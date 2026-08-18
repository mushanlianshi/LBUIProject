import UIKit
import WebKit

/// AI 消息 cell —— 左对齐浅灰背景，用 WKWebView 渲染 Markdown（表格 / 代码高亮 / 公式）。
///
/// 核心设计：
/// - cell 内部持有一个常驻的 `ChatWebView`，随 cell 复用而复用（不重建）。
/// - `cellForRowAt` 直接把已存储的完整文本交给 WebView 重新渲染，
///   因此 cell 滚动复用后永远不会空白。
/// - 渲染高度由 WebView 异步回传（字体加载、流式增量都会触发），
///   通过 `onHeight` 回调告诉 ViewController 更新行高并决定是否滚动。
final class AssistantMarkdownCell: UITableViewCell {

    static let reuseId = "AssistantMarkdownCell"

    private let bubbleView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.96, alpha: 1)
        v.layer.cornerRadius = 12
        return v
    }()

    private let webView: ChatWebView = ChatWebView()

    /// WebView 内容高度约束，由 onHeight 回调实时更新
    private var heightConstraint: NSLayoutConstraint!

    /// 高度回调（由 ViewController 注入，携带具体 message）
    private var onHeight: ((CGFloat) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        contentView.addSubview(bubbleView)
        bubbleView.addSubview(webView)

        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        webView.translatesAutoresizingMaskIntoConstraints = false

        heightConstraint = webView.heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.isActive = true

        NSLayoutConstraint.activate([
            bubbleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            bubbleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            bubbleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            webView.topAnchor.constraint(equalTo: bubbleView.topAnchor),
            webView.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor),
        ])

        // WebView 渲染出内容高度后：先更新自身约束，再通知外层
        webView.onHeight = { [weak self] height in
            self?.heightConstraint.constant = height
            self?.onHeight?(height)
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Public

    /// 用完整 markdown 文本配置 cell（首次显示或 cell 复用时调用）
    /// - Parameter onHeight: 渲染高度变化时的回调，用于更新 UITableView 行高
    func configure(message: ChatMessage, onHeight: @escaping (CGFloat) -> Void) {
        self.onHeight = onHeight
        webView.renderMarkdown(message.text)
    }

    /// 流式更新（增量文本到达时调用）
    func updateMarkdown(_ text: String) {
        webView.renderMarkdown(text)
    }

    // MARK: - Reuse

//    override func prepareForReuse() {
//        super.prepareForReuse()
//        onHeight = nil
//        heightConstraint.constant = 1
//        webView.renderMarkdown("")
//    }
}
