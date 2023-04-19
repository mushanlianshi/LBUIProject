//
//  LBTextField.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/11.
//

import Foundation
import BLTSwiftUIKit
import UIKit
import BLTBasicUIKit

open class LBTextField: UITextField {
    
    @objc public var contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    @objc public var maxTextLength = Int.max
    
    @objc var leftViewOffsetX: CGFloat = 15
    
    @objc var rightViewOffsetX: CGFloat = 15
    
    @objc var leftImage: UIImage?{
        didSet{
            refreshLeftImageView(leftImage)
        }
    }
    
    convenience init(textColor: UIColor, font: UIFont, placeHolderText: String? = nil, placeHolderColor: UIColor = UIColor.blt.hexColor(0x999999)) {
        self.init(frame: .zero)
        self.textColor = textColor
        self.font = font
        
        if let placeHolder = placeHolderText{
            let attributeText = placeHolder.blt.highLightText(highArray: [placeHolder], attrs: [.font : font, .foregroundColor : placeHolderColor])
            self.attributedText = attributeText
        }
    }
    
    
    convenience init(textInsets: UIEdgeInsets){
        self.init(frame: .zero)
        self.contentInsets = contentInsets
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func refreshLeftImageView(_ image: UIImage?){
        guard let img = leftImage else {
            self.leftView = nil
            return
        }
        let imageView = UIImageView()
        imageView.image = img
        self.leftView = imageView
    }
    
    private func addRightButton(image: UIImage?, clickHandler: (() -> Void)?, configButtonBlock:((_ button: BLTUIResponseAreaButton) -> Void)?){
        guard let img = image else {
            self.rightView = nil
            return
        }
        
        let rightButton = BLTUIResponseAreaButton()
        rightButton.responseAreaInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        rightButton.addTouchUp(inside: clickHandler)
        rightButton.setImage(img, for: .normal)
        self.rightView = rightButton
        configButtonBlock?(rightButton)
    }
}


//重写展示区域
extension LBTextField{
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        if contentInsets == .zero {
            return super.editingRect(forBounds: bounds)
        }
        return CGRectFromEdgeInsetsSwift(frame: bounds, insets: contentInsets)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        if contentInsets == .zero {
            return super.editingRect(forBounds: bounds)
        }
        return CGRectFromEdgeInsetsSwift(frame: bounds, insets: contentInsets)
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        if contentInsets == .zero {
            return super.editingRect(forBounds: bounds)
        }
        return CGRectFromEdgeInsetsSwift(frame: bounds, insets: contentInsets)
    }
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.leftViewRect(forBounds: bounds)
        if let _ = self.leftView{
            rect.origin.x += self.leftViewOffsetX
        }
        return rect
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        if let _ = self.rightView{
            rect.origin.x -= self.rightViewOffsetX
        }
        return rect
    }
}
