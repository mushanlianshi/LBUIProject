//
//  LBTextView.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/11.
//

import Foundation
import UIKit
import BLTSwiftUIKit


@objc public protocol LBTextViewDelegate: UITextViewDelegate {
//    是否点了返回
    func lb_textViewShouldReturn(textView: LBTextView) -> Bool
//    文本发送了变化
    func lb_textViewDidChangeText(textView: LBTextView)
//    组织文本发生变化  超过长度限制了
    func lb_textViewPreventTextChange(textView: LBTextView, replacementText: String?)
//    高度发生了变化
    func lb_textViewHeightDidChange(textView: LBTextView, height: CGFloat)
}

public extension LBTextViewDelegate{
    func lb_textViewShouldReturn(textView: LBTextView) -> Bool{ return true }
    //    文本发送了变化
    func lb_textViewDidChangeText(textView: LBTextView){}
    //    组织文本发生变化  超过长度限制了
    func lb_textViewPreventTextChange(textView: LBTextView, replacementText: String?){}
    //    高度发生了变化
    func lb_textViewHeightDidChange(textView: LBTextView){}
}


// open 修饰可以继承  public不可以继承
open class LBTextView: UITextView{
// 通过setText setAttributeText等方法修改文字时  是否触发textView： shouldChangeTextInRange  textViewDidChange方法
    @objc public var shouldResponseAPITextChange = true
    @objc public weak var customDelegate: LBTextViewDelegate?
    
    @objc public var supportEmoji = false
    
//    最大长度
    @objc public var maxTextLength = Int.max
    
    @objc public var placeHolder: String?{
        didSet{
            placeHolderLab.text = placeHolder
            refreshPlaceHolderLabelState()
        }
    }
    
    @objc public var placeHolderColor: UIColor?{
        didSet{
            placeHolderLab.textColor = placeHolderColor
        }
    }
    
    @objc public var placeHolderInsets: UIEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    
//    最大高度  默认无限制
    @objc public var maxTextViewHeight = CGFloat.greatestFiniteMagnitude
    
    private lazy var placeHolderLab: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.blt.hexColor(0x999999)
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func didInitialize(){
        self.delegate = self
        addSubview(placeHolderLab)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChanged(_:)), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc private func textDidChanged(_ senderObj: Any?){
        var textView: LBTextView?
//        通知的只处理自己触发的
        if let notification = senderObj as? Notification, let obj = notification.object as? LBTextView{
            if obj == self{
                textView = obj
            }
        }else if let _ = senderObj as? LBTextView{
            textView = self
        }
        guard let _ = textView else { return }
//        1.刷新placeHolder是否展示的
        refreshPlaceHolderLabelState()
        
//        2.联想词  是否超过最大长度
        if self.markedTextRange == nil && self.text.length > self.maxTextLength{
            cutTextToMaxLength()
            customDelegate?.lb_textViewPreventTextChange(textView: self, replacementText: nil)
        }else{
            customDelegate?.lb_textViewDidChangeText(textView: self)
        }
        
//        3.处理高度是否发生了变化
        let height = self.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude)).height
        if height != self.bounds.height{
            customDelegate?.lb_textViewHeightDidChange(textView: self, height: height)
        }
    }
    
    
//    刷新placeHolder展示的状态
    private func refreshPlaceHolderLabelState(){
        guard let holder = placeHolder, holder.isEmpty == false else {
            placeHolderLab.isHidden = true
            return
        }
        if self.text.isEmpty && holder.isEmpty == false {
            placeHolderLab.isHidden = false
        }else{
            placeHolderLab.isHidden = true
        }
    }
    
//    截取到最大长度
    private func cutTextToMaxLength(){
        self.text = String(self.text.prefix(self.maxTextLength))
    }
}




//重写系统的方法
extension LBTextView{
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var resultSize = super.sizeThatFits(size)
        resultSize.height = max(resultSize.height, maxTextViewHeight)
        return resultSize
    }
    
    open override var text: String!{
        didSet{
            refreshPlaceHolderLabelState()
            if self.shouldResponseAPITextChange{
                textDidChanged(self)
            }
        }
    }
    
    open override var attributedText: NSAttributedString!{
        didSet{
            refreshPlaceHolderLabelState()
            if self.shouldResponseAPITextChange{
                textDidChanged(self)
            }
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        guard let holder = placeHolder, holder.isEmpty == false else {
            return
        }
        self.placeHolderLab.frame = CGRectFromEdgeInsetsSwift(frame: self.bounds, insets: self.placeHolderInsets)
    }
    
}


extension LBTextView: UITextViewDelegate{
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        判断是不是点击了确认
        BLTSwiftLog("LBLog text \(String(describing: textView.text))   \(text)   \(textView.markedTextRange)")
        if text == "\n"{
            return customDelegate?.lb_textViewShouldReturn(textView: self) ?? true
        }
        
        if self.text.length < self.maxTextLength{
//            1.处理中文输入法 markedTextRange 不为空  是huang不能按字数来算
            if let _ = self.markedTextRange  {
                return true
            }
            
//            允许删除的
            if text.length == 0 && range.length > 0{
                return true
            }
        }
        if self.supportEmoji == false && self.hasEmojiText(string: text){
            return false
        }
//        截取放到didChangeText方法里处理
        return true
    }
    
    private func hasEmojiText(string: String) -> Bool{
        let pattern = "[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"
        let predicate = NSPredicate.init(format: "SELF MATCHED \(pattern)", argumentArray: nil)
        return predicate.evaluate(with: string)
    }
    
}
