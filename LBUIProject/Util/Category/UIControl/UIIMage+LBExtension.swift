//
//  UIIMage+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

import Foundation
import UIKit

enum ImageName: String{
    case home = "home"
    case header_place_holder = "header_place_holder"
}

extension UIImage {
    convenience init!(imageName: ImageName) {
        self.init(named: imageName.rawValue)
    }
}

extension UIImage {
    convenience init!(imageName: ImageName, tt: String) {
        self.init(named: imageName.rawValue)
    }
    
}
