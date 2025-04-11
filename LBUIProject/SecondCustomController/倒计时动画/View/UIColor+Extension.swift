//
//  UIColor+Extension.swift
//  HZBuildSwift
//
//  Created by RongCheng on 2023/4/11.
//
import UIKit

extension UIColor {
    static let theme: UIColor = hexString("1BAEF1")
    static let c1: UIColor = hexString("111111")
    static let c2: UIColor = hexString("222222")
    static let c3: UIColor = hexString("333333")
    static let c4: UIColor = hexString("444444")
    static let c5: UIColor = hexString("555555")
    static let c6: UIColor = hexString("666666")
    static let c7: UIColor = hexString("777777")
    static let c8: UIColor = hexString("888888")
    static let c9: UIColor = hexString("999999")
    static let cA: UIColor = hexString("AAAAAA")
    static let cB: UIColor = hexString("BBBBBB")
    static let cC: UIColor = hexString("CCCCCC")
    static let cD: UIColor = hexString("DDDDDD")
    static let cE: UIColor = hexString("EEEEEE")
    static let cF7: UIColor = hexString("F7F7F7")
    static let cRed: UIColor = hexString("FF4053")
    
    static func hexString(_ string: String) -> UIColor {
        var tempStr = string
        if tempStr.hasPrefix("#") {
            tempStr = String(tempStr[tempStr.index(tempStr.startIndex, offsetBy: 1)...])
        }
        assert(tempStr.count == 6, "颜色位数错误")
        
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        
        Scanner(string: String(tempStr[..<tempStr.index(tempStr.startIndex, offsetBy: 2)])).scanHexInt64(&red)
        
        Scanner(string: String(tempStr[tempStr.index(tempStr.startIndex, offsetBy: 2)..<tempStr.index(tempStr.startIndex, offsetBy: 4)])).scanHexInt64(&green)
        
        Scanner(string: String(tempStr[tempStr.index(tempStr.startIndex, offsetBy: 4)...])).scanHexInt64(&blue)
        
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: 1.0)
    }
    
    static func randomColor() -> UIColor {
        let red = arc4random() % 255
        let green = arc4random() % 255
        let blue = arc4random() % 255
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue:  CGFloat(blue)/255.0, alpha: 1.0)
    }
}


//
//  UIColor+Extension.swift
//  CL
//
//  Created by JmoVxia on 2020/2/25.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

import UIKit

extension UIColor {
    /// 颜色16进制字符串
    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        if a == 1.0 {
            return String(format: "%0.2X%0.2X%0.2X", UInt(r * 255), UInt(g * 255), UInt(b * 255))
        } else {
            return String(format: "%0.2X%0.2X%0.2X%0.2X", UInt(r * 255), UInt(g * 255), UInt(b * 255), UInt(a * 255))
        }
    }

    /// 主题色
//    @objc class var theme: UIColor {
//        "#02AA5D".uiColor
//    }

    /// 随机色
    class var random: UIColor {
        let red = CGFloat(arc4random() % 256) / 255.0
        let green = CGFloat(arc4random() % 256) / 255.0
        let blue = CGFloat(arc4random() % 256) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 0.35)
    }

    // 获取反色(补色)
    var invert: UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: nil)
        return UIColor(red: 1.0 - r, green: 1.0 - g, blue: 1.0 - b, alpha: 1)
    }
}

// MARK: - JmoVxia---16进制颜色扩展

extension UIColor {
    private enum ColorType {
        case RGBshort(rgb: String)
        case RGBshortAlpha(rgba: String)
        case RGB(rgb: String)
        case RGBA(rgba: String)

        init?(from hex: String) {
            let hexString: String = if hex.hasPrefix("#") {
                hex.replacingOccurrences(of: "#", with: "")
            } else if hex.hasPrefix("0x") {
                hex.replacingOccurrences(of: "0x", with: "")
            } else {
                hex
            }
            switch hexString.count {
            case 3:
                self = .RGBshort(rgb: hexString)
            case 4:
                self = .RGBshortAlpha(rgba: hexString)
            case 6:
                self = .RGB(rgb: hexString)
            case 8:
                self = .RGBA(rgba: hexString)
            default:
                return nil
            }
        }

        var value: String {
            switch self {
            case let .RGBshort(rgb):
                rgb
            case let .RGBshortAlpha(rgba):
                rgba
            case let .RGB(rgb):
                rgb
            case let .RGBA(rgba):
                rgba
            }
        }

        func components() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
            var hexValue: UInt32 = 0
            guard Scanner(string: value).scanHexInt32(&hexValue) else {
                return nil
            }

            let r, g, b, a, divisor: CGFloat

            switch self {
            case .RGBshort:
                divisor = 15
                r = CGFloat((hexValue & 0xF00) >> 8) / divisor
                g = CGFloat((hexValue & 0x0F0) >> 4) / divisor
                b = CGFloat(hexValue & 0x00F) / divisor
                a = 1
            case .RGBshortAlpha:
                divisor = 15
                r = CGFloat((hexValue & 0xF000) >> 12) / divisor
                g = CGFloat((hexValue & 0x0F00) >> 8) / divisor
                b = CGFloat((hexValue & 0x00F0) >> 4) / divisor
                a = CGFloat(hexValue & 0x000F) / divisor
            case .RGB:
                divisor = 255
                r = CGFloat((hexValue & 0xFF0000) >> 16) / divisor
                g = CGFloat((hexValue & 0x00FF00) >> 8) / divisor
                b = CGFloat(hexValue & 0x0000FF) / divisor
                a = 1
            case .RGBA:
                divisor = 255
                r = CGFloat((hexValue & 0xFF00_0000) >> 24) / divisor
                g = CGFloat((hexValue & 0x00FF_0000) >> 16) / divisor
                b = CGFloat((hexValue & 0x0000_FF00) >> 8) / divisor
                a = CGFloat(hexValue & 0x0000_00FF) / divisor
            }
            return (red: r, green: g, blue: b, alpha: a)
        }
    }

    /// 通过16进制字符串创建颜色
    convenience init(_ hex: String, alpha: CGFloat? = nil) {
        if let hexType = ColorType(from: hex), let components = hexType.components() {
            self.init(red: components.red, green: components.green, blue: components.blue, alpha: alpha ?? components.alpha)
        } else {
            self.init(white: 0, alpha: 0)
        }
    }
}

// MARK: - JmoVxia---字符串颜色支持

extension String {
    var uiColor: UIColor {
        .init(self)
    }

    var cgColor: CGColor {
        uiColor.cgColor
    }
}

// MARK: - JmoVxia---16进制数字颜色支持

extension Int {
    var uiColor: UIColor {
        .init(String(format: "%02X", self))
    }

    var cgColor: CGColor {
        uiColor.cgColor
    }
}
