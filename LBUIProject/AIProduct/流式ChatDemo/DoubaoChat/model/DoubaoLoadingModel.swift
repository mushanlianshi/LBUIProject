//
//  DoubaoLoadingModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/12.
//

import Foundation

/// 加载占位 model（豆包式「回答前的等待动画」）
/// 生命周期：发送问题 → 插入 loading 卡（三点跳动）→ 2 秒后服务端「首字返回」
/// → 移除 loading 卡 → 思考块/正文开始流式输出。
/// 纯 UI 态：不落库（DAO 恢复时也会剥离），杀 App 不残留
struct DoubaoLoadingModel: Identifiable, Hashable, Codable {

    let id = UUID()

    // MARK: - 手动 Codable（let id 自动合成会把随机 id 编进去，解码不一致；
    // 无任何持久化字段：编码为空对象，解码还原为空模型）
    init() {}

    init(from decoder: Decoder) throws {}

    func encode(to encoder: Encoder) throws {}

    static func == (lhs: DoubaoLoadingModel, rhs: DoubaoLoadingModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
