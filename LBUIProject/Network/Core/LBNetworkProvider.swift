//
//  LBNetworkProvider.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import Foundation
import Combine
import Moya

// MARK: - 业务 Target 协议
/// 业务接口枚举遵守本协议即可获得完整网络能力。
/// 将来若要脱离 Moya 直接用 Alamofire：只重写本文件（Provider）内部实现，
/// 业务 Target 与所有调用方零改动——它们只依赖本协议，不感知底层引擎
protocol LBTargetType: TargetType {
    /// 全路径接口（第三方直连，path 为完整 URL）：true 时不拼 baseURL
    var isFullPath: Bool { get }
    /// 第三方原始响应（无 {code,message,data} 统一壳）：true 时跳过解壳，直接解码响应体
    var isRawResponse: Bool { get }
    /// 打印请求地址与参数。默认取全局 LBNetworkConfig.logRequestEnabled；单 Target 覆写可独立开启
    var logRequest: Bool { get }
    /// 打印响应结果（状态码 + 响应体）。默认取全局 LBNetworkConfig.logResponseEnabled；单 Target 覆写可独立开启
    var logResponse: Bool { get }
}

extension LBTargetType {
    var isFullPath: Bool { false }
    var isRawResponse: Bool { false }
    var logRequest: Bool { LBNetworkConfig.logRequestEnabled }
    var logResponse: Bool { LBNetworkConfig.logResponseEnabled }
    var headers: [String: String]? { nil }
}

// MARK: - 统一响应壳
/// 后端标准响应结构（code == 200 才算成功）
struct APIResponse<T: Decodable>: Decodable {
    let code: Int
    let message: String
    let data: T?
}

// MARK: - 统一入口 Provider
/// 网络层唯一入口，编排完整链路：
/// 公共参数注入（Plugin）→ 请求 → 解壳 → code 分流（200/5000/5005/其他）→ 出业务模型
///
/// 两种用法：
/// 1. Combine（默认）：`provider.request(.xxx, type: Model.self)` 拿 AnyPublisher 继续管道
/// 2. 回调版：`provider.request(.xxx, type: Model.self) { result in }`，
///    callback 为 optional，默认 nil；传了内部自动订阅回调，返回值可忽略
final class LBNetworkProvider<T: LBTargetType> {

    /// callback 模式下的内部订阅持有（Provider 一般长命，随 App 存活）
    private var cancellables = Set<AnyCancellable>()

    private let moyaProvider: MoyaProvider<T>

    init(plugins: [PluginType] = [LBCommonParameterPlugin()]) {
        /// 全路径支持：isFullPath 时直接以 path（完整 URL）构造 Endpoint，不经过 baseURL 拼接。
        /// Moya 15 的 Endpoint.url 是只读属性（url(_:) builder 已移除），需重建实例
        let endpointClosure = { (target: T) -> Endpoint in
            guard target.isFullPath else {
                return MoyaProvider.defaultEndpointMapping(for: target)
            }
            return Endpoint(url: target.path,
                            sampleResponseClosure: { .networkResponse(200, target.sampleData) },
                            method: target.method,
                            task: target.task,
                            httpHeaderFields: target.headers)
        }
        self.moyaProvider = MoyaProvider<T>(endpointClosure: endpointClosure,
                                             plugins: plugins)
    }

