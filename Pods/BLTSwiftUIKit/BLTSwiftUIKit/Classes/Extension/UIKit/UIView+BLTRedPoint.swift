//
//  UIViewBLTExtension.swift
//  chugefang
//
//  Created by liu bin on 2022/11/1.
//  Copyright © 2022 baletu123. All rights reserved.
//

import Foundation
import SnapKit
import UIKit

private struct AssociatedKeys {
    static var redPointKey = "redPointKey"
}

extension BLTNameSpace where Base: UIView{
    ///距离右上角的偏移量
    ///x y 距离右上角的偏移量 
    @discardableResult
    public func showRedPointOffsetRightTop(x: CGFloat, y: CGFloat, redColor: UIColor = .red, circleWidth: CGFloat = 5) -> UILabel {
        var redView = objc_getAssociatedObject(base, &AssociatedKeys.redPointKey) as? UILabel
        if redView == nil{
            redView = UILabel()
            redView?.backgroundColor = redColor
            redView?.layer.cornerRadius = circleWidth / 2
            redView?.layer.masksToBounds = true
            objc_setAssociatedObject(base, &AssociatedKeys.redPointKey, redView, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            base.addSubview(redView!)
            redView?.snp.makeConstraints({ make in
                make.width.height.equalTo(circleWidth)
                make.left.equalTo(base.snp_right).offset(x)
                make.top.equalTo(y)
            })
        }
        return redView!
    }
    
    public func hiddenRedPointOffsetRightTop() {
        guard let redView = objc_getAssociatedObject(base, &AssociatedKeys.redPointKey) as? UILabel else {
            return
        }
        redView.removeFromSuperview()
        objc_setAssociatedObject(base, &AssociatedKeys.redPointKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
