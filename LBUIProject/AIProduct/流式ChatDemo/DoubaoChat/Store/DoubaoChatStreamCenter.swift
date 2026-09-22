//
//  DoubaoChatStreamCenter.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/22.
//

import Foundation

/// 流订阅协议（页面实现）：流数据每次变化后回调，页面只负责翻译成 applySnapshot
protocol DoubaoChatStreamDelegate: AnyObject {
    /// - Parameters:
    ///   - reconfiguring: 需要定向刷新的 item（空数组 = 结构变化，重建 snapshot 即可）
    ///   - followsScrollIntent: true = 页面按用户滚动意图（stickToBottom）决定是否跟到底；
    ///     false = 原地变化（高度定型/折叠/赞踩），不许拽人
    func chatStreamDidUpdate(reconfiguring: [DoubaoChatItem], followsScrollIntent: Bool)

    /// 流式态翻转（ask 开始 / 剧本自然跑完 / 手动停止）——低频事件，页面据此刷新
    /// 发送/停止按钮等「流态 UI」。与 chatStreamDidUpdate 分离：数据通知是每拍高频的，
    /// 按钮状态只跟流态相关，只在翻转点通知一次
    func chatStreamStreamingStateDidChange()
}

extension DoubaoChatStreamDelegate {
    /// 默认空实现：历史会话等不需要流态 UI 的订阅方可不实现
    func chatStreamStreamingStateDidChange() {}
}

/// 全局流式会话中心（App 级单例）：多会话分桶并发，替代「流绑在页面上」的旧架构
///
/// 为什么需要它：旧版 rounds/engine/状态机全在 VC 上，退出页面 = engine.stop()，
/// 流被掐死、节流落库的尾拍丢失——「离开页面回答就没了」。
/// 上移后流的生命周期 = 会话的生命周期，与页面解耦；页面只是渲染订阅者。
///
/// 多会话设计（对齐豆包/ChatGPT 的真实行为）：
/// - 一个会话一个桶（DoubaoChatSessionStream），各自独立 engine/状态机/落库，
///   天然并发互不干扰（会话 A 生成中不影响会话 B 提问）
/// - 不做全局串行队列：真实 SSE 每路连接独立下载，不存在「排队等上一路跑完」的语义；
///   若未来服务端限并发，在 center 与桶之间插一层 scheduler 即可，桶无感知
/// - 桶生命周期：进入页面时命中/惰性重建；「流结束 && 无订阅者」或「页面销毁 && 非流式中」
///   时销毁。终态必先 flush 落库再销毁——任何时候查一个会话：
///   桶在则内存最新（流式中续播），桶不在则 DB 终态完整（常规历史恢复）
final class DoubaoChatStreamCenter {

    static let shared = DoubaoChatStreamCenter()

    /// sessionID → 流上下文（并发分桶）
    private var streams: [String: DoubaoChatSessionStream] = [:]

    private init() {}

    // MARK: - 取流（两条进入路径）

    /// 历史会话进入：桶活跃（该会话正在后台生成中）→ 直接用内存 rounds 无缝续播；
    /// 桶不存在 → 从库重建终态 rounds 建新桶（常规历史恢复路径）
    func stream(for session: DoubaoChatSessionModel) -> DoubaoChatSessionStream {
        if let existing = streams[session.id] { return existing }
        let stream = DoubaoChatSessionStream(
            sessionID: session.id,
            existing: session,
            rounds: DoubaoChatDAO.shared.rounds(sessionId: session.id))
        streams[session.id] = stream
        return stream
    }

    /// 新会话进入：预生成 sessionID 建空桶（DB 会话行延迟到首次 ask 才创建，
    /// 保持「没聊就退不占库」的旧语义）
    func createStream() -> DoubaoChatSessionStream {
        let id = UUID().uuidString
        let stream = DoubaoChatSessionStream(sessionID: id, existing: nil, rounds: [])
        streams[id] = stream
        return stream
    }

    // MARK: - 生命周期

    /// 页面销毁时调用：不是正在接受的流式，就给移除掉
    func detach(_ stream: DoubaoChatSessionStream) {
        guard !stream.isStreaming else { return }
        streams.removeValue(forKey: stream.sessionID)
    }

