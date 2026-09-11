//
//  DoubaoMarkdownModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// AI 正文 model（流式增长）
/// Hashable/== 只看 id：文本每拍变化但 id 不变 → 结构 diff 为空，
/// 内容刷新走 reconfigureItems（见 DoubaoChatItem 注释）
/// Codable：随整轮 JSON 落库；renderedHeight 一并持久化，历史恢复时 cell 直接采用缓存高度
struct DoubaoMarkdownModel: Identifiable, Hashable, Codable {

    let id = UUID()
    /// 已到达的正文（流式中持续追加）
    var text: String = ""
    /// 流式标记：cell 据此决定是否显示光标
    var isStreaming = true
    /// 渲染高度缓存（WebView 回传后写回）：
    /// 流式中每拍更新；终态后滚动复用/历史加载时 cell 直接采用，不再走高度回调（防跳变+布局风暴）
    var renderedHeight: CGFloat = 0
    /// 是否历史记录（将来持久层恢复时置 true；当前 demo 无历史入口，模型层先备好）
    var isFromHistory = false

    static func == (lhs: DoubaoMarkdownModel, rhs: DoubaoMarkdownModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
