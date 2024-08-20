//
//  LBDrawerSwiperAnimationController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/8/20.
//

import UIKit

class LBDrawerSwiperAnimationController: UIViewController {
    
    lazy var swiperView = LBDrawerSwiperAnimationView()

    lazy var startAnimationBtn: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "开始弹出", font: .blt.normalFont(16), color: .red, target: self, action: #selector(startPresentButtonClicked))
        button.backgroundColor = UIColor.lightGray
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(startAnimationBtn)
        view.backgroundColor = .lightGray
        startAnimationBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(44)
        }
    }
    
    
    @objc private func startPresentButtonClicked() {
        swiperView.backgroundColor = .black.withAlphaComponent(0.4)
        self.view.addSubview(swiperView)
        swiperView.snp.remakeConstraints { make in
            make.edges.equalToSuperview()
        }
    }


}
