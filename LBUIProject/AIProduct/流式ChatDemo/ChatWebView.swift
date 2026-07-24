import WebKit

/// 封装 WKWebView 的 Markdown 渲染器。
///
/// - 通过 `loadFileURL` 加载本地 `chatweb/index.html` 模板（模板内引用 vendor/ 下的
///   marked / highlight.js / KaTeX 等js，全部打包在 app bundle，离线可用）。
/// - 暴露 `renderMarkdown(_:)`：把 markdown 文本交给前端 marked 解析、
///   highlight.js 高亮代码、KaTeX 渲染公式，结果写入 `#content`。
/// - 渲染完成后通过 `window.webkit.messageHandlers.height` 异步回传真实内容高度。
final class ChatWebView: WKWebView {

    /// 高度回调：前端渲染完成（或字体加载导致尺寸变化）时触发
    var onHeight: ((CGFloat) -> Void)?

    private var didLoadTemplate = false
    private var pendingMarkdown: String?
    private var templateURL: URL?

    convenience init() {
        let config = WKWebViewConfiguration()
        let uc = WKUserContentController()
        config.userContentController = uc
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        self.init(frame: .zero, configuration: config)

        backgroundColor = .clear
        isOpaque = false
        scrollView.isScrollEnabled = false
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        navigationDelegate = self

        uc.add(self, name: "height")
        loadTemplate()
    }

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        self.onHeight = nil
        super.init(frame: frame, configuration: configuration)
    }

    required init?(coder: NSCoder) {
        self.onHeight = nil
        super.init(coder: coder)
    }

    deinit {
        configuration.userContentController.removeScriptMessageHandler(forName: "height")
    }

    // MARK: - Public

    /// 渲染 markdown 文本。模板未加载完时先缓存，加载完成后自动补渲染。
    func renderMarkdown(_ markdown: String) {
        let text = LBMarkdownParser.shared.preprocess(markdown)
        if !didLoadTemplate {
            pendingMarkdown = text
            return
        }
        evaluateJavaScript(renderJSCall(for: text), completionHandler: nil)
    }

    // MARK: - Private

    private func loadTemplate() {
        // 同步根组打包资源时，可能把 index.html 平铺到 bundle 根，也可能保留
        // chatweb/ 子目录结构。这里穷举所有可能的位置，并用正确的 fileURL
        // 构造方式（Bundle.url / fileURLWithPath），避免“加载目标为空”。
        guard templateURL == nil else { return }

        let bundle = Bundle.main
        var candidates = Set<URL>()

        // 1) 平铺到 bundle 根目录
        if let u = bundle.url(forResource: "index", withExtension: "html") {
            candidates.insert(u)
        }
        let fm = FileManager.default
        for url in candidates where fm.fileExists(atPath: url.path) {
            templateURL = url
            // 把整个资源根目录作为可访问范围，确保 vendor/ 及其 fonts/
            // 下的 KaTeX 字体都能通过相对路径被正确加载。
            let readDir = bundle.resourceURL ?? url.deletingLastPathComponent()
            debugPrint("LBLog loadTemplate ->", url.path)
            loadFileURL(url, allowingReadAccessTo: readDir)
            return
        }
        debugPrint("LBLog loadTemplate 失败：bundle 中找不到 index.html，候选：", candidates)
    }

    private func renderJSCall(for text: String) -> String {
        // 注意：JSONSerialization 的 withJSONObject: 只接受 NSArray/NSDictionary，
        // 顶层 String 会抛错。这里用数组包裹做一次标准 JSON 转义，
        // 再剥掉首尾的 [ ]，得到带引号的安全 JS 字符串字面量。
        guard let data = try? JSONSerialization.data(withJSONObject: [text]),
              let arr = String(data: data, encoding: .utf8),
              arr.count >= 2 else {
            return "renderMarkdown(\"\")"
        }
        let quoted = String(arr.dropFirst().dropLast())  // 去掉 [ 和 ]，保留 "..."（已正确转义）
        return "renderMarkdown(\(quoted))"
    }
}

// MARK: - Navigation Delegate

extension ChatWebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didLoadTemplate = true
        if let pending = pendingMarkdown {
            pendingMarkdown = nil
            renderMarkdown(pending)
        } else {
            evaluateJavaScript("reportHeight()", completionHandler: nil)
        }
    }
}

// MARK: - Script Message Handler

extension ChatWebView: WKScriptMessageHandler {
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage
    ) {
        guard message.name == "height",
              let h = message.body as? Double else { return }
        onHeight?(CGFloat(h))
    }
}
