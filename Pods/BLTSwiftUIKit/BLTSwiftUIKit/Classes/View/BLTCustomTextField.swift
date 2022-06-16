//
//  BLTCustomTextField.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2021/11/5.
//  Copyright © 2021 com.wanjian. All rights reserved.
//

import UIKit

class BLTCustomTextField: UITextField {
    
    convenience init(contentInsets: UIEdgeInsets) {
        self.init()
        self.contentInsets = contentInsets
    }
    
    var contentInsets: UIEdgeInsets? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        guard let insets = contentInsets else {
            return super.textRect(forBounds: bounds)
        }
        return CGRectFromEdgeInsetsSwift(frame: bounds, insets: insets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        guard let insets = contentInsets else {
            return super.editingRect(forBounds: bounds)
        }
        return CGRectFromEdgeInsetsSwift(frame: bounds, insets: insets)
    }
}
