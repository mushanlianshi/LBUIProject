//
//  LBDragDownSecondPageView.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/24.
//

import Foundation
import UIKit

class LBDragDownSecondPageView: UIView{
    
    var backHomeBlock: (() -> Void)?
    
    let button :UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 20
        btn.setTitle("回到首页", for: .normal)
        btn.backgroundColor = .black
        btn.addTarget(self, action: #selector(goHome), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true;
        self.backgroundColor = .lightGray
        addSubview(button)
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-60)
            make.size.equalTo(CGSize(width: 100, height: 40))
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func goHome(){
        backHomeBlock?()
    }
    
}


