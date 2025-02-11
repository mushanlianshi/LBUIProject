//
//  LBChangeIconWithoutAlertController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/11.
//

import Foundation

enum AppIconType: String {
    case normal = "AppIcon"
    case appIcon1 = "AppIcon1"
    case appIcon2 = "AppIcon2"
}

fileprivate let currentAppIconKey = "currentAppIcon"

/// 默认更换应用图标需要提前在App内配置好，苹果审核过， app内切换的时候会弹框
/// 现在我们在调用切换图标前先自己present一个透明的Controller，然后在调切换图标，这个时候系统获取当前Controller去present新的系统弹框时，
/// 由于当前alert被dismiss了，所以系统的弹框弹不出来。
/// 我们也可以利用这种方法，来隐藏一些不是权限，不需要应用同意的系统alert， 比如这种提示类的alert
/// https://mp.weixin.qq.com/s?__biz=Mzg3MDk3NzUzNw==&mid=2247486755&idx=1&sn=44f178bc937a93412336a634042daa9c&chksm=ce84d44df9f35d5b7df6760cc94767a48e015073c930e45e5093554ddc070090d92e29a92082&scene=21#wechat_redirect
class LBChangeIconWithoutAlertController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "更换图标"
        view.backgroundColor = .white
        setupUI()
    }
    
    
    func setupUI() {
        let stackView = UIStackView.blt.initStackView(spacing: 15, axis: .vertical)
        let alertChangeBtn = UIButton.blt.initWithTitle(title: "正常更换图标", font: .blt.normalFont(15), color: .blt.threeThreeBlackColor(), target: self, action: #selector(normalChangeBtnClicked))
        
        let withoutAlertChangeBtn = UIButton.blt.initWithTitle(title: "隐藏系统弹框切换图标", font: .blt.normalFont(15), color: .blt.threeThreeBlackColor(), target: self, action: #selector(withoutAlertChangeBtnClicked))
        [alertChangeBtn, withoutAlertChangeBtn].forEach(stackView.addArrangedSubview(_:))
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    
    @objc func normalChangeBtnClicked(){
        guard UIApplication.shared.supportsAlternateIcons else {
            // 不支持
            return
        }
        let name = willChangeName()
        UIApplication.shared.setAlternateIconName(name) { error in
            if let error {
                print("设置 App Icon 出错： \(error)")
            } else {
                print("App Icon 设置成功")
                UserDefaults.standard.setValue(name, forKey: currentAppIconKey)
            }
        }
    }
    
    
    @objc func withoutAlertChangeBtnClicked(){
        guard UIApplication.shared.supportsAlternateIcons else {
            // 不支持
            return
        }

        let transparentVC = LBDismissSystemAlertController()
        transparentVC.modalPresentationStyle = .overFullScreen
        self.present(transparentVC, animated: false) {
            [weak self] in
            guard let self = self else{
                return
            }
            let name = willChangeName()
            UIApplication.shared
                .setAlternateIconName(name) { error in
                if let error {
                    print("设置 App Icon 出错： \(error)")
                } else {
                    print("App Icon 设置成功")
                    UserDefaults.standard.setValue(name, forKey: currentAppIconKey)
                }
            }
        }
    }
    
    
    func willChangeName() -> String {
        guard UIApplication.shared.supportsAlternateIcons else {
            // 不支持
            return AppIconType.normal.rawValue
        }
        var willChangeName = ""
        if currentAppIcon() == .normal || currentAppIcon() == .appIcon2{
            willChangeName = AppIconType.appIcon1.rawValue
        }else{
            willChangeName = AppIconType.appIcon2.rawValue
        }
        return willChangeName
    }
    
    private func currentAppIcon() -> AppIconType {
        guard let currentName = UserDefaults.standard.value(forKey: currentAppIconKey) as? String else { return .normal }
        return AppIconType.init(rawValue: currentName) ?? .normal
    }
}
