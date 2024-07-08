//
//  LBPresentFullScreenController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/7/8.
//

import Foundation

/// present 类型竖屏
class LBPresentFullScreenController: UIViewController{
    
    var isFullScreen = true
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("返回", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(backButtonClicked), for: .touchUpInside)
        return button
    }()
    
    lazy var centerBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("竖屏", for: .normal)
        button.setTitle("横屏", for: .selected)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(changeFullOrientationButtonClicked), for: .touchUpInside)
        return button
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(centerBtn)
        view.addSubview(backButton)
        centerBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(40)
        }
        
        backButton.snp.makeConstraints { make in
            make.width.height.equalTo(44)
            make.left.equalTo(0)
            make.top.equalTo(0)
        }
    }
    
    override var shouldAutorotate: Bool{
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return isFullScreen ? .landscapeRight : .portrait
    }
    
    @objc private func changeFullOrientationButtonClicked() {
        isFullScreen = !isFullScreen
        centerBtn.isSelected = !centerBtn.isSelected
        if #available(iOS 16.0, *) {
            setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            LBFullScreenViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    @objc private func backButtonClicked() {
//        changeFullOrientationButtonClicked()
        self.dismiss(animated: false)
    }

}
