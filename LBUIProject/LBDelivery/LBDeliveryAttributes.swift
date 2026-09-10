//
//  LBDeliveryAttributes.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/7.
//

import Foundation
import ActivityKit

/// 外卖配送 Live Activity 共享数据模型
/// 主 App 与 LBDeliveryWidget 两个 target 共同编译本文件（数据契约）
/// 静态属性 = 发起时确定不再变化；ContentState = 持续更新的动态状态
@available(iOS 16.1, *)
struct LBDeliveryAttributes: ActivityAttributes {

    /// 动态状态：每次 update 刷新
    public struct ContentState: Codable, Hashable {
        /// 距目的地剩余距离（km），5.0 → 0
        var remainingDistance: Double
        /// 配送进度 0~1（已用时 / 75s）
        var progress: Double
        /// 状态文案：「骑手正在飞奔中」/「已送达」
        var statusText: String
        /// 结束态标记（锁屏卡片切换为「已送达」样式）
        var isDelivered: Bool
    }

    /// 订单号（静态，多订单时锁屏堆叠/灵动岛长按切换的区分标识）
    let orderID: String
    /// 目的地（静态）
    let destination: String
    /// 骑手名（静态）
    let riderName: String
}

// MARK: - 桌面小组件数据契约（主 App 写入 App Group，LBDeliveryWidget 读取）
/// 只传「不可变配置」：配送进度可由 startedAt + 匀速参数本地推演，
/// Widget 据此预计算整条 timeline（系统按 entry 时间自动切换，不消耗刷新预算）
struct DeliveryOrderSnapshot: Codable {

    /// 订单号
    let orderID: String
    /// 目的地
    let destination: String
    /// 骑手名
    let riderName: String
    /// 发起时间戳（推演进度的基准）
    let startedAt: TimeInterval
    /// 配送总时长（秒），demo 固定 75
    let duration: TimeInterval
    /// 更新步长（秒），demo 固定 5（timeline entry 间隔）
    let updateInterval: TimeInterval
    /// 总距离（km），demo 固定 5.0
    let totalDistance: Double
}
