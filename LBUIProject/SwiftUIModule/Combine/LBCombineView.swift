//
//  LBCombineView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/1/8.
//

import UIKit

class LBCombineView: UIView {
    
    private lazy var stackView = UIStackView.blt.initStackView(spacing: 10, axis: .vertical)
    
    lazy var titleLab = UILabel.blt.initWithText(text: nil, font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor(), numberOfLines: 0)
    
    private lazy var ageLab = UILabel.blt.initWithText(text: nil, font: .blt.mediumFont(14), textColor: .blt.ninenineBlackColor())
    
    lazy var changeBtn = UIButton.blt.initWithTitle(title: "send data", font: .blt.mediumFont(16), color: .blt.threeThreeBlackColor())
    
    lazy var textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入内容"
        tf.font = .blt.mediumFont(16)
        tf.textColor = .blt.threeThreeBlackColor()
        tf.layer.borderColor = UIColor.red.cgColor
        tf.layer.borderWidth = 1
        tf.layer.cornerRadius = 3
        return tf
    }()
    
    
    var model: LBCombineModel?{
        didSet{
            debugPrint("LBLog model \(String(describing: model))")
            titleLab.text = "名字：" + (model?.name ?? "")
            ageLab.text = "年龄：\(String(describing: model?.age))"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(stackView)
        changeBtn.backgroundColor = .blt.ffRedColor()
        [titleLab, ageLab, changeBtn, textField].forEach(stackView.addArrangedSubview(_:))
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        }
        changeBtn.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        textField.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
