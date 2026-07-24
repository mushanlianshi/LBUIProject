import UIKit

// MARK: - UIFont extension

extension UIFont {
    /// 追加 symbolic traits（如同时 bold + italic）
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        if let descriptor = fontDescriptor.withSymbolicTraits(fontDescriptor.symbolicTraits.union(traits)) {
            return UIFont(descriptor: descriptor, size: 0)
        }
        return self
    }

    var bold: UIFont { withTraits(.traitBold) }
    var italic: UIFont { withTraits(.traitItalic) }
    var boldItalic: UIFont { withTraits([.traitBold, .traitItalic]) }
}

// MARK: - MarkdownStyle

struct MarkdownStyle {
    // Base
    let baseFont: UIFont
    let baseColor: UIColor

    // Headings (index 0 = h1 … 5 = h6)
    let headingFonts: [UIFont]
    let headingColor: UIColor

    // Inline
    let boldFont: UIFont
    let italicFont: UIFont
    let boldItalicFont: UIFont
    let codeFont: UIFont
    let codeBackgroundColor: UIColor
    let codeTextColor: UIColor
    let linkColor: UIColor
    let strikethroughColor: UIColor

    // Code block
    let codeBlockFont: UIFont
    let codeBlockBackgroundColor: UIColor
    let codeBlockTextColor: UIColor

    // Quote
    let quoteColor: UIColor
    let quoteBarColor: UIColor
    let quoteBackgroundColor: UIColor

    // List
    let listIndent: CGFloat

    // Table
    let tableFont: UIFont

    // Spacing
    let paragraphSpacing: CGFloat
    let lineSpacing: CGFloat
    let blockSpacing: CGFloat

    static var `default`: MarkdownStyle {
        let base = UIFont.systemFont(ofSize: 16)
        let code = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        return MarkdownStyle(
            baseFont: base,
            baseColor: .label,
            headingFonts: [
                .systemFont(ofSize: 28, weight: .bold),
                .systemFont(ofSize: 24, weight: .bold),
                .systemFont(ofSize: 20, weight: .bold),
                .systemFont(ofSize: 18, weight: .bold),
                .systemFont(ofSize: 16, weight: .bold),
                .systemFont(ofSize: 16, weight: .semibold),
            ],
            headingColor: .label,
            boldFont: base.bold,
            italicFont: base.italic,
            boldItalicFont: base.boldItalic,
            codeFont: code,
            codeBackgroundColor: UIColor(white: 0.90, alpha: 1),
            codeTextColor: UIColor(white: 0.15, alpha: 1),
            linkColor: .systemBlue,
            strikethroughColor: .secondaryLabel,
            codeBlockFont: code,
            codeBlockBackgroundColor: UIColor(white: 0.95, alpha: 1),
            codeBlockTextColor: UIColor(white: 0.12, alpha: 1),
            quoteColor: .secondaryLabel,
            quoteBarColor: UIColor(white: 0.78, alpha: 1),
            quoteBackgroundColor: UIColor(white: 0.96, alpha: 1),
            listIndent: 20,
            tableFont: UIFont.monospacedSystemFont(ofSize: 13, weight: .regular),
            paragraphSpacing: 8,
            lineSpacing: 3,
            blockSpacing: 10
        )
    }
}
