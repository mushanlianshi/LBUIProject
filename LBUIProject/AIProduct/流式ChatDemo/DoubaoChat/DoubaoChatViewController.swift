//
//  DoubaoChatViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit
import AVFoundation

/// 豆包式多卡片流式对话页（UICollectionView + NSDiffableDataSource）
///
/// 对照旧版 ChatViewController（UITableView + 手动 insertRows），
/// 本页演示 Diffable 在「多卡片类型 + 流式中途结构穿插」场景的分工：
///
/// 分组结构（主流 AI 对话的数据层对齐：一轮 QA = 一个 DoubaoQARoundModel）：
/// - .question(roundID) section：用户气泡（无背景）
/// - .answer(roundID) section：该轮全部回答卡片（整段挂背景卡片 decoration）
/// 每轮两个 section 靠同一 UUID 关联，答的 section 背景即「这段回答」的整体视觉边界
///
/// 两层更新机制（关键设计）：
/// - 结构变化 → snapshot appendItems/apply，diff 自动算 insert（找人卡片中途插入、推荐问追加）
/// - 内容变化（id 不变）→ reconfigureItems 定向刷新（思考文本增长、正文增长、折叠态切换），
///   iOS 14 fallback 到 reloadItems
///
/// 职责拆分：UICollectionView 数据源/布局/diffable 更新/滚动代理在
/// DoubaoChatViewController+CollectionDataSources.swift 分类里；
/// 本文件只保留 UI 搭建、事件消费、会话持久化、输入交互。
/// （存储属性无法放进 extension，留在主类并去 private 供分类访问）
final class DoubaoChatViewController: UIViewController {

