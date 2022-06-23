//
//  Array+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/22.
//

import Foundation
import UIKit



extension UIImage{
    static func imageWithTintColor(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) -> UIImage?{
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
