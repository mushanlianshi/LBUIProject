//
//  LBVerifyVCDisappearController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/9/13.
//

import Foundation

/// modalPresentationStyle是custom的   presentingVC不会走disappear会调    因为没有在视图栈中移除  可以看层级图   只有移除了才会走VC的声明周期会调
/// 设置成fullScreen后就会走声明周期了  这个时候视图栈里也没用presentingVC了
/// https://juejin.cn/post/7032937831286702094
///https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457-CH2-SW1
class LBVerifyVCDisappearController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "modal style"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "弹出VC", style: .done, target: self, action: #selector(presentButtonClicked))
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: backButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("LBLog presenting controller  viewWillDisappear ------")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("LBLog presenting controller  viewDidDisappear ------")
    }
    
    @objc private func presentButtonClicked() {
         let vc = LBVerifyCustomModalController()
        self.present(vc, animated: true)
    }
    
    @objc private func backButtonClicked() {
//        changeFullOrientationButtonClicked()
        self.navigationController?.popViewController(animated: false)
    }

    
}




/// modalPresentationStyle是custom的   presentingVC不会走disappear会调    因为没有在视图栈中移除  可以看层级图   只有移除了才会走VC的声明周期会调
/// 设置成fullScreen后就会走声明周期了  这个时候视图栈里也没用presentingVC了
/// https://juejin.cn/post/7032937831286702094
///https://developer.apple.com/library/archive/featuredarticles/ViewControllerPGforiPhoneOS/index.html#//apple_ref/doc/uid/TP40007457-CH2-SW1
class LBVerifyCustomModalController: UIViewController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red.withAlphaComponent(0.4)
        
        let button = UIButton.blt.initWithTitle(title: "返回", font: .blt.normalFont(16), color: .white, target: self, action: #selector(backButtonClicked), image: nil)
        button.backgroundColor = .blt.f6BackgroundColor()
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    
    @objc private func backButtonClicked() {
        self.dismiss(animated: true)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("LBLog presented controller  viewWillAppear =======")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LBLog presented controller  viewDidAppear ====")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("LBLog presented controller  viewWillDisappear =======")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("LBLog presented controller  viewDidDisappear ====")
        
    }
}
