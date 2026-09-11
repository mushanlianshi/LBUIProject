//
//  DoubaoUnsupportedModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// 未知卡片 model（前向兼容兜底）
///
/// 场景：服务端发布新卡片类型（如「地图卡片」），老版本 App 无对应 case——
/// wire format 解析失败时兜底构造本 model：
/// - rawType / rawPayload 原样保存：能落库、能多端同步（新版本/其他端可正常解析）
/// - UI 层渲染「暂不支持」占位，不崩溃、不丢消息
///
/// 真实产品的解析入口示意（wire format → item）：
///   guard let item = try? DoubaoChatItem.decode(json) else {
///       return .unsupported(DoubaoUnsupportedModel(rawType: json["type"], rawPayload: json))
///   }
struct DoubaoUnsupportedModel: Identifiable, Hashable, Codable {

    let id = UUID()
    /// 服务端原始卡片类型标识（如 "map_card_v2"，占位文案展示 + 排查用）
    let rawType: String
    /// 原始 payload（原样 JSON 字符串，存库/同步透传）
    let rawPayload: String
    /// 展示名（rawType 映射不出的友好文案，如「新卡片」；缺省「消息」）
    let displayName: String

    init(rawType: String, rawPayload: String, displayName: String? = nil) {
        self.rawType = rawType
        self.rawPayload = rawPayload
        self.displayName = displayName ?? Self.fallbackName(for: rawType)
    }

    /// rawType 推导占位名（服务端命名习惯 → 中文展示）
    private static func fallbackName(for rawType: String) -> String {
        if rawType.contains("map") { return "地图卡片" }
        if rawType.contains("video") { return "视频卡片" }
        if rawType.contains("audio") { return "语音卡片" }
        if rawType.contains("image") { return "图片卡片" }
        return "新卡片"
    }

    // MARK: - 手动 Codable（id 是 let UUID()，自动合成会把它编进去导致解码不一致）
    private enum CodingKeys: String, CodingKey {
        case rawType, rawPayload, displayName
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        rawType = try c.decode(String.self, forKey: .rawType)
        rawPayload = try c.decode(String.self, forKey: .rawPayload)
        displayName = try c.decodeIfPresent(String.self, forKey: .displayName)
            ?? Self.fallbackName(for: rawType)
    }

    static func == (lhs: DoubaoUnsupportedModel, rhs: DoubaoUnsupportedModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
