//
//  LBRatioHStack.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/16.
//

import SwiftUI

// MARK: - 按比例分配宽度的 HStack（GeometryReader 封装）
/// 用法（子视图逐个传入，与 ratios 一一对应）：
///     LBRatioHStack(spacing: 10,
///                   ratios: [1, 1.2, 1.3],
///                   views: [{ cardA }, { cardB }, { cardC }])
///
/// 为什么是「闭包数组」而不是 @ViewBuilder 尾闭包：
/// ViewBuilder 展开成 TupleView 后无法在运行时按索引取子视图（泛型编译期定型），
/// 逐视图闭包数组是比例布局的通用务实解法（子视图仍零开销：每个闭包即一个 view builder）
///
/// 设计要点：
/// - 比例切分：可用宽 = 总宽 - spacing×(n-1)，各子视图宽 = 可用宽 × ratio_i / Σratio
/// - views 与 ratios 数量不一致时按较小值渲染（多余的忽略），debugPrint 提示
/// - 行内子视图等高对齐（maxHeight: .infinity，以最高者为准）
/// - 高度：组件高度由子视图内容撑起（内部 ZStack 对齐顶部 + maxHeight 传导）
struct LBRatioHStack: View {

    let spacing: CGFloat
    let ratios: [CGFloat]
    let views: [() -> AnyView]

    /// 便捷构造（自动包 AnyView）
    init(spacing: CGFloat = 0,
         ratios: [CGFloat],
         views: [AnyView]) {
        self.spacing = spacing
        self.ratios = ratios
        self.views = views.map { view in { view } }
    }

    init(spacing: CGFloat = 0,
         ratios: [CGFloat],
         views: [() -> AnyView]) {
        self.spacing = spacing
        self.ratios = ratios
        self.views = views
    }

    var body: some View {
        let count = min(ratios.count, views.count)
        if count != ratios.count || count != views.count {
            debugPrint("LBLog LBRatioHStack 数量不匹配 ratios=\(ratios.count) views=\(views.count)，按 \(count) 个渲染")
        }

        return GeometryReader { proxy in
            let totalRatio = ratios.prefix(count).reduce(CGFloat(0), +)
            let usableWidth = proxy.size.width - spacing * CGFloat(max(0, count - 1))

            HStack(spacing: spacing) {
                ForEach(0..<count, id: \.self) { index in
                    let ratio = max(ratios[index], 0.0001)
                    views[index]()
                        .frame(width: max(0, usableWidth * ratio / totalRatio))
                        .frame(maxHeight: .infinity)   // 行内等高（以最高子视图为准）
                }
            }
            .frame(width: proxy.size.width)   // 横向恰好铺满
        }
    }
}

// MARK: - 使用示例（三卡 1 : 1.2 : 1.3，LBNightCustomCardsSection 里的用法）
/// LBRatioHStack(spacing: 10, ratios: [1, 1.2, 1.3], views: [
///     AnyView(card(icon: "🏠", title: "卡片 A")),
///     AnyView(card(icon: "📮", title: "卡片 B")),
///     AnyView(card(icon: "🌙", title: "卡片 C")),
/// ])
