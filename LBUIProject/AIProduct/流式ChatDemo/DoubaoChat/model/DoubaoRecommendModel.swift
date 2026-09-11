//
//  DoubaoRecommendModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// 推荐问卡片 model（回答结束后追加；点击 chip = 以该问题发起新一轮对话）
struct DoubaoRecommendModel: Identifiable, Hashable, Codable {

    let id = UUID()
    /// 推荐问题列表
    let questions: [String]

    static func == (lhs: DoubaoRecommendModel, rhs: DoubaoRecommendModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
