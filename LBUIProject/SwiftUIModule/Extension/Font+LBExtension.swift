//
//  Font+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/11.
//

import Foundation
import SwiftUI
import BLTSwiftUIKit

extension Font: BLTNameSpaceCompatibleValue{}

extension BLTNameSpace where Base == Font{
    public static func normalFont(_ size: CGFloat) -> Font{
        let font = UIFont.init(name: .normalFontName, size: size) ?? UIFont.systemFont(ofSize: size)
        return Font(font)
    }
    
    public static func mediumFont(_ size: CGFloat) -> Font{
        let font = UIFont.init(name: .mediumFontName, size: size) ?? UIFont.systemFont(ofSize: size)
        return Font(font)
    }
    
    public static func boldFont(_ size: CGFloat) -> Font{
        let font = UIFont.init(name: .boldFontName, size: size) ?? UIFont.systemFont(ofSize: size)
        return Font(font)
    }
}


fileprivate extension String{
    static let normalFontName = "PingFangSC-Regular"
    static let mediumFontName = "PingFangSC-Medium"
    static let boldFontName = "PingFangSC-Semibold"
}
