//
//  LBBaseView.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/1/9.
//

import UIKit

class LBBaseView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubView()
    }
    
    func initSubView() {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
