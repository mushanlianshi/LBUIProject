//
//  LBDeliveryLiveActivity.swift
//  LBDeliveryWidget
//
//  Created by liu bin on 2026/9/7.
//

import WidgetKit
import SwiftUI
import ActivityKit

/// 外卖配送 Live Activity（锁屏卡片 + 灵动岛）
/// 灵动岛重点做紧凑态：compactLeading = 骑手图标，compactTrailing = 剩余距离
struct LBDeliveryLiveActivity: Widget {

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LBDeliveryAttributes.self) { context in
            // MARK: 锁屏卡片（参考美团配送卡片）
            LockScreenDeliveryView(context: context)
                .activityBackgroundTint(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
                .activitySystemActionForegroundColor(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255))
        } dynamicIsland: { context in
            DynamicIsland {
                // MARK: 展开态（API 必需，简洁实现）
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Text("🛵")
                        Text(context.attributes.orderID)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(String(format: "%.1f km", context.state.remainingDistance))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 6) {
                        ProgressView(value: context.state.progress)
                            .tint(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255))
                        Text(context.state.statusText)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            } compactLeading: {
                // MARK: 紧凑态左侧：骑手图标（重点打磨）
                Text("🛵")
                    .font(.system(size: 13))
            } compactTrailing: {
                // MARK: 紧凑态右侧：剩余距离实时跳动（重点打磨）
                Text(context.state.isDelivered ? "送达" : String(format: "%.1fkm", context.state.remainingDistance))
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255))
                    .frame(maxWidth: 52)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
            } minimal: {
                // MARK: 最小态（多活动挤压时）：骑手图标 + 进度环
                ZStack {
                    Circle()
                        .trim(from: 0, to: context.state.progress)
                        .stroke(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255), lineWidth: 1.5)
                        .rotationEffect(.degrees(-90))
                    Text("🛵")
                        .font(.system(size: 10))
                }
            }
            // 点击灵动岛 → 深链回跳 App 对应订单详情页（orderID 编码进 URL）
            .widgetURL(deliveryDeepLinkURL(orderID: context.attributes.orderID))
        }
    }
}

// MARK: - 深链 URL
/// 点击灵动岛/锁屏卡片回跳订单详情页：lbuiproject://deliveryDetail?orderID=订单3251
/// orderID 含中文，用 URLComponents 自动做百分号编码（App 侧 queryItems 解析自动还原）
private func deliveryDeepLinkURL(orderID: String) -> URL? {
    var components = URLComponents()
    components.scheme = "lbuiproject"
    components.host = "deliveryDetail"
    components.queryItems = [URLQueryItem(name: "orderID", value: orderID)]
    debugPrint("LBLog components \(components)")
    debugPrint("LBLog components url \(String(describing: components.url))")
    return components.url
}

// MARK: - 锁屏卡片视图
private struct LockScreenDeliveryView: View {
    let context: ActivityViewContext<LBDeliveryAttributes>

    private let themeBlue = Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255)
    private let titleBlack = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    private let subTitleGray = Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255)

    var body: some View {
        HStack(spacing: 12) {
            // 左侧：骑手图标（配送中）/ 对勾（已送达）
            ZStack {
                Circle()
                    .fill(context.state.isDelivered ? Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x7B / 255).opacity(0.15) : themeBlue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Text(context.state.isDelivered ? "✅" : "🛵")
                    .font(.system(size: 22))
            }

            // 中部：标题 + 进度条 + 状态
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    if context.state.isDelivered {
                        Text("已送达")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x7B / 255))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x7B / 255).opacity(0.12))
                            .clipShape(Capsule())
                    }else{
                        Text("距目的地 \(String(format: "%.1f", context.state.remainingDistance)) km")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(context.state.isDelivered ? Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x7B / 255) : titleBlack)
                    }
                }
                
                if !context.state.isDelivered{
                    ProgressView(value: context.state.progress)
                        .tint(context.state.isDelivered ? Color(red: 0x34 / 255, green: 0xC7 / 255, blue: 0x7B / 255) : themeBlue)
                }
                
                Text("\(context.attributes.orderID) · \(context.state.statusText)")
                    .font(.system(size: 12))
                    .foregroundColor(subTitleGray)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        // 锁屏卡片点击同样深链回跳订单详情页（锁屏卡片需单独挂 widgetURL，灵动岛的设置对它不生效）
        .widgetURL(deliveryDeepLinkURL(orderID: context.attributes.orderID))
    }
}
