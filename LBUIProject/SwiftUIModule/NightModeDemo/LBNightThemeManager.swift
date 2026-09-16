//
//  LBNightThemeManager.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/15.
//

import SwiftUI
import Combine

// MARK: - 主题 Token（EnvironmentKey 携带的值类型）
/// 配色 token 化：页面不写死任何颜色，全部从环境读取——
/// 环境值变化触发全树重渲，切夜模式时所有视图同时变
struct LBNightTheme: Equatable {

    /// 页面底色（白天浅灰 / 深夜藏蓝）
    let background: Color
    /// 卡片底色
    let cardBackground: Color
    /// 主文字
    let primaryText: Color
    /// 次级文字
    let secondaryText: Color
    /// 强调色
    let accent: Color
    /// 天色渐变（详情页顶部氛围背景）
    let skyGradient: [Color]

    static let day = LBNightTheme(
        background: Color(red: 0.96, green: 0.965, blue: 0.976),
        cardBackground: .white,
        primaryText: Color(red: 0.2, green: 0.2, blue: 0.2),
        secondaryText: Color(red: 0.5, green: 0.5, blue: 0.5),
        accent: Color(red: 0.05, green: 0.54, blue: 0.99),
        skyGradient: [Color(red: 0.55, green: 0.78, blue: 0.98),
                      Color(red: 0.75, green: 0.87, blue: 0.99)])

    static let night = LBNightTheme(
        background: Color(red: 0.07, green: 0.08, blue: 0.14),
        cardBackground: Color(red: 0.12, green: 0.13, blue: 0.21),
        primaryText: Color(red: 0.92, green: 0.93, blue: 0.96),
        secondaryText: Color(red: 0.58, green: 0.6, blue: 0.68),
        accent: Color(red: 0.98, green: 0.78, blue: 0.35),
        skyGradient: [Color(red: 0.05, green: 0.05, blue: 0.12),
                      Color(red: 0.13, green: 0.12, blue: 0.28)])
}

// MARK: - 自定义 EnvironmentKey（通道一：只读环境值 \.lbNightTheme）
private struct LBNightThemeKey: EnvironmentKey {
    /// 默认值：白天（未注入时兜底，不崩溃）
    static let defaultValue = LBNightTheme.day
}

extension EnvironmentValues {
    /// 页面用 @Environment(\.lbNightTheme) 读取主题 token（只读，纯函数式）
    var lbNightTheme: LBNightTheme {
        get {
            self[LBNightThemeKey.self]
        }
        set {
            self[LBNightThemeKey.self] = newValue
        }
    }
}

// MARK: - 主题管理器（通道二：EnvironmentObject，可写可订阅、多页面共享）
/// ObservableObject：状态源唯一（isNight），两条通道的值都由它派生——
/// EnvironmentObject 负责读写开关；EnvironmentKey 的值由注入点从它计算而来
final class LBNightThemeManager: ObservableObject {

    /// 当前是否深夜（唯一事实来源）
    @Published var isNight: Bool = false {
        didSet {
            // 环境值由注入点计算：manager.isNight 变 → 注入的 \.lbNightTheme 跟着变
            // 切换带动画：颜色 1.2s 渐变过渡
            if oldValue != isNight {
                withAnimation(.easeInOut(duration: 2.2)) {
                    objectWillChange.send()
                }
            }
        }
    }

    /// 自动模式（定时轮转天色）
    @Published var isAutoMode: Bool = true

    /// 天色进度 0~1（0 正午 → 1 深夜）：滑杆双向绑定，
    /// 派生 isNight（>0.5 判定入夜），也可反向由开关置 0/1
    @Published var skyProgress: Double = 0 {
        didSet {
            let night = skyProgress > 0.5
            if night != isNight {
                isNight = night
            }
        }
    }

    /// 自动轮转定时器（每 10 秒推进一格天色）
    private var autoTimer: AnyCancellable?

    /// 天色阶段描述（滑杆旁的文案）  计算属性里面带有@published的属性，会跟着变化
    var phaseText: String {
        switch skyProgress {
        case ..<0.25: return "正午 ☀️"
        case ..<0.5: return "黄昏 🌇"
        case ..<0.75: return "入夜 🌆"
        default: return "深夜 🌙"
        }
    }

    init() {
        startAutoTimerIfNeeded()
    }

    deinit {
        autoTimer?.cancel()
    }

    // MARK: - 自动轮转
    /// 每 10 秒推进 0.25 天色进度：正午 → 黄昏 → 入夜 → 深夜 → 循环
    private func startAutoTimerIfNeeded() {
        autoTimer?.cancel()
        autoTimer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isAutoMode else { return }
                self.skyProgress = (self.skyProgress + 0.25).truncatingRemainder(dividingBy: 1.01)
                if self.skyProgress >= 1.0 { self.skyProgress = 0 }  // 深夜→正午循环
            }
    }

    /// 手动拨滑杆时暂停自动模式（用户接管）
    func manualOverride() {
        isAutoMode = false
    }

    /// 开关直接切日夜
    func toggleNight() {
        skyProgress = isNight ? 0 : 1
    }
}
