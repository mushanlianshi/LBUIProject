//
//  DoubaoActionsModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// 回答操作栏 model（播报/复制/点赞/点踩）
/// 为什么是 item 而非 section footer：点赞状态变化需要 reconfigureItems 增量刷新、
/// 需要随整轮 JSON 落库恢复、需要复用现有 CellRegistration 交互注入——
/// 这些设施全在 item 通道上；footer(supplementary) 适合纯静态装饰，带交互状态是逆水行舟
struct DoubaoActionsModel: Identifiable, Hashable, Codable {

    let id = UUID()
    /// 点赞状态（与点踩互斥；随整轮 JSON 落库，历史恢复状态不丢）
    var isLiked = false
    /// 点踩状态
    var isDisliked = false

    // MARK: - 手动 Codable（let id 自动合成会把随机 id 编进去，解码不一致破坏 diffable 契约）
    private enum CodingKeys: String, CodingKey {
        case isLiked, isDisliked
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        isLiked = try c.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        isDisliked = try c.decodeIfPresent(Bool.self, forKey: .isDisliked) ?? false
    }

    static func == (lhs: DoubaoActionsModel, rhs: DoubaoActionsModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
