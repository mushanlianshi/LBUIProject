//
//  UIColor+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/10.
//

import Foundation
import UIKit

extension UIColor: BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: UIColor{
    public static func hexColor(_ hexValue: Int, alphaValue: Float = 1) -> UIColor {
        return UIColor(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255, green: CGFloat((hexValue & 0x00FF00) >> 8) / 255, blue: CGFloat(hexValue & 0x0000FF) / 255, alpha: CGFloat(alphaValue))
    }
    public static func themeOrangeColor() -> UIColor{
        return hexColor(0xf8892e)
    }
    
    public static func threeThreeBlackColor() -> UIColor{
        return hexColor(0x333333)
    }
    
    public static func sixsixBlackColor() -> UIColor{
        return hexColor(0x666666);
    }
    
    public static func ninenineBlackColor() -> UIColor{
        return hexColor(0x999999)
    }
    
    public static func ccBackgroundColor() -> UIColor{
        return hexColor(0xcccccc)
    }
    
    public static func f6BackgroundColor() -> UIColor{
        return hexColor(0xF6F6F6)
    }
    
    public static func ffRedColor() -> UIColor{
        return hexColor(0xFF3E33)
    }
    
    public static func eeColor() -> UIColor{
        return hexColor(0xEEEEEE)
    }
    //    转图片
    public func toImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(base.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}


