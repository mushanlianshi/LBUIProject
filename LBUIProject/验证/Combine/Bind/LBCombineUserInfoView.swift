//
//  LBCombineUserInfoView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/7.
//

import UIKit

class LBCombineUserInfoView: LBBaseView {
    private lazy var nameLab = UILabel.blt.initWithText(text: "", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    private lazy var ageLab = UILabel.blt.initWithText(text: "", font: .blt.mediumFont(14), textColor: .blt.sixsixBlackColor())
    
    private lazy var imageView = UIImageView()
    
    lazy var stackView = UIStackView.blt.initStackView(spacing: 15, axis: .vertical)
    
    override func initSubView() {
        addSubview(stackView)
        [nameLab, ageLab, imageView].forEach(stackView.addArrangedSubview(_:))
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func updateInfo(_ userInfo: LBCombineUserInfoModel?) {
        nameLab.text = userInfo?.name
        ageLab.text = userInfo?.age.blt.toString()
    }
}