    /// 会话是否正在生成中（历史列表角标/红点等场景的入口，本次预留未消费）
    func isStreaming(sessionID: String) -> Bool {
        streams[sessionID]?.isStreaming ?? false
    }
}

/// 单会话流上下文：数据（rounds）+ 引擎 + 事件状态机 + 落库，全部从 VC 平移而来。
/// 页面只通过 DoubaoChatStreamDelegate 订阅变化，不直接改数据
final class DoubaoChatSessionStream {

    let sessionID: String
    /// 有序数据源（snapshot 的唯一事实来源）：一轮问答 = 一个 round
    private(set) var rounds: [DoubaoQARoundModel]

    /// 订阅页面（weak：VC 销毁无需反注册，桶持有的引用自动失效；
    /// 同一会话同时只有一个活跃订阅者，后 attach 的抢占）
    weak var subscriber: DoubaoChatStreamDelegate?

    /// 当前流式中的轮次 id（事件到达时定位追加/更新的目标 round）
    private var currentRoundID: UUID?
    /// 当前流式中的思考块 / 正文 model（事件到达时定位更新）
    private var thinkingModel: DoubaoThinkingModel?
    private var markdownModel: DoubaoMarkdownModel?

    private let engine = DoubaoMockStreamEngine()
    private let store = DoubaoChatStoreKeeper()
    /// loading 卡展示期（模拟服务端首字延迟 2 秒）的挂起任务——也算流式中，
    /// 「停止生成」要能掐掉它
    private var pendingStart: DispatchWorkItem?

    /// 流式中 = 剧本在跑 或 首字延迟等待中（页面据此切换 发送/停止 按钮）
    var isStreaming: Bool { engine.isRunning || pendingStart != nil }

    init(sessionID: String,
         existing session: DoubaoChatSessionModel?,
         rounds: [DoubaoQARoundModel]) {
        self.sessionID = sessionID
        self.rounds = rounds
        if let session { store.attach(session) }
        engine.onEvent = { [weak self] event in
            self?.handleMockEvent(event)
        }
        // 剧本自然跑完：engine 队列耗尽自动 stop 是静默的（roundFinished 事件处理时
        // timer 还活着，isStreaming 仍为 true）——没有这次通知，页面「停止」按钮
        // 永远不会翻回「发送」
        engine.onFinish = { [weak self] in
            self?.notifyStreamingState()
            self?.teardownIfIdle()
        }
    }

    deinit {
        engine.stop()
    }

    // MARK: - 提问 / 停止

