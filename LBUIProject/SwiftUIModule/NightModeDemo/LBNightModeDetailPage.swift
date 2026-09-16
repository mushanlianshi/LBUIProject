//
//  LBNightModeDetailPage.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/15.
//

import SwiftUI

/// 深夜模式 demo 子页面（零注入——环境穿透验证页）
///
/// 本页不创建 manager、不写 environment 修饰符：
/// - @EnvironmentObject var manager：从父页面注入的环境里自动取得（找不到会崩溃——
///   环境注入是父级责任，这本身就是 Environment 的教学点）
/// - @Environment(\.lbNightTheme)：同样沿视图树流下来
///
/// 双向同步验证：本页的开关改 manager → 父页面状态区同步变化（单一数据源）
struct LBNightModeDetailPage: View {

    /// 从环境取得共享 manager（父页面 environmentObject 注入）
    @EnvironmentObject private var manager: LBNightThemeManager

    /// 只读主题 token（父页面 environment(\.lbNightTheme) 注入）
    @Environment(\.lbNightTheme) private var theme

    /// 星星显隐动画用本地态
    @State private var starsTwinkle = false

    var body: some View {
        ZStack {
            // 天色渐变（环境值驱动）
            LinearGradient(colors: theme.skyGradient,
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerCard
                    togglesCard
                    starsCard
                }
                .padding(14)
            }
        }
        .navigationTitle("子页面 · 环境穿透")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 星星闪烁动画（深夜才出现）
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                starsTwinkle = true
            }
        }
    }

    // MARK: - 顶部：月亮/太阳大图标（随天色切换）
    private var headerCard: some View {
        VStack(spacing: 12) {
            Text(manager.isNight ? "🌙" : "☀️")
                .font(.system(size: 64))
                .rotationEffect(.degrees(manager.isNight ? -12 : 0))
            Text(manager.phaseText)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(theme.primaryText)
            Text("本页零注入：环境沿视图树从父页面流下来")
                .font(.system(size: 12))
                .foregroundColor(theme.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 开关区：验证 EnvironmentObject 双向同步
    private var togglesCard: some View {
        VStack(spacing: 14) {
            Text("这里的开关与父页面实时同步（EnvironmentObject）")
                .font(.system(size: 12))
                .foregroundColor(theme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            Toggle(isOn: Binding(
                get: { manager.isNight },
                set: { _ in manager.toggleNight() }
            )) {
                Text("深夜模式（子页面切换）")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.primaryText)
            }
            .tint(theme.accent)

            Toggle(isOn: $manager.isAutoMode) {
                Text("自动模式")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.primaryText)
            }
            .tint(theme.accent)
        }
        .padding(16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 星空卡：深夜限定内容（条件渲染 + 闪烁）
    private var starsCard: some View {
        VStack(spacing: 12) {
            Text(manager.isNight ? "深夜限定：星空已点亮 ✨" : "白天：星星休息中")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(theme.primaryText)

            if manager.isNight {
                // 星星网格（布局固定、透明度闪烁）
                let columns = Array(repeating: GridItem(.flexible(), spacing: 18), count: 5)
                LazyVGrid(columns: columns, spacing: 18) {
                    ForEach(0..<10, id: \.self) { i in
                        Text("✨")
                            .font(.system(size: i % 3 == 0 ? 16 : 11))
                            .opacity(starsTwinkle ? (i % 2 == 0 ? 1 : 0.4) : 0.5)
                    }
                }
                .padding(.top, 4)
            } else {
                Text("🌇")
                    .font(.system(size: 40))
                    .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - 环境桥接视图（跨 UIHostingController 边界的环境续传）
/// 父页手动 push 的是本视图（不是 DetailPage 直接当 rootView）：
/// - 父页只注入了 manager（引用类型，环境对象一次注入持续同步）
/// - 只读 token（\.lbNightTheme）是值类型，push 时捕获会定格——
///   由本桥接视图从 manager 实时派生再注入，子树随天色变化持续刷新
///
/// 这就是「Environment 只在 SwiftUI 视图树内流动，跨 UIHostingController
/// 边界（UIKit push）必须手动续传」的落地形态
struct LBNightModeDetailBridge: View {

    @EnvironmentObject private var manager: LBNightThemeManager

    var body: some View {
        LBNightModeDetailPage()
            .environmentObject(manager)
            .environment(\.lbNightTheme, manager.isNight ? .night : .day)
    }
}
