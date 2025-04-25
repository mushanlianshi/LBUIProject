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
// 自动连接wifi， 类似点击酒店投屏，自动连接当前房间的wifi

class LBConnectWifiAutoController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
