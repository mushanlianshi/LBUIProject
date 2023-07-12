//
//  UIEdgeInsets+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/3/13.
//

import Foundation

extension UIEdgeInsets: BLTNameSpaceCompatibleValue{}

extension BLTNameSpace where Base == UIEdgeInsets{
    
    public func contentWidth() -> CGFloat{
        let insets = self.base
        return insets.left + insets.right
    }
    
    public func contentHeight() -> CGFloat {
        return self.base.top + self.base.bottom
    }
}
