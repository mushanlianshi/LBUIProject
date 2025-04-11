//
//  Color+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/11.
//

import Foundation
import SwiftUI

extension Color: BLTNameSpaceCompatibleValue{}

extension BLTNameSpace where Base == Color{
    
    public static func hexColor(_ hexValue: Int, alphaValue: Float = 1) -> Color {
        let color = UIColor(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255, green: CGFloat((hexValue & 0x00FF00) >> 8) / 255, blue: CGFloat(hexValue & 0x0000FF) / 255, alpha: CGFloat(alphaValue))
        return Color(color)
    }
    public static func themeOrangeColor() -> Color{
        return hexColor(0xf8892e)
    }
    
    public static func threeThreeBlackColor() -> Color{
        return hexColor(0x333333)
    }
    
    public static func sixsixBlackColor() -> Color{
        return hexColor(0x666666);
    }
    
    public static func ninenineBlackColor() -> Color{
        return hexColor(0x999999)
    }
    
    public static func ccBackgroundColor() -> Color{
        return hexColor(0xcccccc)
    }
    
    public static func f6BackgroundColor() -> Color{
        return hexColor(0xF6F6F6)
    }
    
    public static func ffRedColor() -> Color{
        return hexColor(0xFF3E33)
    }
    
    public static func eeColor() -> Color{
        return hexColor(0xEEEEEE)
    }
    //    转图片
    public func toImage() -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        let uicolor = self.uiColor
        context?.setFillColor(uicolor.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    public static func gradientColor(fromColor: UIColor, toColor: UIColor, progress: CGFloat) -> Color{
        let pro = min(progress, 1)
        let fromR = fromColor.blt.getColorWay(rgba: .red)
        let fromG = fromColor.blt.getColorWay(rgba: .green)
        let fromB = fromColor.blt.getColorWay(rgba: .blue)
        let fromA = fromColor.blt.getColorWay(rgba: .alpha)
        
        let toR = toColor.blt.getColorWay(rgba: .red)
        let toG = toColor.blt.getColorWay(rgba: .green)
        let toB = toColor.blt.getColorWay(rgba: .blue)
        let toA = toColor.blt.getColorWay(rgba: .alpha)
        
        let finalR = fromR + (toR - fromR) * pro
        let finalG = fromG + (toG - fromG) * pro
        let finalB = fromB + (toB - fromB) * pro
        let finalA = fromA + (toA - fromA) * pro
        let color = UIColor.init(red: finalR, green: finalG, blue: finalB, alpha: finalA)
        return Color(color)
    }
    
    
    public var uiColor: UIColor {
        if #available(iOS 14.0, *) {
            // iOS 14 及以上系统，直接转换
            return UIColor(self.base)
        } else {
            let scanner = Scanner(string: self.base.description.trimmingCharacters(in: .whitespacesAndNewlines))
            var hexNumber: UInt64 = 0
            if scanner.scanHexInt64(&hexNumber) {
                let r = CGFloat((hexNumber & 0xff0000) >> 16) / 255.0
                let g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255.0
                let b = CGFloat(hexNumber & 0x0000ff) / 255.0
                return UIColor.init(red: r, green: g, blue: b, alpha: 1.0)
            } else {
                return .white // 转换失败时，使用透明颜色
            }
        }
    }
    
}
