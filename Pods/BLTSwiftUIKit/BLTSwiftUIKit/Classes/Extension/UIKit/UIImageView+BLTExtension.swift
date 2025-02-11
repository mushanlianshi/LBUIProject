//
//  UIImageView+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2024/2/18.
//

import Foundation

extension BLTNameSpace where Base: UIImageView{
    
    public static func initWithMode(mode: UIView.ContentMode, image: UIImage? = nil, cornerRadius: CGFloat? = nil) -> Base{
        let iv = Base()
        iv.contentMode = mode
        iv.image = image
        if let radius = cornerRadius, radius != 0{
            iv.layer.cornerRadius = radius
            iv.layer.masksToBounds = true
        }
        return iv
    }
    
}
