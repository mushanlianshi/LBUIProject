//
//  LBATTextView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/11/21.
//

import UIKit

class LBMentionTextView: UITextView, UITextViewDelegate {

    private let mentionKey = NSAttributedString.Key("MentionAttribute")
    private var atInsertIndex: Int?
    private let defaultFont = UIFont.systemFont(ofSize: 16)

    var onMentionTrigger: ((_ rect: CGRect) -> Void)?
    var onMentionInsert: ((_ query: String?) -> Void)?

    override var canBecomeFirstResponder: Bool { true }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        typingAttributes = defaultTypingAttributes
    }
    
    // MARK: - Designated initializer
        override init(frame: CGRect, textContainer: NSTextContainer?) {
            super.init(frame: frame, textContainer: textContainer)
            self.delegate = self
            typingAttributes = defaultTypingAttributes
        }

        // MARK: - For storyboard / xib
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            self.delegate = self
            typingAttributes = defaultTypingAttributes
        }

    
    private var defaultTypingAttributes: [NSAttributedString.Key: Any] {
        [.font: defaultFont, .foregroundColor: UIColor.label]
    }

    // MARK: - At Trigger
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if textView.markedTextRange != nil { return true }

        let full = textView.attributedText.string as NSString

        // 删除：整段 mention 删除
        if text.isEmpty, range.length == 1, let attr = textView.attributedText {
            return handleDelete(textView: textView, range: range)
//            if range.location < attr.length,
//               attr.attribute(mentionKey, at: range.location, effectiveRange: nil) != nil {
//
//                let replaceRange = effectiveMentionRange(at: range.location)
//                let mut = NSMutableAttributedString(attributedString: attr)
//                mut.replaceCharacters(in: replaceRange, with: "")
//                textView.attributedText = mut
//                textView.selectedRange = NSRange(location: replaceRange.location, length: 0)
//                return false
//            }
        }

        // 输入 @ 时触发
        if text == "@" && range.length == 0 {
            atInsertIndex = range.location
            let r = caretRect(for: range.location)
            onMentionTrigger?(r)
        }

        return true
    }

    // MARK: - 光标保护（阻止进入 mention）
    func textViewDidChangeSelection(_ textView: UITextView) {
        let pos = textView.selectedRange.location
        guard pos < textView.attributedText.length else { return }

        
        if let attr = textView.attributedText, attr.attribute(mentionKey, at: pos, effectiveRange: nil) != nil {
            // 光标落在 mention 内 → 移到 mention 后
            let range = effectiveMentionRange(at: pos)
            textView.selectedRange = NSRange(location: range.location + range.length, length: 0)
        }
    }

    private func effectiveMentionRange(at index: Int) -> NSRange {
        let attr = self.attributedText
        var range = NSRange(location: 0, length: 0)
        attr?.attribute(mentionKey, at: index, effectiveRange: &range)
        return range
    }

    private func caretRect(for index: Int) -> CGRect {
        let pos = position(from: beginningOfDocument, offset: index) ?? endOfDocument
        return caretRect(for: pos)
    }

    
    // MARK: - 删除逻辑
        func handleDelete(textView: UITextView, range: NSRange) -> Bool {
            guard let full = textView.attributedText else { return true }
            let location = range.location
            if location == 0 { return true }
            
            let checkIndex = max(location - 1, 0)
            var effectiveRange = NSRange(location: 0, length: 0)
            
            guard full.attribute(mentionKey, at: checkIndex, effectiveRange: &effectiveRange) != nil else {
                return true
            }
            
            // 扩展左边
            while effectiveRange.location > 0 {
                let prevIndex = effectiveRange.location - 1
                var leftRange = NSRange(location: 0, length: 0)
                if full.attribute(mentionKey, at: prevIndex, effectiveRange: &leftRange) != nil {
                    let newLocation = leftRange.location
                    let newEnd = effectiveRange.location + effectiveRange.length
                    effectiveRange.location = newLocation
                    effectiveRange.length = newEnd - newLocation
                } else {
                    break
                }
            }
            
            // 扩展右边
            while effectiveRange.location + effectiveRange.length < full.length {
                let nextIndex = effectiveRange.location + effectiveRange.length
                var rightRange = NSRange(location: 0, length: 0)
                if full.attribute(mentionKey, at: nextIndex, effectiveRange: &rightRange) != nil {
                    let newEnd = rightRange.location + rightRange.length
                    effectiveRange.length = newEnd - effectiveRange.location
                } else {
                    break
                }
            }
            
            // 左侧 @ 包含进删除
            if effectiveRange.location > 0 {
                let prevCharRange = NSRange(location: effectiveRange.location - 1, length: 1)
                let prevChar = (full.string as NSString).substring(with: prevCharRange)
                if prevChar == "@" {
                    effectiveRange.location -= 1
                    effectiveRange.length += 1
                }
            }
            
            // 右侧空格可选删除
            let afterIndex = effectiveRange.location + effectiveRange.length
            if afterIndex < full.length {
                let nextCharRange = NSRange(location: afterIndex, length: 1)
                let nextChar = (full.string as NSString).substring(with: nextCharRange)
                if nextChar == " " {
                    effectiveRange.length += 1
                }
            }
            
            // 删除
            let mutable = NSMutableAttributedString(attributedString: full)
            mutable.deleteCharacters(in: effectiveRange)
            textView.attributedText = mutable
            textView.selectedRange = NSRange(location: effectiveRange.location, length: 0)
            textView.typingAttributes = defaultTypingAttributes
            return false
        }
    
    private func handleDelete2(textView: UITextView, range: NSRange) -> Bool {

        guard let full = textView.attributedText else{
            return false
        }
        let location = range.location
        debugPrint("LBLog location is \(location)")
        // 正常删除
        if location == 0 { return true }

        // 检查光标前一个字符是不是 mention
        var effectiveRange = NSRange(location: 0, length: 0)
        let checkIndex = max(location - 1, 0)
        let attr = full.attribute(
            mentionKey,
            at: checkIndex,
            effectiveRange: &effectiveRange
        )

        // 不是 mention，正常删
        if attr == nil { return true }

        // 是 mention -> 整段删除
        let mutable = NSMutableAttributedString(attributedString: full)
        mutable.deleteCharacters(in: effectiveRange)

        textView.attributedText = mutable
        textView.selectedRange = NSRange(location: effectiveRange.location, length: 0)
        return false // 已处理
    }
    
    // MARK: - 插入 Mention
    func insertMention(_ mention: Mention) {
        guard let tv = self as UITextView? else { return }

        let cursor = tv.selectedRange.location
        let start = atInsertIndex ?? cursor
        let full = NSMutableAttributedString(attributedString: tv.attributedText)

        // Replace: @查询文本 → @张三
        let replaceRange = NSRange(location: start, length: cursor - start)

        // mention styled
        let name = "@\(mention.name)"
        let mentionAttr = NSMutableAttributedString(
            string: name,
            attributes: [
                .font: defaultFont,
                .foregroundColor: UIColor.systemBlue
            ]
        )
        mentionAttr.addAttribute(mentionKey, value: mention.userId, range: NSRange(location: 0, length: name.count))

        // 插入普通空格使后续文字保持正常颜色
        let space = NSAttributedString(string: " ", attributes: defaultTypingAttributes)

        let insert = NSMutableAttributedString()
        insert.append(mentionAttr)
        insert.append(space)

        full.replaceCharacters(in: replaceRange, with: insert)

        tv.attributedText = full
        tv.selectedRange = NSRange(location: replaceRange.location + insert.length, length: 0)
        tv.typingAttributes = defaultTypingAttributes
        
        
        debugPrintRuns(tv.attributedText)
        atInsertIndex = nil
    }
    
    func debugPrintRuns(_ attr: NSAttributedString) {
        print("========== Attributed String Runs ==========")
        attr.enumerateAttributes(in: NSRange(location: 0, length: attr.length),
                                 options: []) { attributes, range, _ in
            let substring = attr.string as NSString
            let text = substring.substring(with: range)
            print("Range: \(range), Text: [\(text)]")
            print("Attributes:")
            for (key, value) in attributes {
                print("   \(key.rawValue): \(value)")
            }
            print("-------------------------------------------")
        }
        print("============================================\n")
    }
}
