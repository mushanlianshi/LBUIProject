import UIKit
import SnapKit

// MARK: - Message Model

final class LBSPMChatMessage {
    let id = UUID()
    let role: LBMessageRole
    var markdown: String
    var attributed: NSMutableAttributedString

    init(role: LBMessageRole, markdown: String = "") {
        self.role = role
        self.markdown = markdown
        self.attributed = NSMutableAttributedString(string: markdown)
    }
}

// MARK: - Chat Cell

final class LBSPMChatCell: UITableViewCell {
    static let reuseId = "LBSPMChatCell"

    private let bubbleView = UIView()
    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.backgroundColor = .clear
        tv.textContainerInset = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
        tv.textContainer.lineFragmentPadding = 0
        tv.dataDetectorTypes = [.link]
        tv.isSelectable = true
        tv.linkTextAttributes = [.foregroundColor: UIColor.systemBlue, .underlineStyle: NSUnderlineStyle.single.rawValue]
        return tv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(textView)
        bubbleView.layer.cornerRadius = 12
    }

    func configure(with message: LBSPMChatMessage, renderer: LBSPMStreamMarkdownRenderer) {
        // Update attributed text from current markdown
        message.attributed = renderer.render(message.markdown)

        let isUser = message.role == .user
        bubbleView.backgroundColor = isUser ? UIColor.systemBlue : UIColor(white: 0.93, alpha: 1)
        textView.textColor = isUser ? .white : .black

        bubbleView.snp.remakeConstraints { make in
            make.top.equalTo(6)
            make.bottom.equalTo(-6)
            if isUser {
                make.right.equalTo(-12)
                make.left.greaterThanOrEqualTo(60)
            } else {
                make.left.equalTo(12)
                make.right.lessThanOrEqualTo(-60)
            }
            make.width.lessThanOrEqualTo(UIScreen.main.bounds.width - 72)
        }

        textView.snp.remakeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10))
        }

        textView.attributedText = message.attributed
    }

    /// Update text only (for streaming), without recreating layout
    func updateText(_ attributed: NSAttributedString) {
        textView.attributedText = attributed
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Streaming Chat Controller

final class LBSPMStreamChatController: UIViewController {

    // MARK: - Properties

    private let tableView = UITableView()
    private let inputBar = UIView()
    private let textField: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .none
        tf.font = .systemFont(ofSize: 16)
        tf.placeholder = "输入问题..."
        tf.returnKeyType = .send
        tf.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tf.layer.cornerRadius = 18
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    private let sendButton = UIButton(type: .system)

    private var messages: [LBSPMChatMessage] = []
    private let renderer = LBSPMStreamMarkdownRenderer()
    private let streamBuffer = LBSPMStreamBuffer()
    private var isStreaming = false
    private var lastCellHeight: CGFloat = 0

    // MARK: - Sample streaming content with code blocks

    private let sample = """
    用 `async/await` 可以简化异步代码，避免回调地狱。

    ### 优势
    - **代码可读性**: 同步风格的异步代码
    - **错误处理**: 使用 `try/catch`
    - **结构化并发**: `Task` 组管理

    ### 示例

    ```swift
    func fetchUserData() async throws -> User {
        let url = URL(string: "https://api.example.com/user")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(User.self, from: data)
    }

    // 并行请求
    async func loadProfile() async throws -> Profile {
        async let user = fetchUserData()
        async let avatar = fetchAvatar()
        return try await Profile(user: user, avatar: avatar)
    }
    ```

    ### 请求流程

    | 步骤 | 说明 | 状态 |
    |------|------|------|
    | 1 | 创建 URL | 已完成 |
    | 2 | 发起请求 | 进行中 |
    | 3 | 解析响应 | 待处理 |

    代码中最关键的是 `async let`，它实现了真正的并发执行。
    """
    
    private func sampleAdditionalTokens() -> [String] {
        return sample.map { String($0) }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupTableView()
        setupInputBar()
        setupKeyboardHandling()
        addInitialMessages()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.register(LBSPMChatCell.self, forCellReuseIdentifier: LBSPMChatCell.reuseId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.keyboardDismissMode = .interactive
        tableView.backgroundColor = .white
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
        }
    }

    private func setupInputBar() {
        inputBar.backgroundColor = UIColor(white: 0.97, alpha: 1)
        inputBar.addSubview(textField)
        textField.delegate = self

        sendButton.setTitle("发送", for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        inputBar.addSubview(sendButton)

        let separator = UIView()
        separator.backgroundColor = UIColor(white: 0.85, alpha: 1)
        inputBar.addSubview(separator)

        view.addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(tableView.snp.bottom)
        }

        textField.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.right.equalTo(sendButton.snp.left).offset(-8)
            make.centerY.equalToSuperview()
            make.height.equalTo(36)
        }

        sendButton.snp.makeConstraints { make in
            make.right.equalTo(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(44)
            make.height.equalTo(36)
        }

        separator.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }

    private func addInitialMessages() {
        messages.append(LBSPMChatMessage(role: .user, markdown: "介绍 Swift 并发编程"))
        messages.append(LBSPMChatMessage(role: .assistant, markdown: ""))
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.startStreaming()
        }
    }

    // MARK: - Streaming

    private func startStreaming() {
        guard !isStreaming else { return }
        isStreaming = true

        let tokens = sampleAdditionalTokens()

        // 模拟流式输出
        Task {
//            let tokens = sa.first ?? ""
            for token in sample {
                try? await Task.sleep(nanoseconds: 20_000_000) // 模拟服务端 50ms 1个token
                self.appendStreamText(String(token))
            }
        }
        
//        Task {
//            let chunkSize = 3
//            var index = 0
//            while index < tokens.count {
//                let end = min(index + chunkSize, tokens.count)
//                let chunk = tokens[index..<end].joined()
//                index = end
//
//                try? await Task.sleep(nanoseconds: 30_000_000) // 30ms per chunk
//                await streamBuffer.append(chunk) { [weak self] batched in
//                    debugPrint("LBLog batched \(batched)")
//                    self?.appendStreamText(batched)
//                }
//            }
//
//            // Force flush remaining
//            await streamBuffer.forceFlush { [weak self] batched in
//                self?.appendStreamText(batched)
//            }
//
//            await MainActor.run {
//                self.isStreaming = false
//            }
//        }
    }

    private func appendStreamText(_ text: String) {
        guard let lastMsg = messages.last, lastMsg.role == .assistant else { return }
        lastMsg.markdown.append(text)
        // Re-render full markdown via swift-markdown
        lastMsg.attributed = renderer.render(lastMsg.markdown)

        let indexPath = IndexPath(row: messages.count - 1, section: 0)

        if let cell = tableView.cellForRow(at: indexPath) as? LBSPMChatCell {
            cell.updateText(lastMsg.attributed)

            let newHeight = cell.systemLayoutSizeFitting(
                CGSize(width: view.bounds.width, height: 0),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height

            if abs(newHeight - lastCellHeight) > 1 {
                lastCellHeight = newHeight
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }
        }

        scrollToBottom()
    }

    // MARK: - Send Message

    @objc private func didTapSend() {
        sendMessage(textField.text)
        textField.text = nil
        textField.resignFirstResponder()
    }

    private func sendMessage(_ text: String?) {
        guard let text = text?.trimmingCharacters(in: .whitespaces), !text.isEmpty, !isStreaming else { return }

        messages.append(LBSPMChatMessage(role: .user, markdown: text))
        messages.append(LBSPMChatMessage(role: .assistant, markdown: ""))

        tableView.reloadData()
        scrollToBottom()

        // Simulate AI thinking delay, then stream
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startStreaming()
        }
    }

    // MARK: - Scroll

    private func scrollToBottom() {
        guard messages.count > 0 else { return }
        let ip = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: ip, at: .bottom, animated: false)
    }

    // MARK: - Keyboard

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        inputBar.snp.updateConstraints { make in
            make.bottom.equalTo(-frame.height + view.safeAreaInsets.bottom)
        }
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        inputBar.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITextFieldDelegate

extension LBSPMStreamChatController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension LBSPMStreamChatController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LBSPMChatCell.reuseId, for: indexPath) as! LBSPMChatCell
        cell.configure(with: messages[indexPath.row], renderer: renderer)
        return cell
    }
}
