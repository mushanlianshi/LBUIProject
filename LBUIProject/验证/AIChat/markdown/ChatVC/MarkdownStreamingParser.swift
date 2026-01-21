import Foundation
import Down
import Highlightr
import UIKit

final class LBMarkdownStreamingParser {
    private let downStyler: DownStyler
    private let highlightr: Highlightr?

    init() {
        // Down styler - use default or custom CSS-like styling
        self.downStyler = DownStyler()
        self.highlightr = Highlightr()
        self.highlightr?.setTheme(to: "atom-one-light") // 或 dark
    }

    /// 将一个 markdown 片段解析成 NSAttributedString（包含代码高亮）
    /// 注意：片段可能为普通文本，也可能包含完整或不完整的 code fence
    func attributedFromMarkdownChunk(_ chunk: String, baseFont: UIFont) -> NSAttributedString {
        // Strategy:
        // 1. Split chunk into segments: normal markdown vs fenced code blocks
        // 2. For normal segments, use Down to produce attributed
        // 3. For fenced code segments use Highlightr to syntax highlight then wrap in attributed

        let result = NSMutableAttributedString()

        // normal markdown -> use Down
        if let att = try? Down(markdownString: chunk).toAttributedString(.default, stylesheet: nil) {
            // ensure base font
//            let mutable = NSMutableAttributedString(attributedString: att)
//            mutable.addAttribute(.font, value: baseFont, range: NSRange(location: 0, length: mutable.length))
            result.append(att)
        } else {
            result.append(NSAttributedString(string: chunk, attributes: [.font: baseFont]))
        }
        return result
        
        
        let segments = Self.splitIntoSegments(chunk) // returns array of (isCodeBlock, language, content)
        for seg in segments {
            if seg.isCode {
                // highlight code
                if let highlighted = self.highlightCode(seg.content, language: seg.language, baseFont: baseFont) {
                    result.append(highlighted)
                } else {
                    // fallback to monospaced attributed
                    let attr = NSAttributedString(string: seg.content, attributes: [.font: UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)])
                    result.append(attr)
                }
            } else {
                // normal markdown -> use Down
                if let att = try? Down(markdownString: seg.content).toAttributedString(.default, stylesheet: nil) {
                    // ensure base font
                    let mutable = NSMutableAttributedString(attributedString: att)
                    mutable.addAttribute(.font, value: baseFont, range: NSRange(location: 0, length: mutable.length))
                    result.append(mutable)
                } else {
                    result.append(NSAttributedString(string: seg.content, attributes: [.font: baseFont]))
                }
            }
        }

        return result
    }

    private func highlightCode(_ code: String, language: String?, baseFont: UIFont) -> NSAttributedString? {
        guard let highlightr = highlightr else { return nil }
        highlightr.theme.setCodeFont(UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular))
        let lang = language ?? "plaintext"
        if let highlighted = highlightr.highlight(code, as: lang) {
            return highlighted
        }
        return nil
    }

    // Simple parser to split chunk into code and normal segments
    // Returns: array of (isCode, language, content)
    private static func splitIntoSegments(_ text: String) -> [(isCode: Bool, language: String?, content: String)] {
        // This is a pragmatic splitter. It handles fenced code blocks ```lang\n...\n```
        var out: [(Bool, String?, String)] = []
        let pattern = "(```[\\s\\S]*?```)" // whole fenced block
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return [(false, nil, text)]
        }
        var last = text.startIndex
        let ns = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: ns.length))
        var prevEnd = 0
        for m in matches {
            let range = m.range(at: 1)
            if range.location > prevEnd {
                let prefixRange = NSRange(location: prevEnd, length: range.location - prevEnd)
                let prefix = ns.substring(with: prefixRange)
                out.append((false, nil, prefix))
            }
            let block = ns.substring(with: range)
            // parse language after ```
            // example: ```swift\ncode\n```
            var lang: String? = nil
            if let firstLineRange = block.range(of: "\n") {
                let firstLine = String(block[block.startIndex..<firstLineRange.lowerBound])
                // firstLine contains ```lang or ```
                if firstLine.hasPrefix("```") {
                    let idx = firstLine.index(firstLine.startIndex, offsetBy: 3)
                    let langPart = firstLine[idx...].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !langPart.isEmpty { lang = String(langPart) }
                }
            }
            // strip leading ```lang\n and trailing ```
            var content = block
            // remove leading ```
            if content.hasPrefix("```") {
                if let startNewline = content.range(of: "\n") {
                    content = String(content[startNewline.lowerBound...])
                } else {
                    content = ""
                }
            }
            // remove trailing ```
            if content.hasSuffix("```") {
                content = String(content.dropLast(3))
            }
            out.append((true, lang, content))
            prevEnd = range.location + range.length
        }
        if prevEnd < ns.length {
            let suffixRange = NSRange(location: prevEnd, length: ns.length - prevEnd)
            let suffix = ns.substring(with: suffixRange)
            out.append((false, nil, suffix))
        }
        return out
    }
}
