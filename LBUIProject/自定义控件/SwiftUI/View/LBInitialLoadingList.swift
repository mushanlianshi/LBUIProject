//
//  LBInitialLoadingList.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/17.
//

import SwiftUI

extension View {
    @ViewBuilder
    func conditionalRefreshable(_ condition: Bool,action: @escaping @Sendable () async -> Void) -> some View {
        if condition {
            self.refreshable(action: action)
        } else {
            self
        }
    }
}

// MARK: - 对齐系统下拉刷新菊花规格的自绘指示器
/// 系统 UIRefreshControl 的白色菊花：约 20pt、浅灰（lightGray/systemGray）、2pt 线宽。
/// ProgressView() 默认偏小（~16pt）且默认蓝色 tint，与系统下拉刷新同屏能看出差别——
/// scale 放大到 1.25（≈20pt）+ tint 灰色，肉眼与系统菊花一致
struct LBSysStyleSpinner: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.4)                       // 16pt × 1.25 ≈ 20pt，与系统菊花同径
            .tint(Color(UIColor.systemGray))          // 系统菊花的浅灰（深色模式自适应）
    }
}

// MARK: - 带首载 Loading 的分页 List 封装
/// 解决「第一次进页面要有加载指示，之后走系统下拉刷新」的标准形态：
/// - 首载（data 为空且 loading）：顶部伪菊花行（不是程序化触发系统控件——
///   refreshable 无公开触发 API，模拟它的链路脏且体验不还原生）
/// - 正常态：数据行 + 底部加载更多指示（onAppear 倒数第 2 条触发）
/// - 下拉刷新：系统 refreshable 托管（首载完成后永久由它接管）
///
/// 用法：
///     LBInitialLoadingList(items: viewModel.results,
///                          isLoading: viewModel.isRefreshing,
///                          isLoadingMore: viewModel.isLoadingMore,
///                          onRefresh: { await viewModel.refresh() },
///                          onLoadMore: { await viewModel.loadMoreIfNeeded(current: $0) },
///                          initialAction: { await viewModel.refresh() },
///                          row: { item in weatherRow(item) })
struct LBInitialLoadingList<Item: Identifiable, Row: View>: View {

    // MARK: - 输入
    let items: [Item]
    /// 首载/刷新中（顶部伪菊花行 + 首载判断用）
    let isLoading: Bool
    /// 加载更多中（底部指示行）
    let isLoadingMore: Bool
    /// 下拉刷新动作（系统 refreshable 托管）
    let onRefresh: () async -> Void
    /// 上拉加载触发（参数=当前出现的行 item，组件内只传"倒数第 2 条"，防抖逻辑交给调用方）
    let onLoadMore: (Item) async -> Void
    /// 首载动作（data 空时 task 触发一次）
    let initialAction: () async -> Void
    /// 行视图
    let row: (Item) -> Row

    /// 首载是否已完成（本地记忆：一旦有过数据就永久视为完成——即使后来刷新清空
    /// 列表，也不该回到"首载禁用"状态，刷新中用户仍可正常操作下拉）
    @State private var hasLoadedOnce = false

    /// 首载阶段（伪菊花行展示中）：此阶段禁用真实下拉刷新
    private var isInitialLoading: Bool {
        items.isEmpty && isLoading && !hasLoadedOnce
    }

    var body: some View {
        List {
            // 首载伪菊花行：只在「无数据 + 加载中」出现，数据到达即永久消失
            if isInitialLoading {
                HStack(spacing: 10) {
                    Spacer()
                    LBSysStyleSpinner()
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }

            ForEach(items) { item in
                row(item)
                    .onAppear {
                        // 上拉触发：倒数第 2 条出现时通知（防抖在 onLoadMore 侧）
                        if let index = items.firstIndex(where: { $0.id == item.id }),
                           index >= items.count - 2 {
                            Task { await onLoadMore(item) }
                        }
                    }
                    .listRowSeparator(.hidden)
            }

            // 底部加载更多指示行（菊花同系统规格，与首载行视觉统一）
            if isLoadingMore {
                HStack(spacing: 10) {
                    Spacer()
                    LBSysStyleSpinner()
                    Text("加载中…")
                        .font(.system(size: 14))
                        .foregroundColor(Color(UIColor.systemGray))
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.plain)
        .conditionalRefreshable(!isInitialLoading, action: {
            await onRefresh()
        })
        .task {
            debugPrint("LBLog task -------------")
            // 首载：数据为空才触发（切走再切回不重复）
            if items.isEmpty {
                await initialAction()
            }
        }
        .onChange(of: items.isEmpty) { empty in
            // 数据首次到达 → 永久标记完成（后续刷新清空列表也不会回到首载态）
            if !empty {
                hasLoadedOnce = true
            }
        }
    }
}
