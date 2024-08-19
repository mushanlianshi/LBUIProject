//
//  UINavigationBarAppearance+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/26.
//

import Foundation
import UIKit

public extension UINavigationBar{
//    习惯tintColor来设置属性 item的颜色的
    func refreshNaviBarTintColor(itemColor: UIColor, titleColor: UIColor, barTintColor: UIColor? = nil, backgroundImage: UIImage? = nil, shadowImage: UIImage? = nil) {
        
        if #available(iOS 13.0, *) {
            self.tintColor = itemColor
            
            let appearance = self.standardAppearance
            if let _ = backgroundImage{
                appearance.backgroundImage = backgroundImage
            }
            if let _ = shadowImage{
                appearance.shadowImage = shadowImage
            }
            if let _ = barTintColor{
                appearance.backgroundColor = barTintColor
            }
            var appearanceTitleAttribute: [NSAttributedString.Key : Any] = self.titleTextAttributes ?? [NSAttributedString.Key : Any]()
            appearanceTitleAttribute[.foregroundColor] = titleColor
            appearance.titleTextAttributes = appearanceTitleAttribute
            
            let itemAppearance = UIBarButtonItemAppearance()
            var itemAppearanceTitleAttribute = itemAppearance.normal.titleTextAttributes
            itemAppearanceTitleAttribute[.foregroundColor] = itemColor
            itemAppearance.normal.titleTextAttributes = itemAppearanceTitleAttribute
            
            appearance.doneButtonAppearance = itemAppearance
            appearance.buttonAppearance = itemAppearance
            appearance.backButtonAppearance = itemAppearance
            
//            self.scrollEdgeAppearance = appearance
//            self.standardAppearance = appearance
            
        } else {
            // Fallback on earlier versions
            var attributeDic: [NSAttributedString.Key : Any] = self.titleTextAttributes ?? [NSAttributedString.Key : Any]()
            attributeDic[.foregroundColor] = itemColor
            self.titleTextAttributes = attributeDic
            if let _ = backgroundImage{
                self.setBackgroundImage(backgroundImage, for: .default)
            }
            if let _ = shadowImage{
                self.shadowImage = shadowImage
            }
            if let _ = barTintColor{
                self.barTintColor = barTintColor
            }
        }
    }
}
