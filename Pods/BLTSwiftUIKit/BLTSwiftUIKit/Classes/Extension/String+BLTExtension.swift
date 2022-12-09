//
//  NSString+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2021/12/24.
//

import UIKit
extension String: BLTNameSpaceCompatibleValue{
}

extension BLTNameSpace where Base == String{
    public static let cancelTitle = "取消"
    public static let sureTitle = "确定"
    public static let IKnow = "我知道了"
    public static let alertTipTitle = "温馨提示"
    
    public func toInt() -> Int? {
        return Int(base)
    }
    
    public func rangeOfAll() -> NSRange{
        return NSRange(location: 0, length: base.count)
    }
    
    public func subscriptToIndex(to index: Int) -> String? {
        var realIndex = index
        if index >= base.count {
            realIndex = base.count
        }
        let endIndex = base.index(base.startIndex, offsetBy: realIndex)
        return String(base[base.startIndex ..< endIndex])
    }
    
    public func subscriptFromIndex(from index: Int) -> String? {
        if index >= base.count {
            return nil
        }
        let startIndex = base.index(base.startIndex, offsetBy: index)
        return String(base[startIndex ..< base.endIndex])
    }
    
//    trim去除字符串的
    public func trimStringWithText(_ text: String? = nil) -> String {
        let characterSet = CharacterSet(charactersIn: text ?? " ")
        return base.trimmingCharacters(in: characterSet)
    }
    
    public func widthOfFont(font: UIFont) -> CGFloat{
        return self.sizeOfFont(font: font, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width
    }
    
    public func heightOfFont(font: UIFont, maxWidth: CGFloat, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGFloat{
        return self.sizeOfFont(font: font, size: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)).height
    }
    
    public func sizeOfFont(font: UIFont, size: CGSize, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGSize {
        if self.base.isEmpty {
            return .zero
        }
        var attributeDic = [NSAttributedString.Key : Any]()
        attributeDic[.font] = font
        
        if lineBreakMode != .byWordWrapping{
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineBreakMode = lineBreakMode
            attributeDic[.paragraphStyle] = paragraph
        }
        
        return self.base.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributeDic, context: nil).size
    }
    
    
    ///是不是0金额
    public func isZeroMoney() -> Bool{
        if self.base.isEmpty{
            return true
        }
        let number = NSDecimalNumber.init(string: self.base)
        if number == NSDecimalNumber.zero{
            return true
        }
        
        return false
    }
    
}

// MARK: 富文本的分类
extension BLTNameSpace where Base == String{
    
    public func paragraphSpacingAttributeText(paragraphSpacing: CGFloat, lineSpacing: CGFloat = 0) -> NSMutableAttributedString {
        let attributeString = NSMutableAttributedString.init(string: self.base)
        let style = NSMutableParagraphStyle()
        style.paragraphSpacing = paragraphSpacing
        style.lineSpacing = lineSpacing
        attributeString.addAttribute(.paragraphStyle, value: style, range: self.rangeOfAll())
        return attributeString
    }
    
    public func highLightText(highArray: [String]?, attrs: [NSAttributedString.Key : Any]) -> NSMutableAttributedString? {
        guard let array = highArray else { return nil }
        let attributeString = NSMutableAttributedString.init(string: self.base)
        let nsString = self.base as NSString
        array.forEach { highLightText in
            let range = nsString.range(of: highLightText)
            attributeString.addAttributes(attrs, range: range)
        }
        return attributeString
    }
    
    public func middlelLineText() -> NSMutableAttributedString? {
        let attributeString = NSMutableAttributedString.init(string: self.base)
        let allRange = (self.base as NSString).range(of: self.base)
        attributeString.addAttributes([.strikethroughStyle : 1], range: allRange)
        return attributeString
    }
    
}
