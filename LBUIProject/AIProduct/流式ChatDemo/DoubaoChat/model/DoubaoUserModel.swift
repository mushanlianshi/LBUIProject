//
//  DoubaoUserModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// 用户消息 model
/// Hashable/== 只看 id：发送后内容不变，不参与流式更新
/// Codable：随整轮 answerItems JSON 落库（id 稳定编解码，恢复后 upsert 对齐主键）
struct DoubaoUserModel: Identifiable, Hashable, Codable {

    let id = UUID()
    let text: String

    static func == (lhs: DoubaoUserModel, rhs: DoubaoUserModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
