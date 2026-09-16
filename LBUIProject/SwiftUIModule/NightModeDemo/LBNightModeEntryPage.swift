//
//  LBNightModeEntryPage.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/15.
//

import SwiftUI

/// 深夜模式 demo 父页面（环境注入点）
///
/// 双通道注入（教学核心）：
/// - .environmentObject(manager)：子树共享可写状态源（开关双向同步）
/// - .environment(\.lbNightTheme, theme)：只读配色 token（由 manager.isNight 派生）
///
/// 子页面不注入任何东西——环境沿视图树自动穿透，这是 Environment 的核心机制
struct LBNightModeEntryPage: View {

    /// 状态源：创建一次，注入子树（@StateObject 持有生命周期）
    @StateObject private var manager = LBNightThemeManager()

    var body: some View {
        /// 本页直接作为 UIHostingController 的 rootView 被 push（外层是 UIKit 导航），
        /// 不包 NavigationView——环境注入覆盖本视图树即可。
        /// ⚠️ 子页面跳转不能用 NavigationLink：无 SwiftUI 导航容器时它会复用外层
        /// UINavigationController、把目标页包进全新 UIHostingController push——
        /// 新 hosting 与本页无视图树父子关系，环境穿不过 UIKit 边界，
        /// 子页 @EnvironmentObject 直接崩（"No ObservableObject found"）。
        /// 正解：Button 手动 push + 桥接视图续传环境（见 pushDetailPage）
        debugPrint("LBLog body 重新绘制-------------")
        return ZStack {
            // 天色渐变底：独立底层视图。不能挂在 ScrollView.background 上——
            // ScrollView 会吸收/干扰子树的动画标记，背景 opacity 动画不生效（裸切）；
            // 独立 ZStack 底层与子页面结构同构，动画可靠
            LBNightSkyBackground()
            content
        }
        .navigationTitle("深夜模式")
        .navigationBarTitleDisplayMode(.inline)
        ///manager的isNight变化，触发body的重新渲染， 重新计算environment的值注册theme是night还是day
        .environmentObject(manager)                    // 通道二：可写共享状态
        .environment(\.lbNightTheme, manager.isNight ? .night : .day)  // 通道一：只读 token
        .environment(\.lbNightThemeCustom, manager.isNight ? .day : .night)  // 通道一：只读 token
    }

    private var content: some View {
        ScrollView {
            VStack(spacing: 16) {
                statusCard
                previewCards
                previewCardsCustom
                Button {
                    pushDetailPage()
                } label: {
                    Text("进入子页面（验证环境穿透 →）")
                        .font(.system(size: 15, weight: .medium))
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                }
                .buttonStyle(LBNightLinkButtonStyle())
            }
            .padding(14)
        }
    }

    /// 手动 push 子页：跨 UIHostingController 边界，环境必须显式续传——
    /// 只注入 manager（引用类型，一次即可持续同步），只读 token 由桥接视图实时派生
    private func pushDetailPage() {
        let detail = LBCustomHostingController(naviTitle: "子页面 · 环境穿透", rootView:  LBNightModeDetailBridge()
            .environmentObject(manager))
        detail.navigationItem.title = "子页面 · 环境穿透"
        findNavigationController()?.pushViewController(detail, animated: true)
    }

