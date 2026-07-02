import UIKit
import Down

/// Markdown renderer using Down (SPM) — converts markdown to NSAttributedString
final class LBSPMStreamMarkdownRenderer {
    let baseFont: UIFont
    let baseTextColor: UIColor

    init(baseFont: UIFont = .systemFont(ofSize: 16),
         baseTextColor: UIColor = .black) {
        self.baseFont = baseFont
        self.baseTextColor = baseTextColor
    }

    func render(_ markdown: String) -> NSMutableAttributedString {
        guard !markdown.isEmpty else { return NSMutableAttributedString() }

        let down = Down(markdownString: markdown)
        let result = (try? down.toAttributedString()) ?? NSAttributedString(string: markdown)
        let mutable = NSMutableAttributedString(attributedString: result)
        // Apply base font & color where not already styled by Down
        let fullRange = NSRange(location: 0, length: mutable.length)
        mutable.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            if value == nil {
                mutable.addAttribute(.font, value: baseFont, range: range)
            }
        }
        return mutable
    }
}

// MARK: - Streaming Buffer (throttle)

actor LBSPMStreamBuffer {
    private var buffer = ""
    private var flushTask: Task<Void, Never>?

    func append(_ token: String, nanos: UInt64 = 40_000_000, flush: @escaping (String) -> Void) {
        buffer.append(token)
        flushTask?.cancel()
        flushTask = Task {
            try? await Task.sleep(nanoseconds: nanos)
            guard !Task.isCancelled else { return }
            let out = buffer
            buffer = ""
            await MainActor.run {
                flush(out)
            }
        }
    }

    func forceFlush(flush: @escaping (String) -> Void) {
        flushTask?.cancel()
        let out = buffer
        buffer = ""
        if !out.isEmpty {
            Task { @MainActor in
                flush(out)
            }
        }
    }
}
