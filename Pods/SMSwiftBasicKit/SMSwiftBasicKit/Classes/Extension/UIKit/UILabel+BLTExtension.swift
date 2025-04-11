//
//  UIColor+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/10.
//

import Foundation
import UIKit

//extension UILabel: BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: UILabel{
    
    public static func initWithFont(font: UIFont, textColor: UIColor, numberOfLines: Int = 1) -> Base {
        return self.initWithText(text: nil, font: font, textColor: textColor, textAlignment: .left, numberOfLines: numberOfLines)
    }
    
    public static func initWithText(text: String?, font: UIFont, textColor: UIColor, textAlignment: NSTextAlignment = .left, numberOfLines: Int = 1) -> Base {
        let label = Base()
        label.text = text
        label.font = font
        label.textColor = textColor
        label.textAlignment = textAlignment
        label.numberOfLines = numberOfLines
        return label
    }
}

