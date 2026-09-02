//
//  LBNetworkError.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import Foundation
import Moya

// MARK: - 统一网络错误
/// 调用方只面对这一种错误类型，不再感知 AFError / MoyaError / DecodingError 细节
enum LBNetworkError: Error {

    /// 网络层 / HTTP 层失败（超时、断网、非 2xx 状态码等）
    case underlying(MoyaError)

    /// 响应体解码失败（结构不符 / 非 JSON）
    case decodeFailed(Error)

    /// 业务失败：code != 200（code + 后端 message）
    case business(code: Int, message: String)

    /// code = 200 但 data 为空（无法解码出业务模型）
    case emptyData

    /// code = 5005：会话失效（token 已被网络层清除）
    case sessionExpired

    /// code = 5000：需要登录（已广播 needLogin 事件）
    case needLogin
}

// MARK: - LocalizedError（可直接用于 UI 展示）
extension LBNetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .underlying(let error):
            return "网络请求失败：\(error.localizedDescription)"
        case .decodeFailed:
            return "数据解析失败，请稍后重试"
        case .business(_, let message):
            return message
        case .emptyData:
            return "服务端未返回数据"
        case .sessionExpired:
            return "登录已失效"
        case .needLogin:
            return "请先登录"
        }
    }
}
