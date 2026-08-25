//
//  LBRefreshScrollView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/25.
//

import Foundation
import SwiftUI
import MJRefresh

// MARK: - MJRefresh 刷新容器（SwiftUI 内容桥接 UIScrollView + MJRefresh）
/// 滚动与刷新/加载由 UIKit 成熟控件 MJRefresh 承担，页面内容保持纯 SwiftUI：
/// UIScrollView + UIHostingController 承载 SwiftUI 内容（宽度跟随 frameLayoutGuide，
/// 高度由 SwiftUI 内容固有尺寸撑起 contentSize），mj_header/mj_footer 挂在 scrollView 上。
/// 刷新回调把 scrollView 回传给调用方，数据更新后自行 endRefreshing（对齐项目
/// LBSwiftUIRefreshListController 的用法约定）。
struct LBRefreshScrollView<Content: View>: UIViewRepresentable {

    let content: Content
    let onRefresh: (UIScrollView) -> Void
    let onLoadMore: (UIScrollView) -> Void

    /// 顶层 topLeading 填充包装：hosting view 高度会被撑到至少一屏（见 makeUIView 约束），
    /// 不指定对齐方式 SwiftUI 内容会在大容器里垂直居中、视觉错位。
    /// 用具名包装类型统一泛型参数——直接写 content.frame(...) 的返回类型是
    /// SwiftUI 内部 ModifiedContent，与 Coordinator 声明的 UIHostingController<Content> 不匹配。
    /// fileprivate：与下方 hostController 属性级别匹配（属性级别不能高于其类型），
    /// 且同文件 extension / 其他代码也可访问
    fileprivate struct TopAlignedContent: View {
        let content: Content

        var body: some View {
            content.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var wrappedContent: TopAlignedContent {
        TopAlignedContent(content: content)
    }

    init(content: Content, onRefresh: @escaping (UIScrollView) -> Void, onLoadMore: @escaping (UIScrollView) -> Void) {
        self.content = content
        self.onRefresh = onRefresh
        self.onLoadMore = onLoadMore
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        /// 内容不满一屏时也允许下拉/上拉拖动（UIScrollView 默认短内容不产生垂直 bounce，
        /// 不开这个下拉刷新也拖不出来）
        scrollView.alwaysBounceVertical = true

        let hostController = UIHostingController(rootView: wrappedContent)
        hostController.view.backgroundColor = .clear
        if #available(iOS 16.0, *) {
            /// 固有尺寸模式：高度随 SwiftUI 内容自动更新（修复加载更多后高度不跟随增长）
            hostController.sizingOptions = .intrinsicContentSize
        }
        scrollView.addSubview(hostController.view)
        hostController.view.snp.makeConstraints { make in
            /// 四边贴 contentLayoutGuide、宽度锁 frameLayoutGuide（横向不滚、SwiftUI 拿到确定宽度）。
            /// 关键：高度 >= 可视高度——内容不满一屏时 contentSize 恰好一屏，
            /// footer 钉在 contentSize 底部 = scrollView 底边缘之外（天然屏外），
            /// 上拉 bounces 拖动才露出、松手回弹缩回；满屏后随内容增长。
            /// 导航栏显隐导致的高度变化由 Auto Layout 自动跟随，无转场时机竞争
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
            make.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide)
        }
        context.coordinator.hostController = hostController

        scrollView.mj_header = MJRefreshNormalHeader(refreshingBlock: { onRefresh(scrollView) })
        scrollView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { onLoadMore(scrollView) })
        return scrollView
    }

    /// 数据变化（@State 驱动）时刷新 SwiftUI 内容，无需重建滚动容器
    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        debugPrint("LBLog LBRefreshScrollView  updateUIView  ---------------")
        guard let hostController = context.coordinator.hostController else { return }
        hostController.rootView = wrappedContent
        /// 强制重算固有高度，驱动 contentSize 跟随内容增长
        /// （iOS 16+ sizingOptions 已覆盖；iOS 14/15 必须手动失效，否则高度停留在旧值）
        hostController.view.invalidateIntrinsicContentSize()
    }

    final class Coordinator {
        fileprivate var hostController: UIHostingController<TopAlignedContent>?
    }
}
