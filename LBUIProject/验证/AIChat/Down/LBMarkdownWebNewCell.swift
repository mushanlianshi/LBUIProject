import UIKit
import WebKit
import Down

class LBMarkdownWebNewCell: UITableViewCell, WKScriptMessageHandler {

    // MARK: - Properties
    private var webView: DownView!
    private var lastHeight: CGFloat = 0

    @objc var heightChangedBlock: ((CGFloat) -> Void)?

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupWebView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWebView()
    }

    // MARK: - Setup WebView
    private func setupWebView() {
        let userContentController = WKUserContentController()
        userContentController.add(self, name: "heightChanged")

        let config = WKWebViewConfiguration()
        config.userContentController = userContentController

        webView = try? DownView.init(frame: .zero, markdownString: "")
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.isOpaque = false
        webView.backgroundColor = .clear

        contentView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(10)
        }
    }

    // MARK: - Render Markdown/HTML
    @objc func renderMarkdownHTML(_ html: String) {
        lastHeight = 0

        let wrapHTML = """
        <html>
        <head>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <style>
        body { margin:0; padding:0; font-size:15px; }
        table { width:100%; border-collapse:collapse; }
        td, th { border:1px solid #ccc; padding:6px; }
        </style>
        </head>
        <body>
        \(html)
        <script>
        function reportHeight() {
            var h = Math.max(document.body.scrollHeight, document.documentElement.scrollHeight);
            window.webkit.messageHandlers.heightChanged.postMessage(h);
        }
        window.onload = function() { setTimeout(reportHeight, 50); };
        </script>
        </body>
        </html>
        """

        try? webView.update(markdownString: html) {
            debugPrint("LBLog webview height is \(self.webView.scrollView.contentSize.height)")
            self.webView.snp.updateConstraints { make in
                make.height.equalTo(self.webView.scrollView.contentSize.height)
            }
            self.heightChangedBlock?(self.webView.scrollView.contentSize.height)
        }
    }

    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "heightChanged",
              let height = message.body as? CGFloat else { return }

        // 防止死循环刷新
        if abs(height - lastHeight) < 1 { return }

        lastHeight = height
        heightChangedBlock?(height)
        debugPrint("LBLog webview userContentController is \(height)")
    }

    // MARK: - Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        heightChangedBlock = nil
    }
}