    /// 发起一轮提问（豆包语义：先 loading 卡 2 秒 → 移除 → 启动剧本）。
    /// 正在流式/加载中再提问：打断旧剧本、剥掉旧 loading。
    /// 离开页面期间照常执行——数据与落库都在桶里，与页面无关
    func ask(_ text: String) {
        engine.stop()
        pendingStart?.cancel()
        pendingStart = nil
        finalizeActiveStream()   // 上一轮还在流式中的卡定格
        removeAllLoadingItems()  // 上一轮加载被打断：剥掉残留 loading 卡
        store.ensureSession(id: sessionID, firstQuestion: text)
        let round = DoubaoQARoundModel(userModel: DoubaoUserModel(text: text))
        rounds.append(round)
        currentRoundID = round.id
        store.persist(round: round)   // 用户消息即终态，立即落库
        appendAnswerItem(.loading(DoubaoLoadingModel()))
        // 模拟服务端「首字延迟」：loading 展示 2 秒后移除并开始流式输出
        let roundID = round.id
        let work = DispatchWorkItem { [weak self] in
            guard let self, self.currentRoundID == roundID else { return }  // 已被新一轮提问打断
            self.pendingStart = nil
            self.removeLoadingItem(roundID: roundID)
            self.engine.start(script: DoubaoMockStreamEngine.script(for: text))
        }
        pendingStart = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: work)
        // 流式态翻转通知（含打断重开）：按钮 → 停止。
        // ⚠️ 必须在 pendingStart 赋值之后调用：isStreaming = engine.isRunning || pendingStart != nil，
        // 若在赋值前通知，页面读到的 isStreaming 仍是 false → 按钮不翻
        notifyStreamingState()
    }

    /// 手动停止生成（页面的「停止」按钮）：掐掉剧本/首字延迟，
    /// 定格当前半成品为终态并落库
    func stopStreaming() {
        pendingStart?.cancel()
        pendingStart = nil
        engine.stop()
        finalizeActiveStream()
        removeAllLoadingItems()
        persistCurrentRound(throttled: false)
        notifyStreamingState()   // 流式态翻转：按钮 → 发送
        teardownIfIdle()
    }

    // MARK: - Mock 事件消费（SSE 模拟层 → 数据层，从 VC 平移）
    /// 状态机语义：按事件流的「类型边界」分组——不同类型事件一出现，
    /// 前面的流式卡/思考卡立即定格结束，新内容新开一张卡（绝不拼回旧卡）。
    /// 支持「正文 → 卡片 → 新正文 → 思考 → …」任意穿插的剧本
    private func handleMockEvent(_ event: DoubaoMockEvent) {
        switch event {
        case .thinkingStart:
            finalizeActiveStream()
            let model = DoubaoThinkingModel()
            thinkingModel = model
            appendAnswerItem(.thinking(model))

        case .thinkingText(let chunk):
            // 当前无活跃思考卡（被其他类型卡片打断/剧本直接发文本）→ 新开一张
            if thinkingModel == nil {
                finalizeActiveStream()
                let model = DoubaoThinkingModel()
                thinkingModel = model
                appendAnswerItem(.thinking(model))
            }
            thinkingModel?.text += chunk
            if let model = thinkingModel {
                updateItem(.thinking(model))
            }
            persistCurrentRound(throttled: true)

        case .thinkingEnd(let seconds):
            // 只结束「当前活跃」的思考卡；无活跃卡（事件乱序/已被打断）忽略
            guard var model = thinkingModel else { return }
            model.isStreaming = false
            model.isExpanded = false
            model.elapsedSeconds = seconds
            thinkingModel = nil
            updateItem(.thinking(model))

        case .answerStart:
            finalizeActiveStream()
            let model = DoubaoMarkdownModel()
            markdownModel = model
            appendAnswerItem(.markdown(model))

        case .answerText(let chunk):
            // 当前无活跃正文卡（被找人卡片等打断后正文继续）→ 新开一张，不拼回旧卡
            if markdownModel == nil {
                finalizeActiveStream()
                let model = DoubaoMarkdownModel()
                markdownModel = model
                appendAnswerItem(.markdown(model))
            }
            markdownModel?.text += chunk
            if let model = markdownModel {
                updateItem(.markdown(model))
            }
            persistCurrentRound(throttled: true)

        case .contactCard(let name, let title, let intro, let tags):
            // 结构性插入：先定格前面流式中的卡，再插卡片（diff 自动算 insert）
            finalizeActiveStream()
            let model = DoubaoContactModel(name: name, title: title, intro: intro, tags: tags)
            appendAnswerItem(.contact(model))

        case .recommend(let questions):
            finalizeActiveStream()
            let model = DoubaoRecommendModel(questions: questions)
            appendAnswerItem(.recommend(model))

        case .unsupportedCard(let rawType, let rawPayload):
            // 前向兼容兜底：服务端新卡片类型，本版本无对应 case——
            // 原样存（落库/同步不丢数据），渲染占位「暂不支持」
            finalizeActiveStream()
            let model = DoubaoUnsupportedModel(rawType: rawType, rawPayload: rawPayload)
            appendAnswerItem(.unsupported(model))

        case .roundFinished:
            // 本轮流式结束（对应真实 SSE done）：定格 + 追加操作栏（播报/复制/赞踩）
            finalizeActiveStream()
            appendAnswerItem(.actions(DoubaoActionsModel()))

        case .idle:
            // 空拍：纯消耗节拍（制造「上一块输出完 → 停顿 → 下一卡片出现」的节奏），无动作
            break
        }

        // 结构事件（卡片插入/思考结束/终态）立即落库——文本事件已各自节流，这里补结构变化
        switch event {
        case .thinkingStart, .thinkingEnd, .answerStart, .contactCard, .recommend, .unsupportedCard, .roundFinished:
            persistCurrentRound(throttled: false)
            // 后台跑完（无页面订阅）：终态已 flush 落库，桶可销毁释放内存
            if case .roundFinished = event { teardownIfIdle() }
        default:
            break
        }
    }

    // MARK: - 数据变更原语（结构变化 / 内容变化，从 VC 平移后通知订阅者）

    /// 结构变化：往当前流式轮次的 answerItems 追加卡片（diff 自动算 insert）
    private func appendAnswerItem(_ item: DoubaoChatItem) {
        guard let roundID = currentRoundID,
              let index = rounds.firstIndex(where: { $0.id == roundID }) else { return }
        rounds[index].answerItems.append(item)
        notify(reconfiguring: [], followsScrollIntent: true)
    }

    /// 内容变化（id 不变）：替换数据源后通知页面带新值 reconfigure。
    /// （snapshot 存的是 apply 时的值拷贝，页面侧重建 snapshot 时自然带上最新值）
    private func updateItem(_ newItem: DoubaoChatItem) {
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: { $0 == newItem }) {
                rounds[r].answerItems[i] = newItem
                notify(reconfiguring: [newItem], followsScrollIntent: true)
                return
            }
        }
    }

    /// 移除指定轮的 loading 卡（结构性删除：diff 自动算 delete）
    private func removeLoadingItem(roundID: UUID) {
        guard let index = rounds.firstIndex(where: { $0.id == roundID }) else { return }
        let filtered = rounds[index].answerItems.filter {
            if case .loading = $0 { return false }
            return true
        }
        guard filtered.count != rounds[index].answerItems.count else { return }
        rounds[index].answerItems = filtered
        notify(reconfiguring: [], followsScrollIntent: true)
    }

    /// 剥掉所有轮次残留的 loading 卡（新一轮提问打断上一轮加载时清理）
    private func removeAllLoadingItems() {
        var changed = false
        for r in rounds.indices {
            let filtered = rounds[r].answerItems.filter {
                if case .loading = $0 { changed = true; return false }
                return true
            }
            rounds[r].answerItems = filtered
        }
        if changed {
            notify(reconfiguring: [], followsScrollIntent: false)
        }
    }

    /// 定格当前流式中的卡（不同类型事件到达时调用）：
    /// 正文去光标；思考卡若无 end 事件被硬打断，也转为结束态（保持当前展开状态）
    private func finalizeActiveStream() {
        if var model = markdownModel {
            model.isStreaming = false
            markdownModel = nil
            updateItem(.markdown(model))
        }
        if var model = thinkingModel {
            model.isStreaming = false
            model.elapsedSeconds = max(model.elapsedSeconds, 1)
            thinkingModel = nil
            updateItem(.thinking(model))
        }
    }

    // MARK: - 通知订阅者

    private func notify(reconfiguring: [DoubaoChatItem], followsScrollIntent: Bool) {
        subscriber?.chatStreamDidUpdate(reconfiguring: reconfiguring,
                                        followsScrollIntent: followsScrollIntent)
    }

    /// 流式态翻转通知（ask / 自然跑完 / 手动停止三个翻转点显式调用）：
    /// 页面据此刷新发送/停止按钮等流态 UI——数据每拍高频通知不掺和这件事
    private func notifyStreamingState() {
        subscriber?.chatStreamStreamingStateDidChange()
    }

    // MARK: - 页面侧数据交互入口（折叠/赞踩/高度写回）

    /// 思考块折叠/展开（id 不变的内容变化）。
    /// - 按 id 回查最新 model：避免基于 configure 时的旧状态反复切换
    /// - followsScrollIntent false：展开/收起是原地变化，不许拽人
    func toggleThinkingExpand(modelID: UUID) {
        for r in rounds.indices {
            guard let i = rounds[r].answerItems.firstIndex(where: { item in
                if case .thinking(let m) = item { return m.id == modelID }
                return false
            }), case .thinking(var model) = rounds[r].answerItems[i] else { continue }
            guard !model.isStreaming else { return }  // 流式中禁止收起
            model.isExpanded.toggle()
            rounds[r].answerItems[i] = .thinking(model)
            notify(reconfiguring: [.thinking(model)], followsScrollIntent: false)
            return
        }
    }

    /// 点赞/点踩互斥切换（作用于最近一轮的操作栏）：改 model → 通知 reconfigure → 落库
    func toggleFeedback(like: Bool) {
        guard let r = rounds.indices.last,
              let i = rounds[r].answerItems.firstIndex(where: {
                  if case .actions = $0 { return true }
                  return false
              }),
              case .actions(var model) = rounds[r].answerItems[i] else { return }
        if like {
            model.isLiked.toggle()
            if model.isLiked { model.isDisliked = false }
        } else {
            model.isDisliked.toggle()
            if model.isDisliked { model.isLiked = false }
        }
        rounds[r].answerItems[i] = .actions(model)
        notify(reconfiguring: [.actions(model)], followsScrollIntent: false)
        store.persist(round: rounds[r])   // 状态变化立即落库
    }

    /// 流式中的高度回传：写回 model + 通知页面 reconfigure 对应 item（增量更新路径）。
    /// 去重：高度与 model 缓存相同则跳过（JS 对同一文本可能反复报同高度）
    func applyRenderedHeight(modelID: UUID, height: CGFloat, renderWidth: CGFloat) {
        guard !updateRenderedHeight(modelID: modelID, height: height, renderWidth: renderWidth) else { return }
        if let item = markdownItem(modelID: modelID) {
            notify(reconfiguring: [item], followsScrollIntent: true)
        }
    }

    /// 终态高度修正（onHeightSettled 入口）：缓存有变化 → reconfigure 收敛（不滚动）。
    /// 与 applyRenderedHeight 的区别：不跟随滚动意图（终态修正不该拽人），只做布局收敛
    func settleRenderedHeight(modelID: UUID, height: CGFloat, renderWidth: CGFloat) {
        guard !updateRenderedHeight(modelID: modelID, height: height, renderWidth: renderWidth) else { return }
        if let item = markdownItem(modelID: modelID) {
            notify(reconfiguring: [item], followsScrollIntent: false)
        }
    }

    /// 高度写回 model：更新 rounds 源（供复用/终态 configure 采用）+ 活跃引用
    /// （下一拍 updateItem 构造新 model 时带上，不被旧副本覆盖）。
    /// 同时写入宽度指纹（renderedWidth）：多端同步来的「别的宽度下的高度」恢复时据此作废。
    /// 返回 true = 高度未变化（重复回传，调用方据此跳过）
    @discardableResult
    private func updateRenderedHeight(modelID: UUID, height: CGFloat, renderWidth: CGFloat) -> Bool {
        var duplicated = true
        if markdownModel?.id == modelID, markdownModel?.renderedHeight != height {
            markdownModel?.renderedHeight = height
            markdownModel?.renderedWidth = renderWidth
            duplicated = false
        }
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: {
                if case .markdown(let m) = $0 { return m.id == modelID }
                return false
            }), case .markdown(var m) = rounds[r].answerItems[i], m.renderedHeight != height {
                m.renderedHeight = height
                m.renderedWidth = renderWidth
                rounds[r].answerItems[i] = .markdown(m)
                duplicated = false
            }
        }
        return duplicated
    }

    /// 按 model id 回查 rounds 里的最新 markdown item（高度回传后通知页面用）
    private func markdownItem(modelID: UUID) -> DoubaoChatItem? {
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: {
                if case .markdown(let m) = $0 { return m.id == modelID }
                return false
            }), case .markdown(let m) = rounds[r].answerItems[i] {
                return .markdown(m)
            }
        }
        return nil
    }

    // MARK: - 落库（StoreKeeper 代理：节流/立即两档）

    private func persistCurrentRound(throttled: Bool) {
        guard let roundID = currentRoundID,
              let round = rounds.first(where: { $0.id == roundID }) else { return }
        if throttled {
            store.persistThrottled(round: round)
        } else {
            store.persist(round: round)
        }
    }

    // MARK: - 桶销毁

    /// 终态销毁：流结束 && 无订阅者 → 桶从 center 移除（rounds 终态已 flush 落库）。
    /// 有订阅者（页面还开着）不销毁——页面销毁 detach 时兜底
    private func teardownIfIdle() {
        guard !isStreaming, subscriber == nil else { return }
        DoubaoChatStreamCenter.shared.detach(self)
    }
}
