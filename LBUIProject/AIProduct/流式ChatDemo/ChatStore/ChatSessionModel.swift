//
//  ChatSessionModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/3.
//

import Foundation

/// 聊天会话模型：一个 ChatViewController 页面生命周期 = 一个会话
final class ChatSessionModel {
    /// 会话 id（UUID().uuidString，同时是 DB 主键）
    let id: String
    /// 会话标题（首条用户消息前 20 字，会话列表展示用）
    var title: String
    /// 创建时间戳
    let createdAt: TimeInterval
    /// 最后活跃时间戳（会话列表按此倒序）
    var updatedAt: TimeInterval

    init(id: String, title: String, createdAt: TimeInterval, updatedAt: TimeInterval) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
