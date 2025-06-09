//
//  LBConnectWifiAutoController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/22.
//

import Foundation
import NetworkExtension

//确保 App 开启了 “Hotspot Configuration” 权限：
//    •    打开 Xcode
//    •    选中项目 target
//    •    前往 Capabilities
//    •    打开 Hotspot Configuration
// 自动连接wifi， 类似点击酒店投屏，自动连接当前房间的wifi, 可以扫酒店电视二维码，从二维码信息中获取当前房间的wifi账号、密码，就知道酒店房间wifi了，然后利用系统弹框直接连。

class LBConnectWifiAutoController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "自动连接wifi"
        view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "连接wifi", style: .done, target: self, action: #selector(connectWifi))
    }
    
    
    @objc func connectWifi() {
        connectToRoomWiFi(ssid: "Shangmei-Guest", password: "4006456999") { result in
            
        }
    }
    
    func connectToRoomWiFi(ssid: String, password: String, completion: @escaping (Bool) -> Void) {
        let configuration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: false)
        configuration.joinOnce = false  // 设置为 true 只连一次，false 则记住连接

        NEHotspotConfigurationManager.shared.apply(configuration) { error in
            if let error = error {
                print("LBLog connect wifi failed \(error)")
                completion(false)
            } else {
                print("✅ Wi-Fi 连接成功")
                completion(true)
            }
        }
    }
}
