//
//  LBATViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/11/20.
//

import UIKit

struct Mention {
    let userId: String
    let name: String        // 显示的名字
}

class LBATViewController: UIViewController,UITextViewDelegate {
    
    private lazy var atNameList = ["张三", "李四", "王五", "麻子", "狗蛋"]
    
    private var selectIndex = 0
    
    
    lazy var textView: UITextView = {
       let tv = UITextView()
        tv.backgroundColor = .gray.withAlphaComponent(0.5)
        tv.delegate = self
        return tv
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "at功能"
        self.view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(15)
            make.height.equalTo(120)
        }
    }
    
    private func selectNameInsertMention() {
        let index = self.selectIndex % atNameList.count
        let name = atNameList[index]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            [weak self] in
            self?.insertMention(Mention(userId: "\(index) - \(name)", name: name))
        }
    }
    
    func insertMention(_ mention: Mention) {
        let textView = self.textView
        let name = "@\(mention.name)"
        let attr = NSMutableAttributedString(string: "\(name) ",
             attributes: [
                .foregroundColor: UIColor.systemBlue,
                .backgroundColor: UIColor.clear
             ])

        let mentionKey = NSAttributedString.Key("MentionAttribute")
        attr.addAttribute(mentionKey, value: mention.userId,
                          range: NSRange(location: 0, length: name.count))

        let current = NSMutableAttributedString(attributedString: textView.attributedText)
        let selectedRange = textView.selectedRange
        current.replaceCharacters(in: selectedRange, with: attr)

        textView.attributedText = current

        // 让光标停在末尾
        textView.selectedRange = NSRange(location: selectedRange.location + attr.length, length: 0)
    }
    
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {

        // 监听到用户输入了 @
        if text == "@" {
            selectNameInsertMention()
            
        }
        
        let mentionKey = NSAttributedString.Key("MentionAttribute")

        // 只有在用户按删除键且删除的是空文本时
        if text.isEmpty, range.length == 1 {
            
            // 检查当前位置是否在 mention 里
            guard let full = textView.attributedText else {
                return false
            }
            let attrs = full.attributes(at: range.location, effectiveRange: nil)

            if let _ = attrs[mentionKey] {
                // 获取整个 mention 的 effective range
                var effRange = NSRange(location: 0, length: 0)
                _ = full.attribute(mentionKey, at: range.location, longestEffectiveRange: &effRange, in: NSRange(location: 0, length: full.length))

                // 删除整个 mention
                let mutable = NSMutableAttributedString(attributedString: full)
                mutable.deleteCharacters(in: effRange)
                textView.attributedText = mutable
                textView.selectedRange = NSRange(location: effRange.location, length: 0)
                return false
            }
        }

        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        let mentionKey = NSAttributedString.Key("MentionAttribute")
        let pos = textView.selectedRange.location
        let text = textView.attributedText
        guard let text = text, pos < text.length else { return }
        if pos < text.length {
            let attrs = text.attributes(at: pos, effectiveRange: nil)
            if attrs[mentionKey] != nil {
                // 将光标移到该 mention 的后面
                var eff = NSRange()
                _ = text.attribute(mentionKey, at: pos, longestEffectiveRange: &eff, in: NSRange(location: 0, length: text.length))

                textView.selectedRange = NSRange(location: eff.location + eff.length, length: 0)
            }
        }
    }
    
    func extractMentions() -> [(range: NSRange, userId: String)] {
        guard let text = textView.attributedText else {
            return []
        }
        let mentionKey = NSAttributedString.Key("MentionAttribute")
        var result: [(NSRange, String)] = []
        text.enumerateAttribute(mentionKey, in: NSRange(location: 0, length: text.length), options: []) { value, range, _ in
            if let userId = value as? String {
                result.append((range, userId))
            }
        }

        return result
    }
}
