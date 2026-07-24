import Foundation

/// Markdown 预处理器（轻量扩展点）。
///
/// 真正的解析 / 表格 / 代码高亮 / 公式渲染已全部交给前端
/// `marked` + `highlight.js` + `KaTeX` 在 WKWebView 中完成，
/// 本类只负责在文本交给 WebView 之前做必要的归一化。
///
/// 当前为透传实现，保留为后续扩展（例如清洗某些非标准标记）的入口。
final class LBMarkdownParser {

    static let shared = LBMarkdownParser()

    private init() {}

    /// 预处理：在交给前端渲染前对 markdown 文本做归一化。
    /// - Parameter markdown: 原始 markdown 文本
    /// - Returns: 处理后的文本（当前原样返回）
    func preprocess(_ markdown: String) -> String {
        markdown
    }
}
