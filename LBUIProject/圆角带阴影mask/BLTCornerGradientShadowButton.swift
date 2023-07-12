//
//  BLTCornerGradientShadowButton.swift
//  chugefang
//
//  Created by liu bin on 2023/1/29.
//  Copyright © 2023 baletu123. All rights reserved.
//

import UIKit


@objc public enum BLTGradientDirection: Int {
    case leftToRight = 0
    case leftTopToRightBottom
    case leftBottomToRightTop
    
    case topToBottom
}

/// 圆角 渐变 阴影的按钮  默认圆角是高度的一半
open class BLTCornerGradientShadowButton: UIButton {
    
    ///圆角
    @objc public var customCornerRadius: CGFloat = 0
    
    @objc public lazy var gradientLayer = CAGradientLayer()

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer.frame == self.bounds {
            return
        }
        
        layer.cornerRadius = customCornerRadius
        
        gradientLayer.cornerRadius = customCornerRadius
        gradientLayer.frame = self.bounds
        gradientLayer.masksToBounds = true
        gradientLayer.rasterizationScale = UIScreen.main.scale
        gradientLayer.type = CAGradientLayerType.axial
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    ///设置阴影
    @objc public func setShadowParams(_ shadowColor: UIColor, shadowRadius: CGFloat = 3, shadowOffset: CGSize = CGSize(width: 0, height: 2), shadowOpacity: Float = 1, shadowPath: UIBezierPath? = nil) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowPath = shadowPath?.cgPath
    }
    
    ///设置渐变
    @objc public func setGradientParams(_ startColor: UIColor, _ endColor: UIColor, direction: BLTGradientDirection = .leftToRight, locations: [NSNumber]? = nil){
        self.gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        self.gradientLayer.locations = locations
        
        let pointTuple = gradientPoint(direction: direction)
        self.gradientLayer.startPoint = pointTuple.startPoint
        self.gradientLayer.endPoint = pointTuple.endPoint
    }
    
    
    private func gradientPoint(direction: BLTGradientDirection) -> (startPoint: CGPoint, endPoint: CGPoint){
        switch direction {
        case .leftToRight:
            return (CGPoint(x: 0, y: 0.5), CGPoint(x: 1, y: 0.5))
        case .leftTopToRightBottom:
            return (.zero, CGPoint(x: 1, y: 1))
        case .leftBottomToRightTop:
            return (CGPoint(x: 0, y: 1), CGPoint(x: 1, y: 0))
        case .topToBottom:
            return (CGPoint(x: 0.5, y: 0), CGPoint(x: 0.5, y: 1))
        }
    }
    
}

