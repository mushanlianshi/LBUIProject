//
//  DoubaoChatViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import UIKit
import SnapKit

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
/// Mock 数据流：MockStreamEngine 按剧本节拍吐事件（模拟 SSE）：
/// 思考块流式增长 → 折叠 → 正文增长 →（中途穿插）找人卡片 → 正文继续 → 推荐问
final class DoubaoChatViewController: UIViewController {

    // MARK: - Subviews
    private lazy var collectionView: UICollectionView = {
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
    private var rounds: [DoubaoQARoundModel] = []
    /// 当前流式中的轮次 id（事件到达时定位追加/更新的目标 round）
    private var currentRoundID: UUID?

    /// 注意：项目里 ThirdTabbar 的 DiffableDataSources pod 把
    /// UICollectionViewDiffableDataSource/NSDiffableDataSourceSnapshot 全局 typealias
    /// 指向了第三方实现（无 reconfigureItems），这里必须用 UIKit. 全限定名拿系统原生类
    private var dataSource: UIKit.UICollectionViewDiffableDataSource<DoubaoChatSection, DoubaoChatItem>!

    /// 当前流式中的思考块 / 正文 model id（事件到达时定位更新）
    private var thinkingModel: DoubaoThinkingModel?
    private var markdownModel: DoubaoMarkdownModel?
    private let engine = DoubaoMockStreamEngine()

    /// 用户是否停留在底部（流式滚动跟随判定）
    private var stickToBottom = true

    // MARK: - WebView 高度回调（数据驱动 reconfigure 增量更新）
    /// 流式中的高度回传：写回 model + reconfigure 对应 item（唯一增量更新路径）。
    /// 去重：高度与 model 缓存相同则跳过（JS 对同一文本可能反复报同高度）
    private func applyRenderedHeight(modelID: UUID, height: CGFloat, followScroll: Bool) {
        guard !updateRenderedHeight(modelID: modelID, height: height) else { return }
        // 从 rounds 构造最新 item 走 reconfigure（文本没变，cell 只更新高度约束）
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: {
                if case .markdown(let m) = $0 { return m.id == modelID }
                return false
            }), case .markdown(let m) = rounds[r].answerItems[i] {
                applySnapshot(reconfiguring: [.markdown(m)], forceScrollToBottom: followScroll)
                return
            }
        }
    }

    private var bottomConstraint: NSLayoutConstraint!

    // MARK: - Cell Registrations（交互回调在这里闭包注入）
    /// ⚠️ 不能用 lazy：lazy 首次初始化会发生在 cell provider 执行期间（首个 cell 请求时才访问），
    /// UIKit 检测到 Registration 在 cell provider 调用栈内创建，判定为「每次请求都新建」直接抛
    /// NSInternalInconsistencyException。必须在构造 dataSource 之前显式创建（见 setupDataSource）
    private var userRegistration: UICollectionView.CellRegistration<DoubaoUserBubbleCell, DoubaoChatItem>!
    private var thinkingRegistration: UICollectionView.CellRegistration<DoubaoThinkingCell, DoubaoChatItem>!
    private var markdownRegistration: UICollectionView.CellRegistration<DoubaoMarkdownCell, DoubaoChatItem>!
    private var contactRegistration: UICollectionView.CellRegistration<DoubaoContactCardCell, DoubaoChatItem>!
    private var recommendRegistration: UICollectionView.CellRegistration<DoubaoRecommendCell, DoubaoChatItem>!

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

    /// 单列 estimated 高度基础 section：卡片自撑（autodimension），流式增长自动重排
    private static func makeBaseSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .estimated(60))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        return NSCollectionLayoutSection(group: group)
    }

    /// per-section 布局分发：问 section 无背景，答 section 整段挂背景卡片 decoration
    private func layoutSection(at index: Int) -> NSCollectionLayoutSection {
        guard let identifier = dataSource?.sectionIdentifier(for: index) else {
            return Self.makeBaseSection()
        }
        let section = Self.makeBaseSection()
        switch identifier {
        case .question:
            // 问（用户气泡）：蓝气泡自带背景，仅控制与答 section 的间距
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0)
        case .answer:
            // 答：整段一张白色圆角卡片（背景 decoration），左右留白收在 section inset 上
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 12)
            section.decorationItems = [
                NSCollectionLayoutDecorationItem.background(elementKind: DoubaoAnswerBackground.kind)
            ]
        }
        return section
    }

    private func setupDataSource() {
        // 1. 先创建全部 Registration（必须早于任何 cell provider 调用，见属性注释）
        userRegistration = UICollectionView.CellRegistration { cell, _, item in
            if case .user(let model) = item {
                cell.configure(text: model.text)
            }
        }
        thinkingRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .thinking(let model) = item {
                cell.configure(model: model)
                cell.onToggleExpand = { self?.toggleThinkingExpand(model) }
            }
        }
        markdownRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .markdown(let model) = item {
                cell.configure(model: model)
                // WebView 渲染高度回传（仅流式中触发，终态由 cell 静默处理）。
                // 高度走「数据驱动 reconfigure」：写回 model 后 reconfigure 该 item——
                // diffable 只更新这一个 cell（configure 同文本跳过 JS 重渲，仅高度约束生效）。
                // ⚠️ 不要用全局 invalidateLayout：它会无差别失效所有 cell 的缓存高度，
                // 整列表重新 self-size + 位置重排 → 多轮积累后每次高度回传都全列表跳动（闪烁卡顿）
                cell.onHeightChanged = { [weak self] modelID, height in
                    guard let self else { return }
                    self.applyRenderedHeight(modelID: modelID, height: height,
                                             followScroll: self.stickToBottom)
                }
                // 终态高度定型：只写回 model 缓存（下轮复用 configure 直接采用），不触发重排
                cell.onHeightSettled = { [weak self] modelID, height in
                    self?.updateRenderedHeight(modelID: modelID, height: height)
                }
            }
        }
        contactRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .contact(let model) = item {
                cell.configure(model: model)
                cell.onChatTapped = { name in
                    self?.sendQuestion("@\(name) 你好，想深入请教下这个问题")
                }
            }
        }
        recommendRegistration = UICollectionView.CellRegistration { [weak self] cell, _, item in
            if case .recommend(let model) = item {
                cell.configure(model: model)
                cell.onQuestionTapped = { question in
                    self?.sendQuestion(question)
                }
            }
        }

        // 2. 再构造 dataSource（cell provider 闭包里只 dequeue，不创建任何东西）
        dataSource = UIKit.UICollectionViewDiffableDataSource<DoubaoChatSection, DoubaoChatItem>(
            collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }
            switch item {
            case .user:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.userRegistration, for: indexPath, item: item)
            case .thinking:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.thinkingRegistration, for: indexPath, item: item)
            case .markdown:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.markdownRegistration, for: indexPath, item: item)
            case .contact:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.contactRegistration, for: indexPath, item: item)
            case .recommend:
                return collectionView.dequeueConfiguredReusableCell(
                    using: self.recommendRegistration, for: indexPath, item: item)
            }
        }
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
    /// 正在流式中则先打断（旧轮的流式卡定格为结束态）
    private func sendQuestion(_ text: String) {
        engine.stop()
        finalizeActiveStream()   // 上一轮还在流式中的卡定格
        let round = DoubaoQARoundModel(userModel: DoubaoUserModel(text: text))
        rounds.append(round)
        currentRoundID = round.id
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

        case .contactCard(let name, let title, let intro, let tags):
            // 结构性插入：先定格前面流式中的卡，再插卡片（Diffable 主场：diff 自动 insert）
            finalizeActiveStream()
            let model = DoubaoContactModel(name: name, title: title, intro: intro, tags: tags)
            appendAnswerItem(.contact(model))

        case .recommend(let questions):
            finalizeActiveStream()
            let model = DoubaoRecommendModel(questions: questions)
            appendAnswerItem(.recommend(model))

        case .idle:
            // 空拍：纯消耗节拍（制造「上一块输出完 → 停顿 → 下一卡片出现」的节奏），无动作
            break
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

    // MARK: - Diffable 两层更新
    /// 结构变化：往当前流式轮次的 answerItems 追加卡片（snapshot 全量重建，diff 自动算 insert）。
    /// 滚动策略：按 stickToBottom 意图跟随——用户上滑看历史时新卡片插入不打扰（对齐微信/Telegram），
    /// 拖回底部才恢复跟随；无条件滚底会导致「上滑被周期性弹回」（每次新卡片插入都拽人）
    private func appendAnswerItem(_ item: DoubaoChatItem) {
        guard let roundID = currentRoundID,
              let index = rounds.firstIndex(where: { $0.id == roundID }) else { return }
        rounds[index].answerItems.append(item)
        applySnapshot(reconfiguring: nil, forceScrollToBottom: stickToBottom)
    }

    /// 内容变化（id 不变）：替换数据源后必须带新值重建 snapshot 并 reconfigure。
    /// ⚠️ 关键：snapshot 存的是 apply 时的值拷贝——只改数据源再 reconfigureItems，
    /// cell provider 收到的仍是 snapshot 里的旧值（流式表现为内容不增长，
    /// 直到下次结构性 append 重建 snapshot 才「一下子」出现全部文本）。
    /// 正确姿势：把最新数据重新 append 进 snapshot + reconfigure 标记变化项
    private func updateItem(_ newItem: DoubaoChatItem) {
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: { $0 == newItem }) {
                rounds[r].answerItems[i] = newItem
                applySnapshot(reconfiguring: [newItem], forceScrollToBottom: stickToBottom)
                return
            }
        }
    }

    /// 统一的 snapshot 构建入口：按 rounds 全量重建（数据量小 diff 成本可忽略）。
    /// 每轮一对 section：.question(id) 装用户气泡、.answer(id) 装答侧卡片序列；
    /// 答侧为空时不加 answer section（避免空背景卡片闪现）
    private func applySnapshot(reconfiguring: [DoubaoChatItem]?, forceScrollToBottom: Bool) {
        var snapshot = UIKit.NSDiffableDataSourceSnapshot<DoubaoChatSection, DoubaoChatItem>()
        for round in rounds {
            snapshot.appendSections([.question(round.id)])
            snapshot.appendItems([.user(round.userModel)], toSection: .question(round.id))
            if !round.answerItems.isEmpty {
                snapshot.appendSections([.answer(round.id)])
                snapshot.appendItems(round.answerItems, toSection: .answer(round.id))
            }
        }
        if let reconfiguring, !reconfiguring.isEmpty {
            if #available(iOS 15.0, *) {
                snapshot.reconfigureItems(reconfiguring)
            } else {
                // iOS 14 无 reconfigure：reload 重建 cell（会闪光标，demo 可接受）
                snapshot.reloadItems(reconfiguring)
            }
        }
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            if forceScrollToBottom {
                self?.scrollToBottom()
            }
        }
    }

    /// 高度写回 model：更新 rounds 源（供复用/终态 configure 采用）+ 活跃引用
    /// （下一拍 updateItem 构造新 model 时带上，不被旧副本覆盖）。
    /// 返回 true = 高度未变化（重复回传，调用方据此跳过 invalidate）
    private func updateRenderedHeight(modelID: UUID, height: CGFloat) -> Bool {
        var duplicated = true
        if markdownModel?.id == modelID, markdownModel?.renderedHeight != height {
            markdownModel?.renderedHeight = height
            duplicated = false
        }
        for r in rounds.indices {
            if let i = rounds[r].answerItems.firstIndex(where: {
                if case .markdown(let m) = $0 { return m.id == modelID }
                return false
            }), case .markdown(var m) = rounds[r].answerItems[i], m.renderedHeight != height {
                m.renderedHeight = height
                rounds[r].answerItems[i] = .markdown(m)
                duplicated = false
            }
        }
        return duplicated
    }

    /// 思考块折叠/展开：内容变化（id 不变），同样走 reconfigure
    private func toggleThinkingExpand(_ model: DoubaoThinkingModel) {
        guard !model.isStreaming else { return }  // 流式中禁止收起
        var updated = model
        updated.isExpanded.toggle()
        updateItem(.thinking(updated))
    }

    // MARK: - Scroll
    private func scrollToBottom(animated: Bool = false) {
        debugPrint("LBLog scrollToBottom -------------------------")
        let lastSection = collectionView.numberOfSections - 1
        guard lastSection >= 0 else { return }
        let lastItem = collectionView.numberOfItems(inSection: lastSection) - 1
        guard lastItem >= 0 else { return }
        collectionView.layoutIfNeeded()
        collectionView.scrollToItem(at: IndexPath(item: lastItem, section: lastSection),
                                    at: .bottom, animated: animated)
    }

    private func isNearBottom() -> Bool {
        let contentH = collectionView.contentSize.height
        let offsetY = collectionView.contentOffset.y
        let visibleH = collectionView.bounds.height
        return contentH - offsetY - visibleH < 80
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

// MARK: - 答侧整段背景卡片（section background decoration）
/// 挂在 .answer section 上：一轮回答（思考块+正文+找人卡片+推荐问）整体包一张白色圆角卡片，
/// 与灰底页面/蓝色问气泡形成「这轮 AI 回答」的视觉边界
final class DoubaoAnswerBackground: UICollectionReusableView {

    static let kind = "DoubaoAnswerBackground"

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.blt.hexColor(0xE8EEF5).cgColor
    }

    required init?(coder: NSCoder) { nil }
}

// MARK: - UITextFieldDelegate
extension DoubaoChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}

// MARK: - 滚动意图维护（同旧版：用户上滑看历史则停止跟随，拖回底部恢复）
extension DoubaoChatViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            stickToBottom = false
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        stickToBottom = isNearBottom()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            stickToBottom = isNearBottom()
        }
    }
}
