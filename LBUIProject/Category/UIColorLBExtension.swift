//
//  UIColorLBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/25.
//

import Foundation
import BLTSwiftUIKit


public let lb_randomColorList: [UIColor] = [
    UIColor.blt.color(red: 239, green: 83, blue: 98),
    UIColor.blt.color(red: 254, green: 103, blue: 78),
    UIColor.blt.color(red: 255, green: 203, blue: 71),
    UIColor.blt.color(red: 159, green: 214, blue: 97),
    UIColor.blt.color(red: 63, green: 203, blue: 175),
    UIColor.blt.color(red: 8, green: 91, blue: 181),
    UIColor.blt.color(red: 91, green: 153, blue: 238),
    UIColor.blt.color(red: 170, green: 143, blue: 239),
    UIColor.blt.color(red: 239, green: 133, blue: 192),
    UIColor.blt.color(red: 40, green: 192, blue: 242),
]

extension BLTNameSpace where Base: UIColor{
    
    ///从几个毕竟显眼的颜色重随机一个
    static func randomColorWithNum(_ index: Int = 0) -> UIColor {
        guard index >= 0 && index < 10 else {
            return lb_randomColorList.first ?? UIColor()
        }
        return lb_randomColorList[index]
    }
    
    ///真正的完全随机
    static func randomColor() -> UIColor{
        return UIColor.blt.color(red: CGFloat(arc4random_uniform(255)) , green: CGFloat(arc4random_uniform(255)), blue: CGFloat(arc4random_uniform(255)))
    }
    
    static func color(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor{
        return UIColor.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
    
}
