//
//  DoubaoChatItem.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/11.
//

import Foundation

/// Diffable Section：一轮问答拆两个 section（同用一轮的 UUID 关联）——
/// .question 装用户气泡（无背景），.answer 装该轮全部回答卡片（整段背景卡片）。
/// 分开的意义：答的 section 可以整体挂 background decoration（回答区一张大卡片），
/// 问的气泡保持独立视觉；同一轮问答靠 UUID 成对关联
enum DoubaoChatSection: Hashable {
    /// 一轮的「问」（用户气泡）
    case question(UUID)
    /// 同一轮的「答」（AI 卡片序列：思考块/正文/找人卡片/推荐问……）
    case answer(UUID)
}

/// Diffable Item：一屏内所有卡片类型的枚举（多卡片流式对话的核心数据契约）
///
/// 关联的各 model 遵循「Hashable / == 只看 id」约定，由此形成两层更新机制：
/// - 结构变化（卡片插入/删除）→ id 不同 → snapshot diff 自动计算 insert/delete
/// - 内容变化（流式文本增长、折叠态切换，id 不变）→ diff 结果为空，
///   由 VC 调 reconfigureItems([item]) 定向刷新（iOS 14 fallback reloadItems）
enum DoubaoChatItem: Hashable {
    /// 用户消息气泡
    case user(DoubaoUserModel)
    /// 思考过程块（流式中展开增长，结束后折叠，可点击切换）
    case thinking(DoubaoThinkingModel)
    /// AI 正文（流式增长）
    case markdown(DoubaoMarkdownModel)
    /// 找人卡片（正文流式中途穿插插入）
    case contact(DoubaoContactModel)
    /// 推荐问卡片（回答结束后追加）
    case recommend(DoubaoRecommendModel)
}