    // MARK: - 统一请求入口
    @discardableResult
    func request<Response: Decodable>(_ target: T,
                                      type: Response.Type,
                                      callback: ((Result<Response, LBNetworkError>) -> Void)? = nil)
        -> AnyPublisher<Response, LBNetworkError> {

        logRequestIfNeeded(target)

        let publisher = performRequest(target)
            .flatMap { response -> AnyPublisher<Response, LBNetworkError> in
                if target.isRawResponse {
                    return Self.decodeRaw(response.data)
                }
                return Self.decodeShelled(response.data)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()

        /// 回调版：传了 callback 内部订阅并回调；不传则用返回的 publisher 走 Combine 管道
        if let callback {
            publisher
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        callback(.failure(error))
                    }
                }, receiveValue: { callback(.success($0)) })
                .store(in: &cancellables)
        }
        return publisher
    }

    // MARK: - 日志
    /// 请求日志：最终地址（baseURL/全路径拼接后）+ task 参数（业务参数，公共参数在 Plugin 注入后才可见）
    private func logRequestIfNeeded(_ target: T) {
        guard target.logRequest else { return }
        let endpoint = moyaProvider.endpoint(target)
        debugPrint("LBLog [Net] ⬆️ [\(target.method.rawValue)] \(endpoint.url)")
        switch target.task {
        case .requestParameters(let parameters, _):
            debugPrint("LBLog [Net] ⬆️ 参数 \(parameters)")
        case .requestPlain:
            debugPrint("LBLog [Net] ⬆️ 参数 无")
        default:
            debugPrint("LBLog [Net] ⬆️ 参数类型 \(target.task)")
        }
    }

    /// 响应日志：状态码 + 响应体（超长截断到 2000 字符防刷屏）；失败分支同样打印
    private func logResponseIfNeeded(_ target: T, result: Result<Moya.Response, MoyaError>) {
        guard target.logResponse else { return }
        switch result {
        case .success(let response):
            let body = String(data: response.data, encoding: .utf8) ?? "<非UTF8数据>"
            debugPrint("LBLog [Net] ⬇️ [\(response.statusCode)] \(body.prefix(2000))")
        case .failure(let error):
            debugPrint("LBLog [Net] ⬇️ 请求失败 \(error)")
        }
    }

    // MARK: - 请求执行（回调版 API 包 Combine）
    /// Moya 的 Combine 扩展（requestPublisher）在独立模块 Moya/Combine，项目只装了主模块，
    /// 这里用回调 API + Deferred/Future 包装：Deferred 保证每次订阅才真正发起请求（惰性），
    /// Future 把回调转成单一输出；Moya 默认回调主线程，下游另有 receive(on: main) 兜底
    private func performRequest(_ target: T) -> AnyPublisher<Response, LBNetworkError> {
        Deferred { [moyaProvider] in
            Future<Response, LBNetworkError> { promise in
                moyaProvider.request(target) { result in
                    self.logResponseIfNeeded(target, result: result)
                    switch result {
                    case .success(let response):
                        promise(.success(response))
                    case .failure(let error):
                        promise(.failure(.underlying(error)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - 解码分流
    /// 第三方原始响应：直接解码为业务模型
    private static func decodeRaw<Response: Decodable>(_ data: Data) -> AnyPublisher<Response, LBNetworkError> {
        Result { try JSONDecoder().decode(Response.self, from: data) }
            .publisher
            .mapError { LBNetworkError.decodeFailed($0) }
            .eraseToAnyPublisher()
    }

    /// 标准壳响应：解 APIResponse 后按 code 分流
    private static func decodeShelled<Response: Decodable>(_ data: Data) -> AnyPublisher<Response, LBNetworkError> {
        let wrapped: APIResponse<Response>
        do {
            wrapped = try JSONDecoder().decode(APIResponse<Response>.self, from: data)
        } catch {
            return Fail(error: LBNetworkError.decodeFailed(error)).eraseToAnyPublisher()
        }

        switch wrapped.code {
        case 200:
            guard let model = wrapped.data else {
                return Fail(error: LBNetworkError.emptyData).eraseToAnyPublisher()
            }
            return Just(model).setFailureType(to: LBNetworkError.self).eraseToAnyPublisher()

        case 5000:
            /// 需要登录：广播事件（跳登录页由订阅方执行），调用方收到 .needLogin
            LBNetworkBus.needLogin.send()
            return Fail(error: LBNetworkError.needLogin).eraseToAnyPublisher()

        case 5005:
            /// 会话失效：自动清 token（即退出登录的全部默认动作，UI 不做处理）
            LBCommonParameters.clearToken()
            LBNetworkBus.sessionExpired.send()
            return Fail(error: LBNetworkError.sessionExpired).eraseToAnyPublisher()

        default:
            return Fail(error: LBNetworkError.business(code: wrapped.code, message: wrapped.message))
                .eraseToAnyPublisher()
        }
    }
}
