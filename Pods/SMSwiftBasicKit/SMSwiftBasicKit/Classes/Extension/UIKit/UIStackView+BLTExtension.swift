//
//  UIStackView+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/9/7.
//

import Foundation

extension BLTNameSpace where Base: UIStackView{
    
    /// 快速初始化
    public static func initStackView(spacing: CGFloat) -> Base{
        return self.initStackView(spacing: spacing, axis: .horizontal, distribution: .fill, alignment: .fill)
    }
    
    /// 快速初始化
    public static func initStackView(spacing: CGFloat = 0, axis: NSLayoutConstraint.Axis = .horizontal, distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill) -> Base{
        let stackView = Base()
        stackView.spacing = spacing
        stackView.axis = axis
        stackView.distribution = distribution
        stackView.alignment = alignment
        return stackView
    }
    
    ///因为在iOS13以下  stackView的layer是CATransformLayer 只有布局功能  不参与渲染  导致设置背景色无效
    ///iOS13以后  layer是CALayer  可以正常设置背景颜色
    public func backgroundColor(color: UIColor){
        if #available(iOS  14.0, *){
            base.backgroundColor = color
        }else{
            let view = UIView()
            view.backgroundColor = color
            base.insertSubview(view, at: 0)
            view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        }
    }
    
    
    
}
