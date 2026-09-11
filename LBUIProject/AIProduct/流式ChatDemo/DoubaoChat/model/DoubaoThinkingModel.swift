//
//  DoubaoThinkingModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// 思考过程块 model（豆包「深度思考」交互）
///
/// 生命周期：插入（isStreaming=true, isExpanded=true 流式展开增长）
///         → thinkingEnd（isStreaming=false, isExpanded=false 折叠成一行摘要）
///         → 用户点击头部可随时切换 isExpanded（reconfigure 刷新，不动结构）
struct DoubaoThinkingModel: Identifiable, Hashable, Codable {

    let id = UUID()
    /// 思考内容（流式增长）
    var text: String = ""
    /// 流式中：头部显示 spinner，禁止折叠
    var isStreaming = true
    /// 展开态。流式中强制 true；结束后默认收起，点击切换
    var isExpanded = true
    /// 思考用时（秒，结束态展示「已深度思考 · 用时 Ns」）
    var elapsedSeconds: Int = 0

    static func == (lhs: DoubaoThinkingModel, rhs: DoubaoThinkingModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
