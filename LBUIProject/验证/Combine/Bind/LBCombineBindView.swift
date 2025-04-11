//
//  LBCombineBindView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/7.
//

import Foundation
import Combine

class LBCombineBindView: LBBaseView{
    
    lazy var contentLab = UILabel.blt.initWithText(text: "11", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    
    override func initSubView() {
        addSubview(contentLab)
        contentLab.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
    
    
    
}
