//
//  LBAnimationView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/9/22.
//

import Foundation

import UIKit

class LBRadarView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        createRipple(radius: 50, color: .red, delay: 0)
        createRipple(radius: 100, color: .green, delay: 0.5)
        createRipple(radius: 150, color: .yellow, delay: 1.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createRipple(radius: CGFloat, color: UIColor, delay: CFTimeInterval) {
        let circle = UIView(frame: CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2))
        circle.center = self.center
        circle.layer.cornerRadius = radius
        circle.backgroundColor = color.withAlphaComponent(0.5)
        self.addSubview(circle)
        
        // 动画：scale + alpha
        let scaleAnim = CABasicAnimation(keyPath: "transform.scale")
        scaleAnim.fromValue = 1.0
        scaleAnim.toValue = 1.5
        
        let alphaAnim = CABasicAnimation(keyPath: "opacity")
        alphaAnim.fromValue = 0.8
        alphaAnim.toValue = 0.0
        
        let group = CAAnimationGroup()
        group.animations = [scaleAnim, alphaAnim]
        group.duration = 2.0
        group.beginTime = CACurrentMediaTime() + delay
        group.repeatCount = .infinity
        group.isRemovedOnCompletion = false
        
        circle.layer.add(group, forKey: "ripple")
    }
}
