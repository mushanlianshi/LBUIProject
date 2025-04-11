//
//  UIButton+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/5/18.
//

import Foundation
import UIKit

//extension UIButton: BLTNameSpaceCompatible{}
extension BLTNameSpace where Base: UIButton{
    
    public static func initWithTitle(title:String?, font: UIFont, color: UIColor) -> Base{
        return self.initWithTitle(title: title, font: font, color: color, target: nil, action: nil)
    }
    
    public static func initWithTitle(title:String?, font: UIFont, color: UIColor, target: Any? = nil, action:Selector? = nil, image: UIImage? = nil) -> Base{
        let button = Base()
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)
        button.setTitleColor(color, for: .normal)
        button.titleLabel?.font = font
        if let selector = action{
            button.addTarget(target, action: selector, for: .touchUpInside)
        }
        return button
    }
    
    public static func initWithImage(image: UIImage?, target: Any? = nil, action:Selector? = nil) -> Base{
        let button = Base()
        button.setImage(image, for: .normal)
        if let selector = action{
            button.addTarget(target, action: selector, for: .touchUpInside)
        }
        return button
    }
    
    public static func initWithBackgroundImage(image: UIImage?, target: Any?, action:Selector?) -> Base{
        let button = Base()
        button.setBackgroundImage(image, for: .normal)
        if let selector = action{
            button.addTarget(target, action: selector, for: .touchUpInside)
        }
        return button
    }
    
    public func setBackgroundColor(color: UIColor, state: UIControl.State){
        let image = color.blt.toImage()
        self.base.setBackgroundImage(image, for: state)
    }
}
