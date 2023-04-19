//
//  LBBankFormatterTextFieldController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/4/6.
//

import Foundation

class LBBankFormatterTextFieldController: UIViewController {
    
    lazy var textField: UITextField = {
        let view = UITextField()
        view.backgroundColor = .yellow
        view.blt_showBorderColor(.blt.ffRedColor(), cornerRaduis: 5, borderWidth: 1)
        view.keyboardType = .phonePad
        view.formatterWhiteSpacing = 4
        view.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(30)
            make.top.equalTo(30)
            make.right.equalTo(-30)
            make.height.equalTo(50)
        }
    }
    
    @objc func textChanged(_ textField: UITextField){
        
    }
}
