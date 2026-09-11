//
//  DoubaoQARoundModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// 一轮问答模型（主流 AI 对话的数据层结构：一轮 = 一条 Message）
/// 对齐持久层语义：question 与轮次 id 由本模型统一持有（即「答的模型管理问的问题、问的 id」），
/// 答侧是按事件流顺序排列的卡片序列（answerItems）。
///
/// UI 层映射（Diffable）：
/// - .question(id) section ← userModel 一项
/// - .answer(id) section   ← answerItems 拍平成 item（复用/diff 粒度是 cell 级）
///
/// Codable：一轮 = DB 一行（question + answerItems 整体 JSON），持久化与恢复的最小单元
struct DoubaoQARoundModel: Codable {

    /// 轮次 id（问/答两个 section 用它关联；也是 diffable 的 section identifier 载体）
    let id = UUID()
    /// 本轮用户问题（问的气泡模型，question 文本即 userModel.text）
    let userModel: DoubaoUserModel
    /// 答侧卡片序列（思考块/正文/找人卡片/推荐问，按事件流顺序）
    var answerItems: [DoubaoChatItem] = []
}
