//
//  LBFullScreenViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/7/8.
//

import Foundation

/// 需要tabbar和navigationController都返回上层选中的controller的方向等
class LBFullScreenViewController: UIViewController{
    
    var isFullScreen = true
    
    lazy var backButton: UIButton = {
        let button = UIButton.init()
        button.frame = .init(x: 0, y: 0, width: 44, height: 44)
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
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
        view.backgroundColor = .white
        view.addSubview(centerBtn)
        centerBtn.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(40)
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
        self.navigationController?.popViewController(animated: false)
    }
    
    
}
