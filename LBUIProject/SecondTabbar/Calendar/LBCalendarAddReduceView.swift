//
//  LBCalendarAddReduceView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/1/21.
//

import UIKit
import SMSwiftBasicKit

class LBCalendarAddReduceView: UIView {
    
    var reduceBlock: BLTEmptyBlock?
    
    var addBlock: BLTEmptyBlock?
    
    private lazy var horiStackView = UIStackView.blt.initStackView(spacing: 20)
    
    private lazy var titleLab: UILabel = {
        let label = UILabel.blt.initWithText(text: "year", font: .blt.normalFont(15), textColor: .blt.threeThreeBlackColor())
        label.textAlignment = .right
        return label
    }()
    
    private lazy var reduceBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "-", font: .blt.normalFont(16), color: .blue, target: self, action: #selector(reduceBtnClicked), image: nil)
        return button
    }()
    
    private lazy var contentLab: UILabel = {
        let label = UILabel.blt.initWithText(text: "2026", font: .blt.normalFont(15), textColor: .blt.threeThreeBlackColor())
        label.textAlignment = .center
        return label
    }()
    
    private lazy var addBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "+", font: .blt.normalFont(16), color: .blue, target: self, action: #selector(addBtnClicked), image: nil)
        return button
    }()
    
    var text: String?{
        didSet{
            contentLab.text = text
        }
    }
    
    var title: String?{
        didSet{
            titleLab.text = title
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(horiStackView)
        [titleLab, reduceBtn, contentLab, addBtn].forEach(horiStackView.addArrangedSubview(_:))
        self.blt.setCompressHugging(lowPriorityViews: [titleLab], highPriorityViews: [reduceBtn, contentLab, addBtn])
        setConstraints()
    }
    
    
    private func setConstraints() {
        horiStackView.snp.makeConstraints { make in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.height.equalTo(50)
            make.top.bottom.equalToSuperview()
        }
        
        reduceBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
        
        contentLab.snp.makeConstraints { make in
            make.width.equalTo(120)
        }
        
        addBtn.snp.makeConstraints { make in
            make.width.equalTo(50)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @objc private func reduceBtnClicked(){
        reduceBlock?()
    }
    
    
    @objc private func addBtnClicked(){
        addBlock?()
    }
}
