//
//  UIView+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/5/18.
//

import Foundation

extension UIView: BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: UIView{
    
//    设置优先级
    public func setCompressHugging(lowPriorityViews: [UIView], highPriorityViews: [UIView], direction: NSLayoutConstraint.Axis = .horizontal) {
        for lowView in lowPriorityViews {
            lowView.setContentCompressionResistancePriority(.defaultLow, for: direction)
            lowView.setContentHuggingPriority(.defaultLow, for: direction)
        }
        
        for highView in highPriorityViews{
            highView.setContentCompressionResistancePriority(.defaultHigh, for: direction)
            highView.setContentHuggingPriority(.defaultHigh, for: direction)
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
}
