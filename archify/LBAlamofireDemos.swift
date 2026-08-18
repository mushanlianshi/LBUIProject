//
//  LBAlamofireDemos.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/18.
//
//  四个 Alamofire 调用 demo（GET / POST / 下载 / 上传），覆盖：
//    - 自定义 Header、自定义 body
//    - 自定义请求拦截器（RequestInterceptor：adapt 注入公共 Header，retry 401 重试）
//    - 自定义响应拦截器（ResponseSerializer：解包 {code,message,data}）
//  与 archify 目录下的架构图对应：Session 接拦截器 → 请求进入主路径 → 响应走自定义序列化。
//
//  注意：LBEnvelopeSerializer 假定后端返回 {code,message,data} 包裹；
//  直接打 https://httpbin.org 时该结构不成立，可换成 .responseDecodable / .responseString 联调。
//

import Foundation
import Alamofire

// MARK: - 公共配置

enum LBDemoConfig {
    static let baseURL = "https://httpbin.org"
    static let token = "demo-token"
}

struct LBDemoUser: Codable {
    let name: String
    let age: Int
}

// MARK: - 自定义请求拦截器（RequestInterceptor）
// 对应架构图里的 RequestAdapter + RequestRetrier 扩展点。
// 每个请求发出前 adapt() 注入公共 Header；请求失败后 retry() 决定是否重试。

final class LBAuthInterceptor: RequestInterceptor {

    /// 请求发出前调用：返回被改写过（加 Header）的 URLRequest。
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var request = urlRequest
        request.setValue("Bearer \(LBDemoConfig.token)", forHTTPHeaderField: "Authorization")
        request.setValue("LBAlamofireDemos/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("zh-Hans", forHTTPHeaderField: "Accept-Language")
        completion(.success(request))
    }

    /// 请求失败后调用：401 未授权最多补一次，并延迟 0.5s（模拟刷新 token 场景）。
    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        if let afError = error.asAFError,
           afError.responseCode == 401,
           request.retryCount < 1 {
            completion(.retryWithDelay(0.5))
        } else {
            completion(.doNotRetry)
        }
    }
}

// MARK: - 响应拦截器（自定义 ResponseSerializer）
// 对应架构图里的 ResponseSerializer 扩展点。
// 统一后端包裹 { code, message, data }：业务码非 0 抛错，业务层拿到的是解包后的 value。

struct LBEnvelope<T: Decodable>: Decodable {
    let code: Int
    let message: String?
    let data: T?
}

enum LBEnvelopeError: Error, LocalizedError {
    case business(code: Int, message: String?)

    var errorDescription: String? {
        switch self {
        case .business(let code, let message):
            return "业务错误 code=\(code) message=\(message ?? "")"
        }
    }
}

final class LBEnvelopeSerializer<T: Decodable>: DataResponseSerializerProtocol {
    typealias SerializedObject = T

    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func serialize(request: URLRequest?,
                   response: HTTPURLResponse?,
                   data: Data?,
                   error: Error?) throws -> T {
        // 1. 底层传输错误优先抛出
        if let error = error { throw error }

        // 2. 状态码校验
        guard let response = response, (200..<300).contains(response.statusCode) else {
            throw AFError.responseValidationFailed(reason: .unacceptableStatusCode(code: response?.statusCode ?? -1))
        }

        // 3. 解包统一包裹，业务码非 0 视为业务错误
        let envelope = try decoder.decode(LBEnvelope<T>.self, from: data ?? Data())
        guard envelope.code == 0 else {
            throw LBEnvelopeError.business(code: envelope.code, message: envelope.message)
        }
        guard let value = envelope.data else {
            throw AFError.responseSerializationFailed(reason: .inputDataNil)
        }
        return value
    }
}

// MARK: - 四个调用 demo

final class LBAlamofireDemos {

    /// 共享 Session：把自定义请求拦截器接在 Session 上，四个调用走同一套拦截逻辑。
    private let session: Session

    init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 30
        session = Session(configuration: configuration, interceptor: LBAuthInterceptor())
    }

    // MARK: 1. GET —— Query 参数 + 自定义 Header + 自定义请求/响应拦截器

    func demoGet(completion: @escaping (Result<LBDemoUser, Error>) -> Void) {
        // 自定义 Query 参数（Parameters）+ 自定义 Header；
        // LBAuthInterceptor 还会额外注入 Authorization / User-Agent 等公共 Header。
        session.request(
            "\(LBDemoConfig.baseURL)/get",
            parameters: ["q": "apple", "page": 1],
            headers: ["X-Demo-Source": "get-demo"]
        )
        .validate()
        .response(responseSerializer: LBEnvelopeSerializer<LBDemoUser>()) { response in
            completion(response.result.mapError { $0 as Error })
        }
    }

    // MARK: 2. POST —— 自定义 body（Encodable 模型 JSON 化）

    func demoPost(completion: @escaping (Result<LBDemoUser, Error>) -> Void) {
        // 自定义 body：Encodable 模型 + JSONParameterEncoder；
        // 若要手写原始 JSON，可改用 requestModifier 直接改 urlRequest.httpBody。
        let body = LBDemoUser(name: "liubin", age: 18)
        session.request(
            "\(LBDemoConfig.baseURL)/post",
            method: .post,
            parameters: body,
            encoder: JSONParameterEncoder.default,
            headers: ["Accept": "application/json"]
        )
        .validate()
        .response(responseSerializer: LBEnvelopeSerializer<LBDemoUser>()) { response in
            completion(response.result.mapError { $0 as Error })
        }
    }

    // MARK: 3. 下载 —— 落到沙盒并跟踪进度

    func demoDownload(progress: @escaping (Double) -> Void,
                      completion: @escaping (Result<URL, Error>) -> Void) {
        let destination = DownloadRequest.suggestedDownloadDestination(for: .cachesDirectory)
        session.download(
            "\(LBDemoConfig.baseURL)/bytes/1048576", // 1MB 测试文件
            to: destination
        )
        .downloadProgress { progress($0.fractionCompleted) }
        .responseURL { response in
            completion(response.result.mapError { $0 as Error })
        }
    }

    // MARK: 4. 上传 —— multipart/form-data（文件 + 文本字段）并跟踪进度

    func demoUpload(fileURL: URL,
                    progress: @escaping (Double) -> Void,
                    completion: @escaping (Result<Void, Error>) -> Void) {
        session.upload(
            multipartFormData: { form in
                form.append(fileURL, withName: "file")                 // 文件字段
                form.append("remark".data(using: .utf8)!, withName: "remark") // 文本字段
            },
            to: "\(LBDemoConfig.baseURL)/post",
            headers: ["X-Demo-Source": "upload-demo"]
        )
        .uploadProgress { progress($0.fractionCompleted) }
        .responseData { response in
            completion(response.result.map { _ in () }.mapError { $0 as Error })
        }
    }
}
