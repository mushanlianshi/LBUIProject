import UIKit

/// AI 对话主控制器
///
/// 核心设计：
/// - 纯 UIKit 自己实现对话框架（UITableView + 输入栏 + 流式管线）
/// - Markdown 渲染交给 cell 内的 WKWebView（marked + highlight.js + KaTeX），离线可用
/// - cell 复用时直接用 msg.text 重新交给 WebView 渲染，永远不空白
final class ChatViewController: UIViewController {

    // MARK: - Subviews

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.keyboardDismissMode = .interactive
        tv.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        tv.allowsSelection = false
        tv.estimatedRowHeight = 60
        tv.rowHeight = UITableView.automaticDimension
        return tv
    }()

    private let inputBar: UIView = {
        let v = UIView()
        v.backgroundColor = .systemBackground
        return v
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "输入消息…"
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

    // MARK: - Data

    private var messages: [ChatMessage] = []
    private var bottomConstraint: NSLayoutConstraint!

    // MARK: - Streaming

    private var streamTimer: Timer?
    private var streamChars: [Character] = []
    private var streamIndex = 0
    private var streamingMessage: ChatMessage?
    private var stickToBottom = true   // 用户是否停留在底部（决定是否跟随流式滚动）
    private var lastUIUpdate: CFTimeInterval = 0
    private let charInterval: TimeInterval = 0.05    // 每 50ms 推送
    private let charsPerTick = 3                     // 每次推送 3 个字符
    private let uiThrottle: CFTimeInterval = 0.08      // 150ms 节流 UI 更新

    deinit {
        streamTimer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupKeyboard()
        textField.delegate = self
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        inputBar.addSubview(divider)
        inputBar.addSubview(textField)
        inputBar.addSubview(sendButton)
        view.addSubview(tableView)
        view.addSubview(inputBar)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        divider.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false

        bottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)

        let scale = max(view.traitCollection.displayScale, 1)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

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

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserBubbleCell.self, forCellReuseIdentifier: UserBubbleCell.reuseId)
        tableView.register(AssistantMarkdownCell.self, forCellReuseIdentifier: AssistantMarkdownCell.reuseId)
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
        // 发送后收起键盘，腾出显示区域
        textField.resignFirstResponder()

        // 停止旧的流式
        streamTimer?.invalidate()
        streamTimer = nil

        // 插入用户消息
        let userMsg = ChatMessage(role: .user, text: text)
        messages.append(userMsg)
        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .none)
        scrollToBottom()

        // 开始流式回复
        startStreaming()
    }

    // MARK: - Streaming

    private func startStreaming() {
        guard let path = Bundle.main.path(forResource: "kitchen-sink", ofType: "md"),
              let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            // 加载失败也插一条提示
            let msg = ChatMessage(role: .assistant, text: "（演示内容加载失败）", isStreaming: false)
            messages.append(msg)
            tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .none)
            scrollToBottom()
            return
        }

        streamChars = Array(content)
        streamIndex = 0
        lastUIUpdate = 0

        let msg = ChatMessage(role: .assistant, text: "", isStreaming: true)
        messages.append(msg)
        streamingMessage = msg
        tableView.insertRows(at: [IndexPath(row: messages.count - 1, section: 0)], with: .none)
        scrollToBottom()

        // 使用 .common mode，滚动时 Timer 也不暂停
        let timer = Timer(timeInterval: charInterval, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }

            // 推进字符
            let end = min(self.streamIndex + self.charsPerTick, self.streamChars.count)
            self.streamIndex = end
            let partial = String(self.streamChars[0..<end])
            self.streamingMessage?.text = partial

            // 节流更新 UI
            let now = CACurrentMediaTime()
            if now - self.lastUIUpdate >= self.uiThrottle || end >= self.streamChars.count {
                self.lastUIUpdate = now
                self.updateStreamingCell()
            }

            // 流式结束
            if end >= self.streamChars.count {
                timer.invalidate()
                self.streamTimer = nil
                self.streamingMessage?.isStreaming = false
                // 注意：最后一拍已在上面的节流分支（end>=count 命中）渲染过一次，
                // 这里不再重复调用 updateStreamingCell，避免对同一全文触发两次
                // WebView 渲染与两次异步高度回传，从而引发结尾抖动。
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        streamTimer = timer
    }

    /// 通知流式 cell 用最新累积文本刷新渲染。
    /// 行高由 cell 内的 WebView 异步回传，无需在此手动计算。
    private func updateStreamingCell() {
        guard let msg = streamingMessage else { return }
        let row = messages.count - 1
        let indexPath = IndexPath(row: row, section: 0)
        guard let cell = tableView.cellForRow(at: indexPath) as? AssistantMarkdownCell else { return }
        cell.updateMarkdown(msg.text)
    }

    /// WebView 上报的渲染高度：更新消息缓存高度并（在需要时）重排 + 滚动。
    private func handleAssistantHeight(msg: ChatMessage, height: CGFloat) {
        guard let row = messages.firstIndex(where: { $0.id == msg.id }) else { return }
        // 10pt 死区（滞回）：只有真正增长超过 10pt 才采纳并滚动。
        // 结尾 KaTeX 字体落定 / highlight 上色导致的 ±几 pt 小波动会被挡在这里，
        // 不再逐帧重排 + 追底，从而消除“最后一点流式内容抖动/往上顶”。
        guard height > messages[row].renderedHeight + 10 else { return }
        messages[row].renderedHeight = height
        UIView.performWithoutAnimation {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
        // 用 stickToBottom（由用户滚动意图维护），不依赖重排瞬间的 offset，
        // 避免单次高度增量大时被误判为“已离开底部”而停止滚动。
        if stickToBottom {
            scrollToBottom()
        }
    }

    // MARK: - Scroll

    private func scrollToBottom(animated: Bool = false) {
        guard !messages.isEmpty else { return }
        let ip = IndexPath(row: messages.count - 1, section: 0)
        guard tableView.numberOfRows(inSection: 0) > ip.row else { return }
        tableView.scrollToRow(at: ip, at: .bottom, animated: animated)
    }

    /// 是否“接近底部”。仅在用户主动拖动/惯性滚动时用于更新 stickToBottom，
    /// 因此不会被程序触发的滚动污染 offset，也不受单次高度增量影响。
    private func isNearBottom() -> Bool {
        let contentH = tableView.contentSize.height
        let offsetY = tableView.contentOffset.y
        let visibleH = tableView.bounds.height
        return contentH - offsetY - visibleH < 40
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

// MARK: - UITableView DataSource & Delegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    // 用户主动滚动时维护 stickToBottom：
    // - 拖到接近底部 → 继续跟随流式
    // - 向上滑看历史 → 停止跟随，不被拽回
    // 程序触发的 scrollToBottom 不改变该标志。
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging || scrollView.isDecelerating {
            stickToBottom = isNearBottom()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]

        if msg.role == .user {
            let cell = tableView.dequeueReusableCell(withIdentifier: UserBubbleCell.reuseId, for: indexPath) as! UserBubbleCell
            cell.configure(text: msg.text)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: AssistantMarkdownCell.reuseId, for: indexPath) as! AssistantMarkdownCell
            // 直接用已存储的完整文本重新渲染 —— cell 复用后永远不空白；
            // 高度变化通过 onHeight 回调异步上报
            cell.configure(message: msg) { [weak self] height in
                self?.handleAssistantHeight(msg: msg, height: height)
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msg = messages[indexPath.row]
        if msg.role == .user { return UITableView.automaticDimension }

        // 流式中用缓存高度，结束后校准
        if msg.renderedHeight > 0 {
            return msg.renderedHeight + 8  // bubbleView 上下各 4
        }
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let msg = messages[indexPath.row]
        return msg.renderedHeight > 0 ? msg.renderedHeight + 8 : 60
    }
}

// MARK: - UITextFieldDelegate

extension ChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
