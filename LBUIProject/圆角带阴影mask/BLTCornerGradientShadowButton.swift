//
//  BLTCornerGradientShadowButton.swift
//  chugefang
//
//  Created by liu bin on 2023/1/29.
//  Copyright © 2023 baletu123. All rights reserved.
//

import UIKit

/// 圆角 渐变 阴影的按钮
open class BLTCornerGradientShadowButton: UIButton {
    
    ///圆角
    @objc public var customCornerRadius: CGFloat = 0
    
    @objc public lazy var gradientLayer = CAGradientLayer()

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer.frame == self.bounds {
            return
        }
        
        if customCornerRadius == 0{
            customCornerRadius = self.bounds.height / 2
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
    @objc public func setShadowParams(_ shadowColor: UIColor, shadowRadius: CGFloat = 3, shadowOffset: CGSize = .zero, shadowOpacity: Float = 1, shadowPath: UIBezierPath? = nil) {
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.masksToBounds = false
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowPath = shadowPath?.cgPath
    }
    
    ///设置渐变
    @objc public func setGradientParams(_ startColor: UIColor, _ endColor: UIColor, startLocation: CGPoint = CGPoint(x: 0, y: 0.5), endLocation: CGPoint = CGPoint(x: 1, y: 0.5), locations: [NSNumber]? = nil){
        self.gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        self.gradientLayer.locations = locations
        self.gradientLayer.startPoint = startLocation
        self.gradientLayer.endPoint = endLocation
    }
    
}

