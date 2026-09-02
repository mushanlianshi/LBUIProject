//
//  UITextField+LBFormatter.swift
//  LBUIProject
//
//  Created by liu bin on 2023/4/4.
//

import Foundation
import UIKit

@propertyWrapper
public struct BLTCategoryStore<T>{
    private let object: Any
    private let key: UnsafeRawPointer
    private let defaultValue: T
    private let policy: objc_AssociationPolicy
    
    init(object: Any, key: UnsafeRawPointer, defaultValue: T, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
        self.object = object
        self.key = key
        self.defaultValue = defaultValue
        self.policy = policy
    }
    
    public var wrappedValue: T {
        get{
            return (objc_getAssociatedObject(self, key) as? T) ?? defaultValue
        }
        
        set{
            objc_setAssociatedObject(object, key, newValue, policy)
        }
    }
}


private var _formatterWhiteSpaceKey: Void?
private var _lastTextKey: Void?
private var _lastFormatterTextKey: Void?

///处理textField格式化展示的  如银行卡每个4位展示空格的
extension UITextField{
    
    var formatterWhiteSpacing: Int{
        set{
            objc_setAssociatedObject(self, &_formatterWhiteSpaceKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            if newValue > 0 {
                self.addTarget(self, action: #selector(textChangeToFormatter(_:)), for: .editingChanged)
            }else{
                self.removeTarget(self, action: #selector(textChangeToFormatter(_:)), for: .editingChanged)
            }
        }
        get{
            return (objc_getAssociatedObject(self, &_formatterWhiteSpaceKey) as? Int) ?? 0
        }
    }
    
    private var lastText: String{
        set{
            objc_setAssociatedObject(self, &_lastTextKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get{
            return (objc_getAssociatedObject(self, &_lastTextKey) as? String) ?? ""
        }
    }
    
//    @BLTCategoryStore(object: self, key: &_lastFormatterTextKey, defaultValue: "", policy: .OBJC_ASSOCIATION_COPY_NONATOMIC)
    private var lastFormatterText: String?
    {
        set{
            objc_setAssociatedObject(self, &_lastFormatterTextKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }

        get{
            objc_getAssociatedObject(self, &_lastFormatterTextKey) as? String
        }
    }
    
    
    @objc private func textChangeToFormatter(_ textField: UITextField) {
        
        //1.每次把已经格式化好  或则未格式化好的字符串还原  重新格式化一遍
        textField.text = textField.text?.replacingOccurrences(of: " ", with: "")
        
        //2.开始格式化
        var formatterText = formatterTextToWhiteSpacing(textField.text ?? "")
        
        //3.兼容格式化失败就拿上次的格式化内容
        if formatterText == nil {
            formatterText = lastFormatterText
        }else{
            lastFormatterText = formatterText
        }
        
        //4. 格式化后的内容发生了变化  和原始内容不一样
        guard formatterText != textField.text else {
            lastText = textField.text ?? ""
            return
        }
        
        //5.把textfield的内容设置成格式化后的
        textField.text = formatterText
        
        //6.处理是删除还是输入光标的  如果lastText 为空 说明是没变化或则删完了  没必要处理了
        guard lastText.isEmpty == false else { return }
        
        DispatchQueue.main.async {
            [weak self] in
            //7.如果是输入
            if unwrapStringLength(textField.text) > unwrapStringLength(self?.lastText){
                self?.processInputText(textField, formatterText ?? "")
            }else{
                self?.processDeleteText(textField, formatterText ?? "")
            }
            self?.lastText = textField.text ?? ""
        }
    }
    
    
    private func formatterTextToWhiteSpacing(_ text: String) -> String?{
        guard let regex = try? NSRegularExpression.init(pattern: "(.{1,4})", options: []) else {
            return nil
        }
        let text = regex.stringByReplacingMatches(in: text, options: [], range: NSMakeRange(0, text.length), withTemplate: "$1 ")
        if text.length > 1 {
            return (text as? NSString)?.substring(to: text.length - 1)
        }
        return text
    }
    
    private func processInputText(_ textField: UITextField, _ formatterText: String){
        let textString: NSString = (textField.text as? NSString) ?? NSString()
        let lastTextRange = textString.range(of: lastText)
        let selectedRange = textField.selectedTextRange
        //如果长度是旧字符串的长度  位置是0 则是顺序输入 光标不变
        if lastTextRange.length == lastText.length, lastTextRange.location == 0 {
            print("LBLog 从前往后输入  光标不变")
        }else{
            //输入在空格前  输入后 光标后移两位
            let beginTextPosition = textField.beginningOfDocument
            let startPosition: UITextPosition = selectedRange?.start ?? UITextPosition.init()
            let endPosition: UITextPosition = selectedRange?.end ?? UITextPosition.init()
            
            let textLocation = textField.offset(from: beginTextPosition, to: startPosition)
            let textLength = textField.offset(from: startPosition, to: endPosition)
            
            print("LBLog 我在中间输入")
            textField.selectedTextRange = selectedRange
            
            if unwrapStringLength(formatterText) > 0 && ((formatterText as? NSString)?.substring(with: NSRange(location: textLocation - 1, length: 1)) == " ") {
                print("LBLog 已经点击了删除  并且前面是空格  自动跳过空格")
                let startPosition2 = self.position(from: beginTextPosition, offset: textLocation + 1) ?? UITextPosition()
                let endPosition2 = self.position(from: startPosition, offset: textLength + 1) ?? UITextPosition()
                textField.selectedTextRange = self .textRange(from: startPosition2, to: endPosition2)
            }
        }
    }
    
    private func processDeleteText(_ textField: UITextField, _ formatterText: String){
        let deleteRange = (lastText as? NSString)?.range(of: textField.text ?? "") ?? NSRange(location: 0, length: 0)
        let selectedRange = textField.selectedTextRange
        if deleteRange.length == textField.text?.length && deleteRange.location == 0{
            print("LBLog 从后往前删")
        }else{
            //输入在空格前  输入后 光标后移两位
            let beginTextPosition = textField.beginningOfDocument
            let startPosition: UITextPosition = selectedRange?.start ?? UITextPosition.init()
            let endPosition: UITextPosition = selectedRange?.end ?? UITextPosition.init()
            
            let textLocation = textField.offset(from: beginTextPosition, to: startPosition)
            let textLength = textField.offset(from: startPosition, to: endPosition)
            
            print("LBLog 删除中间数字或则 空格前面删")
            textField.selectedTextRange = selectedRange
            
            if unwrapStringLength(formatterText) > 0 && ((formatterText as? NSString)?.substring(with: NSRange(location: textLocation - 1, length: 1)) == " ") {
                print("LBLog 已经点击了删除  并且前面是空格  自动跳过空格")
                let startPosition2 = self.position(from: beginTextPosition, offset: textLocation - 1) ?? UITextPosition()
                let endPosition2 = self.position(from: startPosition, offset: textLength - 1) ?? UITextPosition()
                textField.selectedTextRange = self .textRange(from: startPosition2, to: endPosition2)
            }
        }
    }
    
}


func unwrapStringLength(_ text: String?) -> Int {
    return text?.length ?? 0
}
