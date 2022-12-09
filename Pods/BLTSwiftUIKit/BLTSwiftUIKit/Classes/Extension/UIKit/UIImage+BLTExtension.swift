//
//  Array+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/17.
//

import UIKit

extension UIImage: BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: UIImage{
    
    static func resizeImageWithCenterPoint(imageName: String) -> UIImage?{
        let image = UIImage.init(named: imageName)
        guard let img = image else { return nil }
        
        return img.blt.resizeImageWithCenterPoint()
    }
    
    func resizeImageWithCenterPoint() -> UIImage{
        let width = self.base.size.width
        let height = self.base.size.height
        let image = self.base.resizableImage(withCapInsets: UIEdgeInsets(top: height / 2, left: width / 2, bottom: height / 2, right: width / 2), resizingMode: .stretch)
        return image
    }
}