    // MARK: - Subviews
    lazy var collectionView: UICollectionView = {
        /// per-section 布局：问/答 section 返回不同配置（答的带背景 decoration）
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            self?.layoutSection(at: sectionIndex) ?? Self.makeBaseSection()
        }
        layout.register(DoubaoAnswerBackground.self,
                        forDecorationViewOfKind: DoubaoAnswerBackground.kind)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        cv.keyboardDismissMode = .interactive
        cv.alwaysBounceVertical = true
        cv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        return cv
    }()

    private let inputBar: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        return v
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "输入问题，如：新人如何做架构设计？"
        tf.borderStyle = .roundedRect
        tf.font = .systemFont(ofSize: 16)
        tf.returnKeyType = .send
        return tf
    }()

    private let sendButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("发送", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        return btn
    }()

    private let divider: UIView = {
        let v = UIView()
        v.backgroundColor = .separator
        return v
    }()

    // MARK: - Data & Diffable
    /// 有序数据源（snapshot 的唯一事实来源）：一轮问答 = 一个 round
    var rounds: [DoubaoQARoundModel] = []
    /// 当前流式中的轮次 id（事件到达时定位追加/更新的目标 round）
    var currentRoundID: UUID?

    // MARK: - 持久化（模块隔离：具体逻辑全在 Store/DoubaoChatStoreKeeper，VC 只做调用）
    /// 恢复的历史会话；nil = 新会话。反射入口无参构造走默认 nil
    var existingSession: DoubaoChatSessionModel?
    /// 持久化代理（会话生命周期 + 落库节流）
    private let store = DoubaoChatStoreKeeper()

    /// 注意：项目里 ThirdTabbar 的 DiffableDataSources pod 把
    /// UICollectionViewDiffableDataSource/NSDiffableDataSourceSnapshot 全局 typealias
    /// 指向了第三方实现（无 reconfigureItems），这里必须用 UIKit. 全限定名拿系统原生类
    var dataSource: UIKit.UICollectionViewDiffableDataSource<DoubaoChatSection, DoubaoChatItem>!

    /// 当前流式中的思考块 / 正文 model id（事件到达时定位更新）
    var thinkingModel: DoubaoThinkingModel?
    var markdownModel: DoubaoMarkdownModel?
    let engine = DoubaoMockStreamEngine()

    /// 用户是否停留在底部（流式滚动跟随判定）
    var stickToBottom = true

    var bottomConstraint: NSLayoutConstraint!

    // MARK: - Cell Registrations（交互回调在这里闭包注入）
    /// ⚠️ 不能用 lazy：lazy 首次初始化会发生在 cell provider 执行期间（首个 cell 请求时才访问），
    /// UIKit 检测到 Registration 在 cell provider 调用栈内创建，判定为「每次请求都新建」直接抛
    /// NSInternalInconsistencyException。必须在构造 dataSource 之前显式创建（见分类 setupDataSource）
    var userRegistration: UICollectionView.CellRegistration<DoubaoUserBubbleCell, DoubaoChatItem>!
    var thinkingRegistration: UICollectionView.CellRegistration<DoubaoThinkingCell, DoubaoChatItem>!
    var markdownRegistration: UICollectionView.CellRegistration<DoubaoMarkdownCell, DoubaoChatItem>!
    var contactRegistration: UICollectionView.CellRegistration<DoubaoContactCardCell, DoubaoChatItem>!
    var recommendRegistration: UICollectionView.CellRegistration<DoubaoRecommendCell, DoubaoChatItem>!
    var unsupportedRegistration: UICollectionView.CellRegistration<DoubaoUnsupportedCell, DoubaoChatItem>!
    var actionsRegistration: UICollectionView.CellRegistration<DoubaoActionsCell, DoubaoChatItem>!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "豆包式卡片流式对话"
        view.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        setupUI()
        setupDataSource()
        setupKeyboard()
        collectionView.delegate = self
        textField.delegate = self
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        engine.onEvent = { [weak self] event in
            self?.handleMockEvent(event)
        }
        setupSession()
    }

    // MARK: - 会话（对齐旧版 ChatViewController 模式）
    /// 历史会话：恢复全部轮次（终态直显，WebView 用缓存高度零回调）；新会话：右上角只挂入口
    private func setupSession() {
        if let existing = existingSession {
            store.attach(existing)
            rounds = DoubaoChatDAO.shared.rounds(sessionId: existing.id)
            applySnapshot(reconfiguring: nil, forceScrollToBottom: false)
            debugPrint("LBLog 恢复豆包会话 \(existing.id)，共 \(rounds.count) 轮")
            /// 延迟一拍滚动：WebView 以缓存高度同步就位，快照 apply 完成后再滚到底所见即终态
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.scrollToBottom()
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "历史记录", style: .plain,
                                                            target: self, action: #selector(openHistory))
    }

    @objc private func openHistory() {
        navigationController?.pushViewController(DoubaoChatSessionListViewController(), animated: true)
    }

    deinit {
        engine.stop()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup
    private func setupUI() {
        inputBar.addSubview(divider)
        inputBar.addSubview(textField)
        inputBar.addSubview(sendButton)
        view.addSubview(collectionView)
        view.addSubview(inputBar)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        bottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        let scale = max(view.traitCollection.displayScale, 1)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,

            divider.topAnchor.constraint(equalTo: inputBar.topAnchor),
            divider.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1.0 / scale),

            textField.topAnchor.constraint(equalTo: inputBar.topAnchor, constant: 8),
            textField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 12),
            textField.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 36),

            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: textField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 50),
        ])
    }

    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - Actions
    @objc private func didTapSend() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return
        }
        textField.text = nil
        textField.resignFirstResponder()
        sendQuestion(text)
    }

    /// 发起一轮提问：新建 QA 轮次（新的一对 question/answer section）→ 启动 mock 剧本。
    /// 正在流式中则先打断（旧轮的流式卡定格为结束态）。
    /// 非 private：+CollectionDataSources 分类里找人卡/推荐问的回调要调
    func sendQuestion(_ text: String) {
        engine.stop()
        finalizeActiveStream()   // 上一轮还在流式中的卡定格
        store.ensureSession(firstQuestion: text)   // 惰性建会话（历史会话继续聊不新建）
        let round = DoubaoQARoundModel(userModel: DoubaoUserModel(text: text))
        rounds.append(round)
        currentRoundID = round.id
        store.persist(round: round)   // 用户消息即终态，立即落库
        applySnapshot(reconfiguring: nil, forceScrollToBottom: true)
        engine.start(script: DoubaoMockStreamEngine.script(for: text))
    }

    // MARK: - Mock 事件消费（SSE 模拟层 → Diffable 数据层）
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
            // 结构性插入：先定格前面流式中的卡，再插卡片（Diffable 主场：diff 自动 insert）
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
        default:
            break
        }
    }

    // MARK: - 回答操作栏（播报/复制/赞踩，作用于最近一轮）
    /// 系统 TTS 播报器（再次点击播报 = 停止）
    private lazy var synthesizer = AVSpeechSynthesizer()

    /// 当前操作栏所属轮次（roundFinished 后即当前轮；历史恢复时为最后一轮）
    private var actionsRoundID: UUID? {
        rounds.last?.id
    }

    /// 操作栏目标轮的全部正文文本（多个 markdown 块按段落拼接）
    private func currentRoundPlainText() -> String? {
        guard let roundID = actionsRoundID,
              let round = rounds.last(where: { $0.id == roundID }) else { return nil }
        var texts: [String] = []
        for item in round.answerItems {
            if case .markdown(let m) = item, !m.text.isEmpty {
                texts.append(m.text)
            }
        }
        return texts.isEmpty ? nil : texts.joined(separator: "\n\n")
    }

    /// 以下三个 action 非 private：+CollectionDataSources 分类里操作栏 registration 回调要调
    func speechCurrentRound() {
        guard let text = currentRoundPlainText() else { return }
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            return
        }
        let utterance = AVSpeechUtterance(string: String(text.prefix(300)))  // demo 截断播报
        utterance.voice = AVSpeechSynthesisVoice(language: "zh-CN")
        synthesizer.speak(utterance)
    }

    func copyCurrentRound() {
        guard let text = currentRoundPlainText() else { return }
        UIPasteboard.general.string = text
        debugPrint("LBLog 已复制本轮回答（\(text.count) 字）")
    }

    /// 点赞/点踩互斥切换：改 model → reconfigure 该 item（增量刷新，状态随整轮 JSON 落库）
    func toggleFeedback(like: Bool) {
        guard let roundID = actionsRoundID,
              let r = rounds.firstIndex(where: { $0.id == roundID }),
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
        applySnapshot(reconfiguring: [.actions(model)], forceScrollToBottom: false)
        store.persist(round: rounds[r])   // 状态变化立即落库
    }

    /// 落库当前轮（StoreKeeper 代理：节流/立即两档；rounds 里的数据始终是最新）
    private func persistCurrentRound(throttled: Bool) {
        guard let roundID = currentRoundID,
              let round = rounds.first(where: { $0.id == roundID }) else { return }
        if throttled {
            store.persistThrottled(round: round)
        } else {
            store.persist(round: round)
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

    // MARK: - Keyboard
    @objc private func keyboardWillShow(_ n: Notification) {
        guard let frame = n.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else {
            return
        }
        bottomConstraint.constant = -(frame.height - view.safeAreaInsets.bottom)
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
        scrollToBottom(animated: true)
    }

    @objc private func keyboardWillHide(_ n: Notification) {
        let duration = (n.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        bottomConstraint.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate
extension DoubaoChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
