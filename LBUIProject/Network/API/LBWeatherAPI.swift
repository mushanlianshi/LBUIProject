//
//  LBWeatherAPI.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import Foundation
import Moya
import Alamofire

// MARK: - 模型（自旧 APIClient.swift 迁移）
/// 「市→下属县/区」天气预报搜索结果
struct SearchResult: Identifiable {
    let id = UUID()
    /// 县/区名，如「西湖区」「桐庐县」
    let countyName: String
    /// 所属市名，如「杭州」
    let cityName: String
    /// 实时温度（℃）
    let temperature: Double
    /// 天气描述（WMO code 转中文）
    let weatherDescription: String
    /// 风速（km/h）
    let windSpeed: Double
    /// 是否白天
    let isDay: Bool
}

/// Open-Meteo 响应模型
struct OpenMeteoWeatherResponse: Decodable {
    struct CurrentWeather: Decodable {
        let temperature: Double
        let windSpeed: Double
        let windDirection: Double
        let weatherCode: Int
        /// 1 白天 0 夜晚
        let isDay: Int
        let time: String

        enum CodingKeys: String, CodingKey {
            case temperature
            case windSpeed = "windspeed"
            case windDirection = "winddirection"
            case weatherCode = "weathercode"
            case isDay = "is_day"
            case time
        }
    }

    let currentWeather: CurrentWeather?

    enum CodingKeys: String, CodingKey {
        case currentWeather = "current_weather"
    }
}

// MARK: - 地理编码模型
/// Open-Meteo Geocoding 响应（https://geocoding-api.open-meteo.com/v1/search）
struct LBGeocodingResponse: Decodable {
    /// GeoNames 数据库的地点 id（稳定唯一，用作 List 标识）
    struct GeoResult: Decodable, Identifiable {
        let id: Int
        /// 地点名（如「杭州」）
        let name: String
        let latitude: Double
        let longitude: Double
        /// 海拔（米）
        let elevation: Double?
        /// 人口
        let population: Int?
        /// 国家（language=zh 时为「中国」）
        let country: String?
        /// 一级行政区（省，如「浙江」）
        let admin1: String?
        /// 二级行政区（市，如「杭州市」）
        let admin2: String?
        let timezone: String?
    }

    let results: [GeoResult]?
}

// MARK: - 业务错误
enum LBSearchError: LocalizedError {
    case cityNotFound

    var errorDescription: String? {
        switch self {
        case .cityNotFound:
            return "未收录该城市，目前支持：杭州、北京、上海、广州"
        }
    }
}

// MARK: - 天气 API（新网络层第一个业务示例）
/// 演示「全路径第三方接口」：isFullPath = true（不拼 baseURL）、
/// isRawResponse = true（Open-Meteo 无 {code,message,data} 壳，直接解码原始响应）
enum LBWeatherAPI: LBTargetType {

    /// 按经纬度查县/区实时天气
    case countyWeather(latitude: Double, longitude: Double)

    /// 按城市名查地理坐标与城市信息（Geocoding）。
    /// 注意：Open-Meteo Geocoding 不支持 offset 翻页，count 为单次返回上限（1~100）——
    /// 需分页的场景一次拉全量（count=100），由客户端切片分页
    case cityCoordinate(name: String, count: Int)

    // MARK: TargetType
    /// baseURL 走协议默认实现（LBNetworkConfig 环境域名）；
    /// 本 API 全是全路径接口（isFullPath = true），endpointClosure 直接用 path 整体替换 URL，
    /// baseURL 实际不参与——无需覆写
    var path: String {
        switch self {
        case .countyWeather:
            return "https://api.open-meteo.com/v1/forecast"
        case .cityCoordinate:
            return "https://geocoding-api.open-meteo.com/v1/search"
        }
    }

    var method: Moya.Method { .get }

