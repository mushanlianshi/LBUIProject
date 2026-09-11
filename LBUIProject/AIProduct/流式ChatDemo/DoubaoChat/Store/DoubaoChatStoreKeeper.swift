//
//  DoubaoChatStoreKeeper.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// VC 的持久化代理：把「会话生命周期 + 落库节流」从 VC 中隔离出来，
/// VC 只需要三个调用（attach / ensureSession / persist(throttled:)），零 SQL 零 DAO 细节
///
/// 落库节奏（对齐旧版 ChatViewController 的哲学）：
/// - 流式文本事件（thinkingText/answerText）→ persistThrottled：每 3 拍真正落一次半成品，
///   流式中杀 App 也能恢复到最近一拍
/// - 结构事件（卡片插入/思考结束/终态）→ persist 立即落
/// - 所有写入走 DAO 的幂等 upsert，半成品与终态同一 API
final class DoubaoChatStoreKeeper {

    /// 当前会话（nil = 尚未创建：首次发送时惰性创建，没聊就退不占库）
    private(set) var session: DoubaoChatSessionModel?

    private var persistTick = 0

    /// 历史会话恢复时挂载（继续聊不建新会话）
    func attach(_ session: DoubaoChatSessionModel) {
        self.session = session
    }

    /// 确保会话存在（首次发送时惰性创建 + 写标题）
    func ensureSession(firstQuestion: String) {
        guard session == nil else { return }
        session = DoubaoChatDAO.shared.createSession()
        DoubaoChatDAO.shared.updateTitle(sessionId: session!.id,
                                         title: String(firstQuestion.prefix(20)))
    }

    /// 落库当前轮（节流版：每 3 次调用真正写一次，流式文本事件用）
    func persistThrottled(round: DoubaoQARoundModel) {
        persistTick += 1
        guard persistTick >= 3 else { return }
        persistTick = 0
        persist(round: round)
    }

    /// 落库当前轮（立即：结构事件/终态用）
    func persist(round: DoubaoQARoundModel) {
        guard let session else { return }
        DoubaoChatDAO.shared.upsertRound(sessionId: session.id, round: round)
    }
}
