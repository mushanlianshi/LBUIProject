//
//  DoubaoChatDAO.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation
import FMDB

/// 豆包对话会话模型（与旧 ChatSessionModel 同构，独立表独立模型，模块不耦合）
final class DoubaoChatSessionModel {
    /// 会话 id（UUID().uuidString，DB 主键）
    let id: String
    /// 会话标题（首条用户消息前 20 字）
    var title: String
    /// 创建时间戳
    let createdAt: TimeInterval

    init(id: String, title: String, createdAt: TimeInterval) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
    }
}

/// 豆包对话持久层：会话 + QA 轮次读写
///
/// 隔离设计：
/// - 独立表 doubao_session / doubao_round（doubao_ 前缀与旧 chat_* 表互不干扰）
/// - 复用 ChatDatabase 管家的 FMDatabaseQueue（同一 sqlite 文件、同一串行队列，
///   无并发问题；管家是基础设施，不算业务耦合）
/// - 一轮 QA = 一行：question 冗余字段（列表预览用）+ payload（整轮 DoubaoQARoundModel JSON）
final class DoubaoChatDAO {

    static let shared = DoubaoChatDAO()

    private var queue: FMDatabaseQueue { ChatDatabase.shared.queue }

    private init() {
        setupSchema()
    }

    // MARK: - 建表
    private func setupSchema() {
        queue.inDatabase { db in
            let createSession = """
            CREATE TABLE IF NOT EXISTS doubao_session (
                id          TEXT PRIMARY KEY,
                title       TEXT NOT NULL DEFAULT '',
                created_at  REAL NOT NULL
            );
            """
            db.executeUpdate(createSession, withArgumentsIn: [])

            let createRound = """
            CREATE TABLE IF NOT EXISTS doubao_round (
                id          TEXT PRIMARY KEY,
                session_id  TEXT NOT NULL,
                question    TEXT NOT NULL DEFAULT '',
                payload     TEXT NOT NULL,
                created_at  REAL NOT NULL,
                FOREIGN KEY(session_id) REFERENCES doubao_session(id) ON DELETE CASCADE
            );
            CREATE INDEX IF NOT EXISTS idx_doubao_round ON doubao_round(session_id, created_at);
            """
            db.executeStatements(createRound)
        }
    }

    // MARK: - 会话
    /// 创建新会话，返回模型
    func createSession() -> DoubaoChatSessionModel {
        let session = DoubaoChatSessionModel(id: UUID().uuidString,
                                             title: "",
                                             createdAt: Date().timeIntervalSince1970)
        queue.inDatabase { db in
            db.executeUpdate("INSERT INTO doubao_session (id, title, created_at) VALUES (?, ?, ?)",
                             withArgumentsIn: [session.id, session.title, session.createdAt])
        }
        return session
    }

    /// 会话列表（按创建时间倒序）
    func listSessions() -> [DoubaoChatSessionModel] {
        var sessions: [DoubaoChatSessionModel] = []
        queue.inDatabase { db in
            guard let rs = db.executeQuery("SELECT id, title, created_at FROM doubao_session ORDER BY created_at DESC",
                                           withArgumentsIn: []) else { return }
            while rs.next() {
                sessions.append(DoubaoChatSessionModel(id: rs.string(forColumn: "id") ?? "",
                                                       title: rs.string(forColumn: "title") ?? "",
                                                       createdAt: rs.double(forColumn: "created_at")))
            }
            rs.close()
        }
        return sessions
    }

    /// 会话标题（首条用户消息前 20 字，已有标题不覆盖）
    func updateTitle(sessionId: String, title: String) {
        queue.inDatabase { db in
            db.executeUpdate("UPDATE doubao_session SET title = ? WHERE id = ? AND title = ''",
                             withArgumentsIn: [title, sessionId])
        }
    }

    /// 删除会话（外键级联删除其下所有轮次）
    func deleteSession(_ sessionId: String) {
        queue.inDatabase { db in
            db.executeUpdate("DELETE FROM doubao_session WHERE id = ?", withArgumentsIn: [sessionId])
        }
    }

    /// 会话内轮次数（列表副标题展示用）
    func roundCount(sessionId: String) -> Int {
        var count = 0
        queue.inDatabase { db in
            guard let rs = db.executeQuery("SELECT COUNT(*) AS cnt FROM doubao_round WHERE session_id = ?",
                                           withArgumentsIn: [sessionId]) else { return }
            if rs.next() { count = Int(rs.int(forColumn: "cnt")) }
            rs.close()
        }
        return count
    }

    // MARK: - 轮次
    /// 幂等写入（流式中每 N 拍半成品 + 终态各调一次，同一 API）。
    /// 对齐旧版 ChatDAO 哲学用 ON CONFLICT 而非 REPLACE：只更新 payload（内含最新文本/高度/卡片），
    /// created_at 永远定格首次插入，保证恢复时轮次顺序稳定
    func upsertRound(sessionId: String, round: DoubaoQARoundModel) {
        guard let payload = try? JSONEncoder().encode(round),
              let payloadString = String(data: payload, encoding: .utf8) else {
            debugPrint("LBLog 豆包轮次序列化失败 \(round.id)")
            return
        }
        queue.inDatabase { db in
            db.executeUpdate("""
                INSERT INTO doubao_round (id, session_id, question, payload, created_at)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                    payload = excluded.payload,
                    question = excluded.question
                """,
                withArgumentsIn: [
                    round.id.uuidString,
                    sessionId,
                    round.userModel.text,
                    payloadString,
                    Date().timeIntervalSince1970,
                ])
        }
    }

    /// 查询会话内全部轮次（按 created_at 升序 + rowid 兜底），恢复历史会话用。
    /// 恢复语义：所有卡片都是终态（isStreaming=false）、正文带 isFromHistory=true
    /// （cell 直接采用持久化的 renderedHeight，不走高度回调——防闪 + 滚动丝滑）
    func rounds(sessionId: String) -> [DoubaoQARoundModel] {
        var result: [DoubaoQARoundModel] = []
        queue.inDatabase { db in
            let sql = """
            SELECT payload FROM doubao_round
            WHERE session_id = ?
            ORDER BY created_at ASC, rowid ASC
            """
            guard let rs = db.executeQuery(sql, withArgumentsIn: [sessionId]) else { return }
            while rs.next() {
                guard let payloadString = rs.string(forColumn: "payload"),
                      let data = payloadString.data(using: .utf8) else { continue }
                guard var round = try? JSONDecoder().decode(DoubaoQARoundModel.self, from: data) else { continue }
                for i in round.answerItems.indices {
                    switch round.answerItems[i] {
                    case .markdown(var m):
                        m.isStreaming = false
                        m.isFromHistory = true
                        round.answerItems[i] = .markdown(m)
                    case .thinking(var t):
                        t.isStreaming = false
                        t.isExpanded = false
                        round.answerItems[i] = .thinking(t)
                    default:
                        break
                    }
                }
                result.append(round)
            }
            rs.close()
        }
        return result
    }
}
