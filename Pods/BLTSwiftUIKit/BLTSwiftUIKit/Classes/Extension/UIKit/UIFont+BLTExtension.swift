//
//  UIFont+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/9/22.
//

import Foundation

extension UIFont: BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: UIFont{
    public static func normalFont(_ size: CGFloat) -> UIFont{
        return UIFont.init(name: .normalFontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    public static func mediumFont(_ size: CGFloat) -> UIFont{
        return UIFont.init(name: .mediumFontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    public static func boldFont(_ size: CGFloat) -> UIFont{
        return UIFont.init(name: .boldFontName, size: size) ?? UIFont.systemFont(ofSize: size)
    }
}


fileprivate extension String{
    static let normalFontName = "PingFangSC-Regular"
    static let mediumFontName = "PingFangSC-Medium"
    static let boldFontName = "PingFangSC-Semibold"
}
