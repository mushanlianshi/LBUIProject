//
//  LBNotificationViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/16.
//

import Foundation
import BLTUIKitProject

class LBNotificationViewController: UIViewController{
    
    lazy var autoDismissButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title:  "自动消失的notificationView", font: UIFontPFFontSize(16), color: .white, target: self, action: #selector(showNotificationView), image: nil)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        button.backgroundColor = UIColor.blue.withAlphaComponent(0.6)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.view.addSubview(autoDismissButton)
        autoDismissButton.snp.makeConstraints { make in
            make.top.equalTo(100)
            make.centerX.equalToSuperview()
        }
    }
    
    
    @objc private func showNotificationView(){
        let notification = LBNotification.notificationWithViewClass(viewClass: LBNotificationView.self) { view in
            guard let notiView = view as? LBNotificationView else { return }
            notiView.imageView.image = UIImageNamed("home_selected")
            notiView.titleLab.text = "我饿后文化佛问佛华为"
            notiView.contentLab.text = "问候我和佛我和佛我腹黑我合肥how凤凰网哈佛我和佛为哈佛我粉红微风化我方宏伟佛后悔无法我耳环佛号"
        }
        notification.autoHidden = false
        notification.show()
    }
}
