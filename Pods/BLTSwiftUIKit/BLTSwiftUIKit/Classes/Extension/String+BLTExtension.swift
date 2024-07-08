//
//  NSString+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2021/12/24.
//

import UIKit

extension String: BLTNameSpaceCompatibleValue{
    public func toPrintBLTLog(_ prefix: String?) {
        
    }
    
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
    
    public func rangeOfString(_ text: String) -> NSRange{
        return (base as NSString).range(of: text)
    }
    
    ///截取字符串到from
    public func subString(from: Int) -> String{
        return self.subString(from: from, to: base.count)
    }
    
    ///截取字符串 从to开始截取到结尾
    public func subString(to: Int) -> String{
        return self.subString(from: 0, to: to)
    }
    
    public func subString(from: Int, to: Int) -> String{
        if from > base.count{
            return ""
        }
        
        var endIndex = base.endIndex
        if to < base.count{
            endIndex = base.index(endIndex, offsetBy: to - base.count )
        }
        let startIndex = base.index(base.startIndex, offsetBy: from)
        return String(base[ startIndex ..< endIndex])
    }
    
    ///截取字符串startIndex - endIndex之间
    public func subscriptInRange(_ startIndex: Int, _ endIndex: Int) -> String? {
        if startIndex > endIndex || startIndex >= base.count || endIndex > base.count {
            return nil
        }
        
        let sIndex = base.index(base.startIndex, offsetBy: startIndex)
        let eIndex = base.index(sIndex, offsetBy: endIndex - startIndex)
        return String(base[sIndex ..< eIndex])
    }
    
    ///trim去除字符串的 默认是去除空格
    public func trimStringWithText(_ text: String? = nil) -> String {
        let characterSet = CharacterSet(charactersIn: text ?? " ")
        return base.trimmingCharacters(in: characterSet)
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
    
    
    public static func randomIntString(length: Int) -> String{
        var result = ""
        var list = [Int](0...9)
        for _ in 1...length {
            list.shuffle()
            result.append(String(list.first!))
        }
        return result
    }
    
    
}



//计算文本宽高的
extension BLTNameSpace where Base == String{
    public func widthOfFont(font: UIFont) -> CGFloat{
        return self.sizeOfFont(font: font, size: CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)).width + 1.0
    }
    
    public func heightOfFont(font: UIFont, maxWidth: CGFloat, lineBreakMode: NSLineBreakMode = .byWordWrapping) -> CGFloat{
        return self.sizeOfFont(font: font, size: CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)).height + 1.0
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
        
        var resultSize = self.base.boundingRect(with: size, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributeDic, context: nil).size
        resultSize.width += 1.0
        resultSize.height += 1.0
        return resultSize
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
