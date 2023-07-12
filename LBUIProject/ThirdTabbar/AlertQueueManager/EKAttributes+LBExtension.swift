//
//  EKAttributes+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/26.
//

import Foundation
import SwiftEntryKit

extension EKAttributes{
    
    ///自定义弹框类型的EKAttributes
    public static func customAlertAttribute() -> EKAttributes {
        var attributes = EKAttributes()
        attributes = .centerFloat
        attributes.displayMode = .inferred
        ///设置自动消失的duration  .infinity不会消失
        attributes.displayDuration = .infinity
        
//        attributes.screenBackground = .color(color: .clear,
//                                             dark: .clear)
        ///设置背景色
        attributes.screenBackground = .clear
        attributes.entryBackground = .clear
        
        attributes.screenInteraction = .forward
        attributes.entryInteraction = .absorbTouches
        ///设置不可滚动消失
        attributes.scroll = .disabled
        attributes.entranceAnimation = .init(
            translate: .init(
                duration: 0.5,
                spring: .init(damping: 1, initialVelocity: 0)
            )
        )
        attributes.exitAnimation = .init(
            translate: .init(duration: 0.35)
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.35)
            )
        )
//        attributes.shadow = .active(
//            with: .init(
//                color: .black,
//                opacity: 0.3,
//                radius: 6
//            )
//        )
        attributes.positionConstraints.size = .init(
            width: .fill,
            height: .ratio(value: 1)
        )
        attributes.positionConstraints.verticalOffset = 0
        attributes.positionConstraints.safeArea = .overridden
        attributes.statusBar = .dark
        return attributes
    }
}