    var task: Moya.Task {
        switch self {
        case .countyWeather(let latitude, let longitude):
            return .requestParameters(
                parameters: [
                    "latitude": String(format: "%.4f", latitude),
                    "longitude": String(format: "%.4f", longitude),
                    "current_weather": "true",
                    "timezone": "Asia/Shanghai",
                ],
                encoding: URLEncoding.default)
        case .cityCoordinate(let name, let count):
            return .requestParameters(
                parameters: [
                    "name": name,
                    "count": String(count),
                    "language": "zh",
                    "format": "json",
                ],
                encoding: URLEncoding.default)
        }
    }

    // MARK: LBTargetType
    var isFullPath: Bool { true }
    var isRawResponse: Bool { true }

    // MARK: 日志开关示例（默认全局 false，见 LBNetworkConfig）
    /// 单请求开启示例：仅本 API 打印响应（全局开关不动）
    var logResponse: Bool { true }
    /// 单请求关闭示例：全局开了打印，仅本 API 静默
    var logRequest: Bool { true }
}

// MARK: - 市下属县/区数据
extension LBWeatherAPI {

    struct County {
        let name: String
        let latitude: Double
        let longitude: Double
    }

    /// 「杭州市」/「杭州 」都归一成「杭州」后查表
    static func counties(in city: String) -> [County]? {
        let key = city
            .replacingOccurrences(of: "市", with: "")
            .trimmingCharacters(in: .whitespaces)
        return cityMap[key]
    }

    private static let cityMap: [String: [County]] = [
        "杭州": [
            County(name: "西湖区", latitude: 30.24, longitude: 120.13),
            County(name: "余杭区", latitude: 30.42, longitude: 120.01),
            County(name: "临安区", latitude: 30.32, longitude: 119.72),
            County(name: "桐庐县", latitude: 29.79, longitude: 119.69),
            County(name: "淳安县", latitude: 29.61, longitude: 119.04),
        ],
        "北京": [
            County(name: "朝阳区", latitude: 39.92, longitude: 116.43),
            County(name: "海淀区", latitude: 39.96, longitude: 116.30),
            County(name: "丰台区", latitude: 39.86, longitude: 116.29),
            County(name: "通州区", latitude: 39.91, longitude: 116.66),
            County(name: "延庆区", latitude: 40.46, longitude: 115.98),
        ],
        "上海": [
            County(name: "浦东新区", latitude: 31.22, longitude: 121.54),
            County(name: "徐汇区", latitude: 31.19, longitude: 121.44),
            County(name: "闵行区", latitude: 31.11, longitude: 121.38),
            County(name: "嘉定区", latitude: 31.38, longitude: 121.27),
            County(name: "崇明区", latitude: 31.62, longitude: 121.40),
        ],
        "广州": [
            County(name: "天河区", latitude: 23.12, longitude: 113.36),
            County(name: "越秀区", latitude: 23.13, longitude: 113.27),
            County(name: "番禺区", latitude: 23.00, longitude: 113.38),
            County(name: "南沙区", latitude: 22.80, longitude: 113.53),
            County(name: "从化区", latitude: 23.54, longitude: 113.59),
        ],
    ]

    /// WMO weather code -> 中文描述
    static func weatherDescription(for code: Int) -> String {
        switch code {
        case 0: return "晴"
        case 1: return "基本晴"
        case 2: return "局部多云"
        case 3: return "阴"
        case 45, 48: return "雾"
        case 51, 53, 55: return "毛毛雨"
        case 56, 57: return "冻毛毛雨"
        case 61: return "小雨"
        case 63: return "中雨"
        case 65: return "大雨"
        case 66, 67: return "冻雨"
        case 71: return "小雪"
        case 73: return "中雪"
        case 75: return "大雪"
        case 77: return "雪粒"
        case 80, 81, 82: return "阵雨"
        case 85, 86: return "阵雪"
        case 95: return "雷暴"
        case 96, 99: return "雷暴伴冰雹"
        default: return "未知天气(\(code))"
        }
    }
}
