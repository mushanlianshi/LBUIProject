//
//  LBNetworkConfig.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import Foundation

// MARK: - 网络环境
enum LBNetworkEnvironment: String {
    case debug
    case pre
    case prod
}

// MARK: - 网络配置
/// 环境判定：优先取 scheme 环境变量 runEnvironment（Debug 配置默认 pre），
/// 无值时按编译宏兜底（Debug 构建 → debug，Release 构建 → prod）
enum LBNetworkConfig {

    static let environment: LBNetworkEnvironment = {
        if let raw = ProcessInfo.processInfo.environment["runEnvironment"],
           let env = LBNetworkEnvironment(rawValue: raw) {
            return env
        }
        #if DEBUG
        return .debug
        #else
        return .prod
        #endif
    }()

    /// 当前环境 base URL（业务接口统一走这里拼路径；全路径接口不经过它）
    static var baseURL: URL {
        switch environment {
        case .debug:
            return URL(string: "https://debug.api.example.com")!   // TODO: 换真实域名
        case .pre:
            return URL(string: "https://pre.api.example.com")!     // TODO: 换真实域名
        case .prod:
            return URL(string: "https://api.example.com")!         // TODO: 换真实域名
        }
    }

    // MARK: - 网络日志全局开关
    /// 打印请求地址与参数。默认 false 不打印。
    /// 全局开启：`LBNetworkConfig.logRequestEnabled = true`（如 AppDelegate 按环境设置）
    /// 单请求开启：在业务 Target 里覆写 `var logRequest: Bool { true }`（优先级高于全局）
    static var logRequestEnabled = false

    /// 打印请求响应结果（状态码 + 响应体）。默认 false 不打印。
    /// 单请求覆写：`var logResponse: Bool { true }`
    static var logResponseEnabled = false
}
