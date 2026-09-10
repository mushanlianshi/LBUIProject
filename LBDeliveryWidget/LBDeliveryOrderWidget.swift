//
//  LBDeliveryOrderWidget.swift
//  LBDeliveryWidget
//
//  Created by liu bin on 2026/9/10.
//

import WidgetKit
import SwiftUI

/// 订单配送桌面小组件（普通 WidgetKit，非 Live Activity）
///
/// 与灵动岛的分工：
/// - Live Activity：锁屏/灵动岛/StandBy，高频实时（ActivityKit 或 APNs 驱动）
/// - 本组件：桌面主屏，WidgetKit timeline 机制
///
/// 刷新预算应对（系统每天只给约 40~70 次 timeline 刷新，做不到秒级）：
/// 数据契约只传「不可变配置」（发起时间 + 匀速参数），本组件在 getTimeline 时
/// 一次性预计算未来全部 entries（每 5 秒一拍直到最晚订单送达），系统按 entry
/// 时间自动切换展示 —— 本地时间线切换不消耗刷新预算，效果等同实时跳动；
/// reloadTimelines 仅在订单增减时由主 App 主动触发一次
///
/// App 被杀：数据已在 App Group 共享容器 + 时间线已预计算，桌面照样跑完全程
struct LBDeliveryOrderWidget: Widget {

    let kind = "LBDeliveryOrderWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DeliveryOrderProvider()) { entry in
            DeliveryOrderWidgetView(entry: entry)
        }
        .configurationDisplayName("订单配送")
        .description("桌面查看配送中订单的实时进度（与灵动岛/锁屏卡片同一数据源）")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Entry
private struct DeliveryOrderEntry: TimelineEntry {

    /// 本拍时刻
    let date: Date
    /// 该时刻仍在配送中的订单（已按发起时间倒序，最新在前）
    let activeOrders: [OrderDisplay]

    /// 推演后的单订单展示状态
    struct OrderDisplay {
        let snapshot: DeliveryOrderSnapshot
        let remainingDistance: Double
        let progress: Double
        let statusText: String

        /// 深链跳订单详情（复用灵动岛同一路由：AppDelegate openURL 解析）
        var deepLinkURL: URL? {
            var components = URLComponents()
            components.scheme = "lbuiproject"
            components.host = "deliveryDetail"
            components.queryItems = [URLQueryItem(name: "orderID", value: snapshot.orderID)]
            return components.url
        }
    }

    /// 空态示例（placeholder / 无订单时展示）
    static let empty = DeliveryOrderEntry(date: Date(), activeOrders: [])
}

// MARK: - TimelineProvider
private struct DeliveryOrderProvider: TimelineProvider {

    func placeholder(in context: Context) -> DeliveryOrderEntry {
        .empty
    }

    func getSnapshot(in context: Context, completion: @escaping (DeliveryOrderEntry) -> Void) {
        let orders = SharedOrderStore.loadOrders()
        completion(.init(date: Date(), activeOrders: Self.displayOrders(orders, at: Date())))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DeliveryOrderEntry>) -> Void) {
        let orders = SharedOrderStore.loadOrders()
        let now = Date()

        // 无订单：空态挂 5 分钟兜底（正常路径由主 App reloadTimelines 主动驱动）
        guard !orders.isEmpty else {
            completion(Timeline(entries: [.empty], policy: .after(now.addingTimeInterval(5 * 60))))
            return
        }

        // 预计算：从 now 起，每拍取 updateInterval（demo 5s），直到最晚订单送达
        let latestEnd = orders.map { $0.startedAt + $0.duration }.max() ?? now.timeIntervalSince1970
        let step = orders.map { $0.updateInterval }.max() ?? 5
        var entries: [DeliveryOrderEntry] = []
        var t = now
        while t.timeIntervalSince1970 < latestEnd {
            let active = Self.displayOrders(orders, at: t)
            // 该拍已全部送达则跳过（终态展示交给灵动岛，组件回空态）
            if !active.isEmpty {
                entries.append(.init(date: t, activeOrders: active))
            }
            t = t.addingTimeInterval(step)
        }

        // 收尾：全部送达后回空态，时间线结束
        let endEntry = DeliveryOrderEntry(date: Date(timeIntervalSince1970: latestEnd), activeOrders: [])
        entries.append(endEntry)
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    /// 按时刻推演各订单状态：匀速运动 remainingDistance = totalDistance * (1 - progress)
    /// 送达（elapsed >= duration）即从活跃列表过滤
    private static func displayOrders(_ orders: [DeliveryOrderSnapshot], at date: Date) -> [DeliveryOrderEntry.OrderDisplay] {
        let timestamp = date.timeIntervalSince1970
        return orders
            .filter { timestamp < $0.startedAt + $0.duration }
            .sorted { $0.startedAt > $1.startedAt }  // 最新订单在前（小组件主展示位）
            .map { order in
                let progress = min(max((timestamp - order.startedAt) / order.duration, 0), 1)
                let distance = max(order.totalDistance * (1 - progress), 0)
                return DeliveryOrderEntry.OrderDisplay(
                    snapshot: order,
                    remainingDistance: distance,
                    progress: progress,
                    statusText: progress >= 1 ? "已送达" : (progress == 0 ? "骑手已接单" : "骑手正在飞奔中"))
            }
    }
}

