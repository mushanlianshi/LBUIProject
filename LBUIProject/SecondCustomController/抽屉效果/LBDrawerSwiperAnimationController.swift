//
//  LBDrawerSwiperAnimationController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/8/20.
//

import UIKit

class LBDrawerSwiperAnimationController: UIViewController {
    

    lazy var startAnimationBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "开始弹出", font: .blt.normalFont(16), color: .red, target: self, action: #selector(startPresentButtonClicked))
        button.backgroundColor = UIColor.lightGray
        
        return button
    }()
    
    lazy var startAnimationBtn2: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "开始弹出2", font: .blt.normalFont(16), color: .red, target: self, action: #selector(startPresentButtonClicked2))
        button.backgroundColor = UIColor.lightGray
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(startAnimationBtn)
        view.addSubview(startAnimationBtn2)
        view.backgroundColor = .lightGray
        startAnimationBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(44)
        }
        
        startAnimationBtn2.snp.makeConstraints { make in
            make.top.equalTo(startAnimationBtn.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(44)
        }
    }
    
    
    @objc private func startPresentButtonClicked() {
        let swiperView = LBDrawerSwiperAnimationView()
        swiperView.backgroundColor = .black.withAlphaComponent(0.4)
        self.view.addSubview(swiperView)
        swiperView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    @objc private func startPresentButtonClicked2() {
        let swiperView2 = LBDrawerSwiperAnimationView2()
        swiperView2.backgroundColor = .black.withAlphaComponent(0.4)
        self.view.addSubview(swiperView2)
        swiperView2.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


}
