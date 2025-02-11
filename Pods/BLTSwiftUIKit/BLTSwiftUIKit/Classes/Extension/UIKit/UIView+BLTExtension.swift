//
//  UIView+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/5/18.
//

import Foundation
import UIKit

extension UIView: BLTNameSpaceCompatible{}



///快速初始化的
extension BLTNameSpace where Base: UIView{
    
    public static func initWithBackgroundColor(color: UIColor = .white,  cornerRadius: CGFloat? = nil) -> Base{
        let view = Base()
        view.backgroundColor = color
        if let radius = cornerRadius {
            view.layer.cornerRadius = radius
            view.layer.masksToBounds = true
        }
        return view
    }
    
}



/// 设置约束优先级的
extension BLTNameSpace where Base: UIView{
    //    设置优先级
    public func setCompressHugging(lowPriorityViews: [UIView], highPriorityViews: [UIView], direction: NSLayoutConstraint.Axis = .horizontal) {
        for lowView in lowPriorityViews {
            lowView.setContentCompressionResistancePriority(.defaultLow, for: direction)
            lowView.setContentHuggingPriority(.defaultLow, for: direction)
        }
        
        for highView in highPriorityViews{
            highView.setContentCompressionResistancePriority(.required, for: direction)
            highView.setContentHuggingPriority(.required, for: direction)
        }
    }
    
    //    获取view的currentVC
    public func currentViewController() -> UIViewController?{
        var superV = base.superview
        while superV != nil {
            let nextResponder = superV?.next
            if nextResponder is UIViewController{
                return nextResponder as? UIViewController
            }
            superV = superV?.superview
        }
        return nil
    }
    
    public func removeAnchorConstraints(){
        self.base.removeConstraints(self.base.constraints)
    }
}


///根据约束来获取宽高的
extension BLTNameSpace where Base: UIView{
    ///根据view的约束 来获取约束的高  width是view约束的宽度
    public func heightByLayoutWidth(_ width: CGFloat) -> CGFloat{
        let size = base.systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
        return size.height
    }
    
    ///根据view的约束 来获取约束的高  width是view约束的宽度
    public func widthByLayoutHeight(_ height: CGFloat) -> CGFloat{
        let size = base.systemLayoutSizeFitting(CGSize(width: 0, height: height), withHorizontalFittingPriority: .defaultLow, verticalFittingPriority: .required)
        return size.width
    }
}