    /// demo 取当前导航控制器（SwiftUI struct 内拿 UIKit 容器的最简路径）：
    /// tabbar 的 selectedViewController 即当前 Tab 的导航栈
    private func findNavigationController() -> UINavigationController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let windows = scenes.compactMap { $0.keyWindow }
        for window in windows {
            if let tab = window.rootViewController as? UITabBarController,
               let nav = tab.selectedViewController as? UINavigationController {
                return nav
            }
            if let nav = window.rootViewController as? UINavigationController {
                return nav
            }
        }
        return nil
    }

    // MARK: - 状态区（读写 EnvironmentObject）
    private var statusCard: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("当前天色")
                        .font(.system(size: 12))
                        .foregroundColor(theme.secondaryText)
                    Text(manager.phaseText)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(theme.primaryText)
                }
                Spacer()
                Text(manager.isAutoMode ? "自动轮转中 · 10s/格" : "手动模式")
                    .font(.system(size: 11))
                    .foregroundColor(theme.accent)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(theme.accent.opacity(0.12))
                    .clipShape(Capsule())
            }

            // 天色滑杆（拖动 = 用户接管，自动模式暂停）
            VStack(spacing: 4) {
                Slider(value: Binding(
                    get: { manager.skyProgress },
                    set: { manager.manualOverride(); manager.skyProgress = $0 }
                ), in: 0...1)
                .tint(theme.accent)
                HStack {
                    Text("☀️ 正午").font(.system(size: 10)).foregroundColor(theme.secondaryText)
                    Spacer()
                    Text("深夜 🌙").font(.system(size: 10)).foregroundColor(theme.secondaryText)
                }
            }

            Toggle(isOn: Binding(
                get: { manager.isNight },
                set: { _ in manager.toggleNight() }
            )) {
                Text("深夜模式开关")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.primaryText)
            }
            .tint(theme.accent)

            Toggle(isOn: $manager.isAutoMode) {
                Text("自动模式（定时轮转天色）")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(theme.primaryText)
            }
            .tint(theme.accent)
        }
        .padding(16)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - 预览区（只读 \.lbNightTheme，验证环境值驱动全树变色）
    private var previewCards: some View {
        VStack(spacing: 10) {
            Text("环境值预览（\\.lbNightTheme 只读驱动）")
                .font(.system(size: 12))
                .foregroundColor(theme.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                previewCard(icon: "🏠", title: "卡片 A")
                previewCard(icon: "📮", title: "卡片 B")
                previewCard(icon: "🌙", title: "卡片 C")
            }
        }
    }
    
    private var previewCardsCustom: some View {
        /// 拆成独立视图：@Environment 的依赖注册以「视图」为粒度——
        /// 声明在父视图上、由父 body 里的方法读取时，环境变化未必触发重渲
        /// （父视图的重渲依赖挂在 manager 上，环境快照更新时机与之错位，表现为「不跟着变」）；
        /// 独立 View 结构体自持 @Environment，环境槽位变化直接定位到该视图，注册才可靠
        LBNightCustomCardsSection()
    }

    private func previewCard(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Text(icon).font(.system(size: 26))
            Text(title).font(.system(size: 12)).foregroundColor(theme.primaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    /// 主题 theme, 直接取值，不依赖注入环境，少了一道，直接从源头取值，根据manager.isNight的变化，来更新theme主题。 比子页面取theme少绕了一步，直接取
    private var theme: LBNightTheme {
//        debugPrint("LBLog them is \(manager.isNight ? LBNightTheme.night : LBNightTheme.day)")
        // 注：父页面自己也从环境读——注入发生在 content 上层，本页 body 重新计算时生效
        return manager.isNight ? .night : .day
    }
}

// MARK: - 反向主题卡片区（独立视图：验证 @Environment 依赖注册的视图粒度）
/// 与 previewCards（正向主题，父视图直接派生）对照：
/// 本区自持 @Environment(\.lbNightThemeCustom)，环境槽位变化 → 本视图重渲（不依赖父视图刷新）。
/// ⚠️ 之前声明在父视图上、由父 body 里的方法读取时不跟着变——
/// @Environment 的依赖注册以「View 结构体」为粒度，跨 body 方法的读取注册不上
struct LBNightCustomCardsSection: View {

    @Environment(\.lbNightThemeCustom) private var themeCustom

    var body: some View {
        VStack(spacing: 10) {
            Text("反向主题预览（\\.lbNightThemeCustom 独立槽位）")
                .font(.system(size: 12))
                .foregroundColor(themeCustom.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            // 按比例分配宽度：可用宽 - 2×spacing 后按 1/1.2/1.3 切分（LBRatioHStack 封装）
            LBRatioHStack(spacing: 10, ratios: [1, 1.2, 1.3], views: [
                AnyView(card(icon: "🏠", title: "卡片 A")),
                AnyView(card(icon: "📮", title: "卡片 B")),
                AnyView(card(icon: "🌙", title: "卡片 C")),
            ])
            .frame(height: 90)   // GeometryReader 无固有高度，外部定高
        }
    }

    private func card(icon: String, title: String) -> some View {
        VStack(spacing: 8) {
            Text(icon).font(.system(size: 26))
            Text(title).font(.system(size: 12)).foregroundColor(themeCustom.primaryText)
        }
        .frame(maxWidth: .infinity)     // ← 关键：吃满 LBRatioHStack 分配的宽度
        .frame(maxHeight: .infinity)    // 行内等高（高度吃满行高）
        .padding(.vertical, 18)
        .background(themeCustom.cardBackground)   // 背景铺满整个 frame（含 padding）
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 天色渐变背景（读环境值的独立视图，证明环境穿透到任意子视图）
/// ⚠️ 渐变动画必须用「双层叠加 + opacity 过渡」：
/// LinearGradient 之间不是 Animatable（colors 数组无插值实现，diff = 整个换掉 = 裸切）；
/// opacity 是几何可插值属性，夜层透明度 0↔1 的动画在任何渲染时机都可靠。
/// 单层写法（colors: theme.skyGradient + animation(value:)）颜色一换就是跳变——勿改回
struct LBNightSkyBackground: View {

    @Environment(\.lbNightTheme) private var theme

    var body: some View {
        ZStack {
            // 白天渐变（常驻底层）
            LinearGradient(colors: LBNightTheme.day.skyGradient,
                           startPoint: .top, endPoint: .bottom)
            // 夜晚渐变（顶层，透明度随主题过渡）
            LinearGradient(colors: LBNightTheme.night.skyGradient,
                           startPoint: .top, endPoint: .bottom)
                .opacity(theme == .night ? 1 : 0)
        }
        .animation(.easeInOut(duration: 2.2), value: theme == .night)
        .ignoresSafeArea()
    }
}

// MARK: - 导航按钮样式（同样读环境值：环境可用于任意 Style）
struct LBNightLinkButtonStyle: ButtonStyle {

    @Environment(\.lbNightTheme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? theme.accent : theme.primaryText)
            .background(theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