// MARK: - 共享数据读取
/// App Group 数据契约（主 App DeliveryActivityManager 写入同结构 JSON）
private enum SharedOrderStore {

    static let suiteName = "group.zhiyong.test.project"
    static let ordersKey = "lb.delivery.orders"

    static func loadOrders() -> [DeliveryOrderSnapshot] {
        guard let defaults = UserDefaults(suiteName: suiteName),
              let data = defaults.data(forKey: ordersKey) else { return [] }
        return (try? JSONDecoder().decode([DeliveryOrderSnapshot].self, from: data)) ?? []
    }
}

// MARK: - 视图
private struct DeliveryOrderWidgetView: View {

    let entry: DeliveryOrderEntry

    private let themeBlue = Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255)

    var body: some View {
        Group {
            if entry.activeOrders.isEmpty {
                emptyView
            } else if let latest = entry.activeOrders.first {
                // 中尺寸：最新订单主卡 + 其余订单行（各自 Link 深链）
                // 小尺寸：只显示最新订单
                if entry.activeOrders.count > 1 {
                    mediumView(latest: latest, others: Array(entry.activeOrders.dropFirst().prefix(2)))
                } else {
                    orderCard(latest, compact: false)
                }
            }
        }
        .widgetBackground()
    }

    // MARK: 空态
    private var emptyView: some View {
        VStack(spacing: 8) {
            Text("🛵")
                .font(.system(size: 28))
            Text("暂无配送中订单")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
            Text("打开 App「外卖配送灵动岛」发起模拟订单")
                .font(.system(size: 11))
                .foregroundColor(Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: 中尺寸布局
    private func mediumView(latest: DeliveryOrderEntry.OrderDisplay,
                            others: [DeliveryOrderEntry.OrderDisplay]) -> some View {
        HStack(spacing: 12) {
            orderCard(latest, compact: true)
                .frame(maxWidth: .infinity)
            VStack(spacing: 8) {
                ForEach(others, id: \.snapshot.orderID) { order in
                    Link(destination: order.deepLinkURL ?? URL(string: "lbuiproject://deliveryDetail")!) {
                        otherOrderRow(order)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
    }

    /// 最新订单主卡（小尺寸整卡 / 中尺寸左半区）
    @ViewBuilder
    private func orderCard(_ order: DeliveryOrderEntry.OrderDisplay, compact: Bool) -> some View {
        let content = VStack(spacing: 6) {
            HStack(spacing: 6) {
                Text("🛵")
                    .font(.system(size: compact ? 16 : 22))
                Text(order.snapshot.orderID)
                    .font(.system(size: compact ? 12 : 14, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Text(String(format: "%.1f km", order.remainingDistance))
                .font(.system(size: compact ? 20 : 30, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
            ProgressView(value: order.progress)
                .tint(.white.opacity(0.9))
            Text(order.statusText)
                .font(.system(size: compact ? 10 : 11))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
        }
        .padding(12)

        if let url = order.deepLinkURL {
            Link(destination: url) {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(themeBlue)
            }
        } else {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(themeBlue)
        }
    }

    /// 中尺寸右侧其余订单行
    private func otherOrderRow(_ order: DeliveryOrderEntry.OrderDisplay) -> some View {
        HStack(spacing: 8) {
            Text("🛵")
                .font(.system(size: 13))
            VStack(alignment: .leading, spacing: 2) {
                Text(order.snapshot.orderID)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                    .lineLimit(1)
                Text(String(format: "%.1f km · %.0f%%", order.remainingDistance, order.progress * 100))
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255))
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - iOS 17 containerBackground 适配
/// iOS 17+ 必须用 containerBackground（否则组件内容不可见）；16.x 用传统 background
private extension View {
    @ViewBuilder
    func widgetBackground() -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            containerBackground(for: .widget) {
                Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255)
            }
        } else {
            background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
        }
    }
}
