//
//  LBCommonParameterPlugin.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import Foundation
import Moya

// MARK: - 公共参数注入插件
/// Moya PluginType：请求发出前（prepare 阶段）自动注入
/// 1. 公共 header：token / deviceId / platform / appVersion
/// 2. 公共 body 参数：有 JSON body 的请求合并公共字段（GET 无 body 不受影响）
/// 对业务调用方完全透明，业务 Target 只声明自己的参数
final class LBCommonParameterPlugin: PluginType {

    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        var request = request
        let params = LBCommonParameters.shared

        /// 1. 公共 header
        params.commonHeaders.forEach { request.setValue($1, forHTTPHeaderField: $0) }

        /// 2. 公共 body 参数：仅 JSON body 请求合并（Moya 的 JSONEncoding 会把参数写入 httpBody）
        if let bodyData = request.httpBody,
           let bodyDict = (try? JSONSerialization.jsonObject(with: bodyData)) as? [String: Any] {
            var merged = bodyDict
            params.commonBodyParameters.forEach { merged[$0] = $1 }
            request.httpBody = try? JSONSerialization.data(withJSONObject: merged)
        }
        return request
    }
}
