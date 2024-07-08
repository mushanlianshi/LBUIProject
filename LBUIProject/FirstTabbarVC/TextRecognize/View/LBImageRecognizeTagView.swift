//
//  LBImageRecognizeTagView.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/30.
//

import UIKit

class LBImageRecognizeTagView: UIView {
    
    let borderColor = UIColor.green
    
    lazy var borderLayer: CALayer = {
        let layer = CALayer.init()
        layer.borderWidth = 2
        layer.borderColor = borderColor.cgColor
        return layer
    }()
    
    lazy var label: UILabel = {
        let label = UILabel.blt.initWithFont(font: UIFont.systemFont(ofSize: 11), textColor: .white)
        label.backgroundColor = borderColor
        return label
    }()
    
    init(frame: CGRect, tag: String) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
