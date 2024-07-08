//
//  LBAlphaAndOpacityViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/9/4.
//

import UIKit
import BLTSwiftUIKit
import BLTUIKitProject

class LBAlphaAndOpacityViewController: UIViewController {
    
    lazy var alphaBtn: BLTCustomImageTitleButton = {
        let image = UIImageNamed("mine_selected")
        let button = BLTCustomImageTitleButton.blt.initWithTitle(title: "alpha", font: .blt.normalFont(16), color: .blt.threeThreeBlackColor(), target: nil, action: nil, image: image)
        button.imageTitleInnerMargin = 2
        button.imagePosition = .left
        button.backgroundColor = .blt.ffRedColor()
        button.alpha = 0.7
        return button
    }()
    
    lazy var opacityBtn: BLTCustomImageTitleButton = {
        let image = UIImageNamed("mine_selected")
        let button = BLTCustomImageTitleButton.blt.initWithTitle(title: "opacity", font: .blt.normalFont(16), color: .blt.threeThreeBlackColor(), target: nil, action: nil, image: image)
        button.imageTitleInnerMargin = 2
        button.imagePosition = .left
        button.layer.opacity = 0.7
        button.backgroundColor = .blt.ffRedColor()
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "alpha And opacity"
        view.backgroundColor = .white
        
        view.addSubview(alphaBtn)
        view.addSubview(opacityBtn)
        
        alphaBtn.snp.makeConstraints { make in
            make.left.top.equalTo(20)
        }
        
        opacityBtn.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(alphaBtn.snp_bottom).offset(20)
        }
    }

}
