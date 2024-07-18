//
//  LBPresentFullScreenController.swift
//  LBUIProject
//
//  Created by liu bin on 2024/7/8. testreset
//

import Foundation
import SwiftDate

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
        testDate()
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
    
    func testDate(){
        let date = Date()
        print("LBLog date \(date)  \(date.hour) \(date.minute)")
        let time = "2024-07-08 00:58:19"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let date2 = dateFormatter.date(from: time) else {
            return
        }
        
        print("LBLog date \(date2)  \(date2.hour) \(date2.minute)")
        
        let date3 = DateInRegion("2019-06-27 14:30:30")!
         print("LBLogdate3:\(date3.date) \(date3.hour) \(date3.minute)")
    }
    

}
