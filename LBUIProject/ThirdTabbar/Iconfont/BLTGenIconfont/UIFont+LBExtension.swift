//
//  UIFont+LBExtension.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/1/10.
//

import Foundation
import UIKit
import SMSwiftBasicKit
import BLTIconFont

extension BLTNameSpace where Base: UIImage{
    static func iconFontImage(name: String, fontSize: Int, color: UIColor) -> UIImage{
        return BLTMakeIconfontImage(.bltCustomIconfontGen, name, CGFloat(fontSize), color, true)
    }
}
