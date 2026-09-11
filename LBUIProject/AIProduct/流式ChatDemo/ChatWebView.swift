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

    // MARK: - 宽度屏障（修「历史恢复首帧空白/高度为0」）
    /// ⚠️ cell 尚未布局时 configure 就会触发渲染：此时 webView.frame.width == 0，
    /// JS 拿不到可用宽度 → 文档塌成一条线 → 高度回传 0~1pt、内容白屏
    /// （老 ChatViewController「历史记录刚进来不显示」同根）。
    /// 解法：宽度未就位前只缓存文本，layoutSubviews 拿到真实宽度后再真正渲染
    private var hasValidWidth = false
    /// 宽度屏障期间缓存的待渲染文本（宽度就位后自动补渲）
    private var pendingWidthMarkdown: String?

    convenience init() {
        let config = WKWebViewConfiguration()
        let uc = WKUserContentController()
        config.userContentController = uc
        config.preferences.javaScriptCanOpenWindowsAutomatically = false
        config.defaultWebpagePreferences.allowsContentJavaScript = true

        self.init(frame: .zero, configuration: config)

        backgroundColor = .clear
        isOpaque = false
        // ⚠️ 关键：WKWebView 的 scrollView 默认自带不透明白底，会盖住宿主背景
        // （section decoration 背景卡被它挡住，只露出边缘——「只见边框不见背景色」的元凶）
        scrollView.backgroundColor = .clear
        scrollView.isOpaque = false
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

    /// 宽度屏障解除点：cell 布局完成（frame 拿到真实宽度）后补渲染缓存文本
    override func layoutSubviews() {
        super.layoutSubviews()
        if !hasValidWidth, bounds.width > 0 {
            hasValidWidth = true
            if let text = pendingWidthMarkdown {
                pendingWidthMarkdown = nil
                renderMarkdown(text)
            }
        }
    }

    deinit {
        configuration.userContentController.removeScriptMessageHandler(forName: "height")
    }

    // MARK: - Public

    /// 渲染 markdown 文本。模板未加载完时先缓存，加载完成后自动补渲染；
    /// 宽度未就位（cell 未布局 frame 为 zero）时也先缓存，layoutSubviews 后补渲染——
    /// 否则 JS 按宽度 0 渲染，文档塌成一条线（高度 0~1pt），表现为白屏
    func renderMarkdown(_ markdown: String) {
        let text = LBMarkdownParser.shared.preprocess(markdown)
        if !didLoadTemplate {
            pendingMarkdown = text
            return
        }
        guard hasValidWidth else {
            pendingWidthMarkdown = text
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
