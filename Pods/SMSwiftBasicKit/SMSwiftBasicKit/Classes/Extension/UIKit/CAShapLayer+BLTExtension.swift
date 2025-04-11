//
//  CAShapLayer+BLTExtension.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2022/5/24.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

import Foundation
import QuartzCore
import UIKit

extension CAShapeLayer :BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: CAShapeLayer{
//    初始化一个间隔线的layer
    public static func initDottedLine(frame: CGRect, dashPattern: [NSNumber], strokeColor: UIColor, lineWidth: CGFloat = 1, lineJoin: CAShapeLayerLineJoin = .round) -> Base{
        let shaperLayer = Base()
        shaperLayer.frame = frame
        shaperLayer.strokeColor = strokeColor.cgColor
        shaperLayer.lineWidth = lineWidth
//        虚线间距的宽度
        shaperLayer.lineDashPattern = dashPattern
        let path = UIBezierPath()
        path.move(to: .zero)
        ///画线 调整这头到那头  偏一点高度或则宽度的
        if frame.height > frame.width {
            path.addLine(to: CGPoint(x: 0, y: frame.height))
        }else{
            path.addLine(to: CGPoint(x: frame.width, y: 0))
        }
        shaperLayer.path = path.cgPath
        return shaperLayer
    }
    
    //    初始化一个间隔线的layer
        public func drawDottedLine(dashPattern: [NSNumber], strokeColor: UIColor, lineWidth: CGFloat = 1, lineJoin: CAShapeLayerLineJoin = .round){
            base.strokeColor = strokeColor.cgColor
            base.lineWidth = lineWidth
    //        虚线间距的宽度
            base.lineDashPattern = dashPattern
            let path = UIBezierPath()
            path.move(to: .zero)
            ///画线 调整这头到那头  偏一点高度或则宽度的
            if base.frame.height > base.frame.width {
                path.addLine(to: CGPoint(x: 0, y: base.frame.height))
            }else{
                path.addLine(to: CGPoint(x: base.frame.width, y: 0))
            }
            base.path = path.cgPath
        }
}
