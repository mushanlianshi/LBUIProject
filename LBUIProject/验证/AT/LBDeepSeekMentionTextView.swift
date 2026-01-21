import UIKit

class LBDeepSeekMentionTextView: UITextView {
    
    // 自定义属性键
    private struct MentionAttributes {
        static let mentionUser = NSAttributedString.Key("mentionUser")
        static let userId = NSAttributedString.Key("userId")
    }
    
    // 字体设置
    private var originalFont: UIFont {
        return self.font ?? UIFont.systemFont(ofSize: 16)
    }
    
    private var originalTextColor: UIColor {
        return self.textColor ?? UIColor.label
    }
    
    // @文本的属性
    private var mentionAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: UIColor.systemBlue,
            .font: originalFont, // 使用原有字体
            .backgroundColor: UIColor.systemBlue.withAlphaComponent(0.1),
            MentionAttributes.mentionUser: true
        ]
    }
    
    // 普通文本属性
    private var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: originalTextColor,
            .font: originalFont
        ]
    }
    
    private var mentionRanges: [NSRange] = []
    private var mentionUsers: [String: String] = [:]
    
    override var font: UIFont? {
        didSet {
            resetTypingAttributes()
        }
    }
    
    override var textColor: UIColor? {
        didSet {
            resetTypingAttributes()
        }
    }
}

// MARK: - 添加@用户功能
extension LBDeepSeekMentionTextView {
    
    /// 添加@用户
    func addMention(userName: String, userId: String) {
        let mentionText = "@\(userName) "
        let attributedMention = NSMutableAttributedString(string: mentionText)
        
        // 设置@文本的属性
        var attributes = mentionAttributes
        attributes[MentionAttributes.userId] = userId
        attributedMention.addAttributes(attributes, range: NSRange(location: 0, length: mentionText.count))
        
        // 获取当前文本
        let currentAttributedText = NSMutableAttributedString(attributedString: self.attributedText)
        let selectedRange = self.selectedRange
        
        // 插入@文本
        currentAttributedText.insert(attributedMention, at: selectedRange.location)
        
        // 计算新的@范围
        let newMentionRange = NSRange(location: selectedRange.location, length: mentionText.count)
        
        // 更新已有的@范围
        updateExistingMentionRanges(after: selectedRange.location, shiftBy: mentionText.count)
        
        // 添加新的@范围
        mentionRanges.append(newMentionRange)
        mentionUsers[rangeString(newMentionRange)] = userId
        
        // 更新文本
        self.attributedText = currentAttributedText
        
        // 移动光标
        let newSelectedRange = NSRange(location: selectedRange.location + mentionText.count, length: 0)
        self.selectedRange = newSelectedRange
        
        resetTypingAttributes()
    }
    
    private func updateExistingMentionRanges(after location: Int, shiftBy length: Int) {
        mentionRanges = mentionRanges.map { existingRange in
            if existingRange.location >= location {
                return NSRange(location: existingRange.location + length, length: existingRange.length)
            }
            return existingRange
        }
        
        // 更新用户信息存储
        var updatedUsers: [String: String] = [:]
        mentionRanges.forEach { range in
            let oldRangeString = rangeString(NSRange(location: range.location - length, length: range.length))
            if let userId = mentionUsers[oldRangeString] {
                updatedUsers[rangeString(range)] = userId
            }
        }
        mentionUsers = updatedUsers
    }
}

// MARK: - 删除处理
extension LBDeepSeekMentionTextView {
    
    func handleDeleteInRange(_ range: NSRange) -> Bool {
        if range.length == 1 {
            return handleSingleCharacterDeletion(in: range)
        } else if range.length > 1 {
            return handleMultipleCharactersDeletion(in: range)
        }
        return true
    }
    
    private func handleSingleCharacterDeletion(in range: NSRange) -> Bool {
        let deleteLocation = range.location
        
        // 查找包含删除位置的功能性@
        for mentionRange in mentionRanges {
            if NSLocationInRange(deleteLocation, mentionRange) && isFunctionalMention(at: mentionRange) {
                deleteEntireMention(mentionRange)
                return false
            }
        }
        
        updateMentionRangesAfterDeletion(in: range)
        return true
    }
    
    private func handleMultipleCharactersDeletion(in range: NSRange) -> Bool {
        let affectedMentions = findMentionsInRange(range)
        
        if !affectedMentions.isEmpty {
            deleteMentions(affectedMentions)
            return false
        }
        
        updateMentionRangesAfterDeletion(in: range)
        return true
    }
    
    private func deleteEntireMention(_ range: NSRange) {
        let mutableString = NSMutableAttributedString(attributedString: self.attributedText)
        mutableString.deleteCharacters(in: range)
        
        mentionRanges.removeAll { $0 == range }
        mentionUsers.removeValue(forKey: rangeString(range))
        
        updateMentionRangesAfterDeletion(in: range)
        
        self.attributedText = mutableString
        self.selectedRange = NSRange(location: range.location, length: 0)
        resetTypingAttributes()
    }
    
    private func deleteMentions(_ ranges: [NSRange]) {
        let mutableString = NSMutableAttributedString(attributedString: self.attributedText)
        let sortedRanges = ranges.sorted { $0.location > $1.location }
        
        sortedRanges.forEach { range in
            mutableString.deleteCharacters(in: range)
            mentionRanges.removeAll { $0 == range }
            mentionUsers.removeValue(forKey: rangeString(range))
            updateMentionRangesAfterDeletion(in: range)
        }
        
        self.attributedText = mutableString
        resetTypingAttributes()
    }
}

// MARK: - 辅助方法
extension LBDeepSeekMentionTextView {
    
    private func isFunctionalMention(at range: NSRange) -> Bool {
        guard range.location < self.attributedText.length else { return false }
        return self.attributedText.attribute(MentionAttributes.mentionUser, at: range.location, effectiveRange: nil) != nil
    }
    
    private func findMentionsInRange(_ range: NSRange) -> [NSRange] {
        return mentionRanges.filter { mentionRange in
            NSIntersectionRange(mentionRange, range).length > 0 && isFunctionalMention(at: mentionRange)
        }
    }
    
    private func updateMentionRangesAfterDeletion(in deletedRange: NSRange) {
        var updatedRanges: [NSRange] = []
        var updatedUsers: [String: String] = [:]
        
        mentionRanges.forEach { existingRange in
            if existingRange.location > deletedRange.location {
                let shift = min(existingRange.location - deletedRange.location, deletedRange.length)
                let newLocation = existingRange.location - shift
                let newRange = NSRange(location: newLocation, length: existingRange.length)
                
                if newLocation + existingRange.length <= self.attributedText.length {
                    updatedRanges.append(newRange)
                    if let userId = mentionUsers[rangeString(existingRange)] {
                        updatedUsers[rangeString(newRange)] = userId
                    }
                }
            } else {
                updatedRanges.append(existingRange)
                if let userId = mentionUsers[rangeString(existingRange)] {
                    updatedUsers[rangeString(existingRange)] = userId
                }
            }
        }
        
        mentionRanges = updatedRanges
        mentionUsers = updatedUsers
    }
    
    private func resetTypingAttributes() {
        self.typingAttributes = normalAttributes
    }
    
    private func rangeString(_ range: NSRange) -> String {
        return "\(range.location)-\(range.length)"
    }
    
    func getMentionedUserIds() -> [String] {
        return Array(mentionUsers.values)
    }
}
