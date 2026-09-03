//
//  ChatDAO.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/3.
//

import Foundation
import FMDB

/// 会话 + 消息读写（demo 体量合一，FMDatabaseQueue 串行保证线程安全）
final class ChatDAO {

    static let shared = ChatDAO()

    private var queue: FMDatabaseQueue { ChatDatabase.shared.queue }

    private init() {}

    // MARK: - 会话

    /// 创建新会话（INSERT），返回模型
    func createSession() -> ChatSessionModel {
        let now = Date().timeIntervalSince1970
        let session = ChatSessionModel(id: UUID().uuidString, title: "", createdAt: now, updatedAt: now)
        queue.inDatabase { db in
            db.executeUpdate("INSERT INTO chat_session (id, title, created_at, updated_at) VALUES (?, ?, ?, ?)",
                             withArgumentsIn: [session.id, session.title, session.createdAt, session.updatedAt])
        }
        return session
    }

    /// 会话列表（按创建时间倒序；updated_at 不再刷新、恒等于创建时间）
    func listSessions() -> [ChatSessionModel] {
        var sessions: [ChatSessionModel] = []
        queue.inDatabase { db in
            guard let rs = db.executeQuery("SELECT id, title, created_at, updated_at FROM chat_session ORDER BY created_at DESC", withArgumentsIn: []) else { return }
            while rs.next() {
                sessions.append(ChatSessionModel(id: rs.string(forColumn: "id") ?? "",
                                                title: rs.string(forColumn: "title") ?? "",
                                                createdAt: rs.double(forColumn: "created_at"),
                                                updatedAt: rs.double(forColumn: "updated_at")))
            }
            rs.close()
        }
        return sessions
    }

    /// 会话标题（首条用户消息前 20 字，已有标题不覆盖）
    func updateTitle(sessionId: String, title: String) {
        queue.inDatabase { db in
            db.executeUpdate("UPDATE chat_session SET title = ? WHERE id = ? AND title = ''",
                             withArgumentsIn: [title, sessionId])
        }
    }

    /// 删除会话（外键级联删除其下所有消息）
    func deleteSession(_ sessionId: String) {
        queue.inDatabase { db in
            db.executeUpdate("DELETE FROM chat_session WHERE id = ?", withArgumentsIn: [sessionId])
        }
    }

    /// 会话内消息数（列表副标题展示用）
    func messageCount(sessionId: String) -> Int {
        var count = 0
        queue.inDatabase { db in
            guard let rs = db.executeQuery("SELECT COUNT(*) AS cnt FROM chat_message WHERE session_id = ?", withArgumentsIn: [sessionId]) else { return }
            if rs.next() {
                count = Int(rs.int(forColumn: "cnt"))
            }
            rs.close()
        }
        return count
    }

    // MARK: - 消息

    /// 新增消息（终态一次落库：用户消息 / 流式结束的助手消息）
    func insertMessage(sessionId: String, message: ChatMessage) {
        upsertMessage(sessionId: sessionId, message: message)
    }

    /// 幂等写入：流式中每 3 拍保存一次半成品、结束时保存终态，同一 API。
    /// 用 SQLite UPSERT 语法而非 INSERT OR REPLACE——关键区别：
    /// REPLACE 会整行重写（created_at 被刷新），而助手消息的最后一次写入是
    /// 异步的高度修正（可能发生在很久之后），刷新会破坏时序导致恢复时
    /// 「问题聚一起、答案聚一起」；ON CONFLICT 只更新 content/height，
    /// created_at 永远定格在首次插入
    func upsertMessage(sessionId: String, message: ChatMessage) {
        queue.inDatabase { db in
            db.executeUpdate("""
                INSERT INTO chat_message
                (id, session_id, role, content, rendered_height, created_at)
                VALUES (?, ?, ?, ?, ?, ?)
                ON CONFLICT(id) DO UPDATE SET
                    content = excluded.content,
                    rendered_height = excluded.rendered_height
                """,
                withArgumentsIn: [
                    message.id.uuidString,
                    sessionId,
                    Self.roleRaw(message.role),
                    message.text,
                    Double(message.renderedHeight),
                    Date().timeIntervalSince1970,
                ])
        }
    }

    /// 查询会话内全部消息（按 created_at 升序 + rowid 兜底同秒排序），恢复历史会话用。
    /// 恢复的消息携带 DB 原 id：后续流式/高度修正的 upsert 才能对齐主键 REPLACE 而非插入新行
    func messages(sessionId: String) -> [ChatMessage] {
        var result: [ChatMessage] = []
        queue.inDatabase { db in
            let sql = """
            SELECT id, role, content, rendered_height FROM chat_message
            WHERE session_id = ?
            ORDER BY created_at ASC, rowid ASC
            """
            guard let rs = db.executeQuery(sql, withArgumentsIn: [sessionId]) else { return }
            while rs.next() {
                let role = Self.role(fromRaw: Int(rs.int(forColumn: "role")))
                let idString = rs.string(forColumn: "id") ?? UUID().uuidString
                let message = ChatMessage(id: UUID(uuidString: idString) ?? UUID(),
                                          role: role,
                                          text: rs.string(forColumn: "content") ?? "")
                message.renderedHeight = CGFloat(rs.double(forColumn: "rendered_height"))
                message.isFromHistory = true
                result.append(message)
            }
            rs.close()
        }
        return result
    }

    // MARK: - role 映射
    private static func roleRaw(_ role: ChatRole) -> Int {
        role == .user ? 0 : 1
    }

    private static func role(fromRaw raw: Int) -> ChatRole {
        raw == 0 ? .user : .assistant
    }
}
