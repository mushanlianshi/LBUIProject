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
/// 架构（全局流中心版）：数据（rounds）+ 引擎 + 事件状态机 + 落库已全部上移到
/// DoubaoChatStreamCenter（App 级单例，按会话分桶），本页退化为纯渲染订阅者——
/// attach 订阅流通知 → 翻译成 applySnapshot。由此获得的能力（对齐豆包）：
/// - 流式输出中退出页面：流在后台继续跑、照常落库；重进（含从历史记录进）无缝续播
/// - 多会话并发：每个会话独立桶互不干扰，会话 A 生成中不影响会话 B 提问
/// - 流式中的「发送」按钮切换为「停止生成」
///
/// 分组结构（主流 AI 对话的数据层对齐：一轮 QA = 一个 DoubaoQARoundModel）：
/// - .question(roundID) section：用户气泡（无背景）
/// - .answer(roundID) section：该轮全部回答卡片（整段挂背景卡片 decoration）
///
/// 两层更新机制（关键设计）：
/// - 结构变化 → snapshot appendItems/apply，diff 自动算 insert
/// - 内容变化（id 不变）→ reconfigureItems 定向刷新（iOS 14 fallback 到 reloadItems）
///
/// 本页保留的纯 UI 关注点：手势挂起、stickToBottom 滚动意图、键盘、输入交互。
/// 数据源/布局/diffable 更新在 DoubaoChatViewController+CollectionDataSources.swift 分类里
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

    // MARK: - 流订阅（数据在流桶里，VC 不持有 rounds）
    /// 恢复的历史会话；nil = 新会话。反射入口无参构造走默认 nil
    var existingSession: DoubaoChatSessionModel?
    /// 当前订阅的会话流上下文（attach 后数据/事件/落库全由它负责）
    var stream: DoubaoChatSessionStream!

    // MARK: - Diffable
    /// 注意：项目里 ThirdTabbar 的 DiffableDataSources pod 把
    /// UICollectionViewDiffableDataSource/NSDiffableDataSourceSnapshot 全局 typealias
    /// 指向了第三方实现（无 reconfigureItems），这里必须用 UIKit. 全限定名拿系统原生类
    var dataSource: UIKit.UICollectionViewDiffableDataSource<DoubaoChatSection, DoubaoChatItem>!

    /// 用户是否停留在底部（流式滚动跟随判定）
    var stickToBottom = true

    /// 手势期间挂起的 apply 补拍标记（松手时触发一次全量 apply，见分类 applySnapshot 注释）
    var pendingApplyDuringGesture = false

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
    var loadingRegistration: UICollectionView.CellRegistration<DoubaoLoadingCell, DoubaoChatItem>!

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
        setupSession()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 重入抢占订阅权：同一会话先后打开两个页面（本页 → 历史列表 → 同一会话），
        // 弹回本页时把订阅权抢回来，继续收增量通知。
        // 同时补一次按钮状态：订阅被抢/页面离开期间流可能已结束（错过 onFinish 通知）
        stream.subscriber = self
        updateSendButtonState()
    }

    // MARK: - 会话订阅
    /// attach 流桶 + 首帧定位——豆包式首帧定位（对齐 26Project 方案）：
    /// 进入时隐藏列表（页面底色 = 列表底色，隐藏期间视觉是纯背景），
    /// 「apply 完成 + 布局就绪」双条件满足后一次性滚底再显示——
    /// 用户看到的第一帧就是最后一轮，全程无「顶部→底部」可见跳变。
    ///
    /// 两条进入路径（对 VC 透明，拿到的都是「当前最全的 rounds」）：
    /// - 历史会话：桶活跃（后台生成中）→ 内存 rounds 无缝续播；桶不在 → 从库重建终态
    /// - 新会话：预生成 sessionID 建空桶（DB 行延迟到首次提问）
    private func setupSession() {
        if let existing = existingSession {
            stream = DoubaoChatStreamCenter.shared.stream(for: existing)
            collectionView.isHidden = true   // 定位完成前不显示（双底色相同，视觉纯背景）
            debugPrint("LBLog 恢复豆包会话 \(existing.id)，共 \(stream.rounds.count) 轮，流式中: \(stream.isStreaming)")
            applySnapshot(reconfiguring: nil, forceScrollToBottom: false) { [weak self] in
                // 条件一：数据源 apply 完成（numberOfSections 已就位，滚底不落空）
                self?.dataSourceReadyOnEnter = true
                self?.tryScrollToBottomOnEnter()
            }
        } else {
            stream = DoubaoChatStreamCenter.shared.createStream()
        }
        stream.subscriber = self
        updateSendButtonState()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "历史记录", style: .plain,
                                                            target: self, action: #selector(openHistory))
    }

    // MARK: - 首帧定位就绪门卫（双条件一次性）
    /// apply 完成（数据源就位）
    private var dataSourceReadyOnEnter = false
    /// 布局完成（bounds.width 非零，contentSize 按真实宽度算出）
    private var pendingScrollToBottomOnEnter = true

    /// 布局就绪补偿路径：viewDidLayoutSubviews 在 apply 完成前后都可能触发，
    /// 每次都尝试满足条件二（仅历史恢复期间）
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if pendingScrollToBottomOnEnter, collectionView.bounds.width > 0 {
            tryScrollToBottomOnEnter()
        }
    }

    /// 双条件门卫：apply 完成 && 布局就绪 → 一次滚底 + 显示列表。
    /// 两个时序漏洞各自被另一方补上：
    /// - apply 早于布局：bounds.width=0，contentSize 错值 → 挂起等 viewDidLayoutSubviews
    /// - 布局早于 apply：numberOfSections=0，滚底无效 → 挂起等 apply completion
    private func tryScrollToBottomOnEnter() {
        guard pendingScrollToBottomOnEnter, dataSourceReadyOnEnter,
              collectionView.bounds.width > 0 else { return }
        pendingScrollToBottomOnEnter = false
        scrollToBottom()
        collectionView.isHidden = false   // 定位完成，列表登场——第一帧即底部终态
        // 空会话也照常显示（scrollToBottom 内部 guard 兜底）
    }

    @objc private func openHistory() {
        navigationController?.pushViewController(DoubaoChatSessionListViewController(), animated: true)
    }

    deinit {
        // 只解绑不掐流：非流式中的桶由 center 随之销毁；流式中的保留后台续跑完
        if let stream {
            DoubaoChatStreamCenter.shared.detach(stream)
        }
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
        // 流式中 = 停止生成（对齐豆包：发送按钮切换为停止按钮）；
        // 按钮刷新由流桶的流态翻转通知驱动（stopStreaming 内 notifyStreamingState）
        if stream.isStreaming {
            stream.stopStreaming()
            return
        }
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else {
            return
        }
        textField.text = nil
        textField.resignFirstResponder()
        sendQuestion(text)
    }

    /// 发起一轮提问：打断旧流/建会话/loading/剧本/落库全在流桶里，
    /// 离开页面期间照常执行
    func sendQuestion(_ text: String) {
        stream.ask(text)
    }

    /// 发送/停止切换（流式中显示停止，对应豆包「停止生成」；
    /// 状态变化时机：attach 后 + 每次流通知回调）
    private func updateSendButtonState() {
        if stream.isStreaming {
            sendButton.setTitle("停止", for: .normal)
            sendButton.setTitleColor(.systemRed, for: .normal)
        } else {
            sendButton.setTitle("发送", for: .normal)
            sendButton.setTitleColor(.systemBlue, for: .normal)
        }
    }

    // MARK: - 回答操作栏（播报/复制/赞踩，作用于最近一轮）
    /// 系统 TTS 播报器（再次点击播报 = 停止）
    private lazy var synthesizer = AVSpeechSynthesizer()

    /// 操作栏目标轮的全部正文文本（多个 markdown 块按段落拼接）——纯读操作，直接读流桶
    private func currentRoundPlainText() -> String? {
        guard let round = stream.rounds.last else { return nil }
        var texts: [String] = []
        for item in round.answerItems {
            if case .markdown(let m) = item, !m.text.isEmpty {
                texts.append(m.text)
            }
        }
        return texts.isEmpty ? nil : texts.joined(separator: "\n\n")
    }

    /// 以下两个 action 非 private：+CollectionDataSources 分类里操作栏 registration 回调要调
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

// MARK: - DoubaoChatStreamDelegate（流通知 → diffable 两层更新）
extension DoubaoChatViewController: DoubaoChatStreamDelegate {
    /// 流桶数据变化 → 翻译成 applySnapshot：
    /// - reconfiguring 为空 = 结构变化（重建 snapshot，diff 自动算增删）
    /// - 非空 = 内容变化（带最新值 reconfigure 定向刷新）
    /// - followsScrollIntent 决定是否按 stickToBottom 意图跟到底（原地变化不许拽人）
    func chatStreamDidUpdate(reconfiguring: [DoubaoChatItem], followsScrollIntent: Bool) {
        applySnapshot(reconfiguring: reconfiguring.isEmpty ? nil : reconfiguring,
                      forceScrollToBottom: followsScrollIntent ? stickToBottom : false)
    }

    /// 流式态翻转（ask 开始 / 剧本跑完 / 手动停止）——只在这三个低频点刷新按钮，
    /// 数据每拍高频通知不再掺和按钮状态
    func chatStreamStreamingStateDidChange() {
        updateSendButtonState()
    }
}

// MARK: - UITextFieldDelegate
extension DoubaoChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
