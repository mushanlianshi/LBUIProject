//
//  LBCommonParameters.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import Foundation
import UIKit

// MARK: - 公共参数管理
/// token、设备信息的统一出口：
/// - token：UserDefaults 读写（key 见 tokenKey），登录后调 updateToken 写入
/// - deviceId：首次取时生成 UUID 缓存，之后直接读缓存
/// - 设备机型 / 系统版本 / App 版本：实时取（每次调用时计算，量级极小）
final class LBCommonParameters {

    static let shared = LBCommonParameters()

    private let tokenKey = "lb_user_token"
    private let deviceIdKey = "lb_device_id"

    private init() {}

    // MARK: - Token

    var token: String {
        UserDefaults.standard.string(forKey: tokenKey) ?? ""
    }

    static func updateToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: shared.tokenKey)
    }

    static func clearToken() {
        UserDefaults.standard.removeObject(forKey: shared.tokenKey)
    }

    // MARK: - 设备信息

    /// 设备唯一标识：首次生成 UUID 缓存，之后复用
    var deviceId: String {
        if let cached = UserDefaults.standard.string(forKey: deviceIdKey) {
            return cached
        }
        let newId = UUID().uuidString
        UserDefaults.standard.set(newId, forKey: deviceIdKey)
        return newId
    }

    /// 设备机型（如 iPhone15,2）
    var machineModel: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        return withUnsafeBytes(of: &systemInfo.machine) { raw in
            String(decoding: raw.prefix(while: { $0 != 0 }), as: UTF8.self)
        }
    }

    /// 系统版本（如 17.4.1）
    var systemVersion: String {
        UIDevice.current.systemVersion
    }

    /// App 版本号（CFBundleShortVersionString）
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    // MARK: - 公共参数集合（由 Plugin 在请求发出前自动注入）

    /// 公共 header：每个请求自动携带
    var commonHeaders: [String: String] {
        [
            "token": token,
            "deviceId": deviceId,
            "platform": "iOS",
            "appVersion": appVersion,
        ]
    }

    /// 公共 body 参数：有 JSON body 的请求自动合并（GET 无 body 不受影响）
    var commonBodyParameters: [String: Any] {
        [
            "deviceId": deviceId,
            "platform": "iOS",
            "appVersion": appVersion,
            "systemVersion": systemVersion,
            "deviceModel": machineModel,
        ]
    }
}
