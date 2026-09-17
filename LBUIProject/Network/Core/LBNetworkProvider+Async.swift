//
//  LBNetworkProvider+Async.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/17.
//

import Foundation
import Combine

/// async/await 直调版请求（桥接 Combine 回调的全局唯一桥梁）
///
/// 设计定位：Combine 是这个网络层的原生形态（返回 AnyPublisher），
/// async 版不重写请求链路——只做一次「回调 → continuation」翻译，
/// 与其每个 VM 方法里各写一座 withCheckedContinuation 桥，
/// 不如网络层一座桥全局共享，业务侧从此直译：
///
///     // VM 里不再有 continuation：
///     func refresh() async {
///         do {
///             let list = try await provider.requestAsync(.cityCoordinate(name: "杭州", count: 10),
///                                                        type: LBGeocodingResponse.self)
///         } catch {
///             // LBNetworkError 处理
///         }
///     }
///
/// 线程语义：内部复用 request(callback:)，回调在主线程（Combine 链 receive(on: main)），
/// continuation 的 resume 也在主线程——await 恢复后直接安全碰 UI 状态
extension LBNetworkProvider {

    /// async/await 版统一请求入口（成功返回 Response，失败抛 LBNetworkError）
    func requestAsync<Response: Decodable>(_ target: T,
                                           type: Response.Type) async throws -> Response {
        try await withCheckedThrowingContinuation { continuation in
            request(target, type: type) { result in
                switch result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
