//
//  LBLoginCombineContentView.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/1/9.
//

import Foundation
import SMSwiftBasicKit
import QMUIKit

class LBLoginCombineContentView: LBBaseView {
    
    private lazy var stackView = UIStackView.blt.initStackView(spacing: 15, axis: .vertical)
    
    private lazy var titleLab = UILabel.blt.initWithText(text: "欢迎登录", font: .blt.mediumFont(16), textColor: .blt.threeThreeBlackColor())
    
    lazy var phoneTF: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "请输入手机号"
        tf.textColor = .blt.threeThreeBlackColor()
        tf.placeholderColor = .blt.ninenineBlackColor()
        tf.font = .blt.mediumFont(16)
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.blt.ffRedColor().cgColor
        tf.layer.cornerRadius = 22
        tf.textInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        tf.keyboardType = .phonePad
        tf.maximumTextLength = 11
        return tf
    }()
    
    lazy var codeTF: QMUITextField = {
        let tf = QMUITextField()
        tf.placeholder = "请输入验证码"
        tf.textColor = .blt.threeThreeBlackColor()
        tf.placeholderColor = .blt.ninenineBlackColor()
        tf.font = .blt.mediumFont(16)
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.blt.ffRedColor().cgColor
        tf.layer.cornerRadius = 22
        tf.textInsets = .init(top: 0, left: 15, bottom: 0, right: 15)
        tf.keyboardType = .phonePad
        tf.maximumTextLength = 4
        return tf
    }()
    
    lazy var agreeBtn: QMUIButton = {
        let button = QMUIButton.blt.initWithTitle(title: "请阅读用户隐私协议", font: .blt.mediumFont(12), color: .blue)
        button.setImage(.blt.iconFontImage(name: "blt_kuang", fontSize: 14, color: .blt.ninenineBlackColor()), for: .normal)
        button.imagePosition = .left
        button.setImage(.blt.iconFontImage(name: "blt_duihao_gouxuan1", fontSize: 14, color: .blue), for: .selected)
        return button
    }()
    
    lazy var loginBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "登录", font: .blt.mediumFont(16), color: .white)
        button.isEnabled = false
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.blt.setBackgroundColor(color: UIColor.blt.ffRedColor(), state: .normal)
        button.blt.setBackgroundColor(color: UIColor.blt.ninenineBlackColor(), state: .disabled)
        return button
    }()
    
    override func initSubView() {
        addSubview(stackView)
        [titleLab, phoneTF, codeTF, agreeBtn, loginBtn].forEach(stackView.addArrangedSubview(_:))
        setConstraints()
    }
    
    private func setConstraints(){
        stackView.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.right.equalTo(-15)
            make.top.equalTo(15)
        }
        [phoneTF, codeTF, loginBtn].forEach { view in
            view.snp.makeConstraints { make in
                make.height.equalTo(44)
            }
        }
    }
    
}
