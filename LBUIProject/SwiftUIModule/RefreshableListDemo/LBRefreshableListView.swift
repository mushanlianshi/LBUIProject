//
//  LBRefreshableListView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/17.
//

import SwiftUI

/// SwiftUI List 原生「下拉刷新 + 上拉加载更多」demo
///
/// 列表整套交互（首载 loading 行 / refreshable 下拉 / onAppear 上拉 / 底部指示）
/// 已封装进 LBInitialLoadingList——本页只负责行视图与 VM 接线
///
/// 数据源：天气接口（LBWeatherAPI 城市表 + countyWeather），客户端分页
struct LBRefreshableListView: View {

    @StateObject private var viewModel = LBRefreshableListViewModel()

    var body: some View {
        LBInitialLoadingList(
            items: viewModel.results,
            isLoading: viewModel.isRefreshing,
            isLoadingMore: viewModel.isLoadingMore,
            onRefresh: { await viewModel.refresh() },
            onLoadMore: { item in await viewModel.loadMoreIfNeeded(current: item) },
            initialAction: { await viewModel.refresh() },
            row: { item in weatherRow(item) }
        )
        .navigationTitle("下拉刷新 · 上拉加载")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - 行
    private func weatherRow(_ item: SearchResult) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.cityName) · \(item.countyName)")
                    .font(.system(size: 15, weight: .medium))
                Text(item.weatherDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.0f℃", item.temperature))
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(item.isDay ? .orange : .indigo)
                Text(String(format: "%.0f km/h", item.windSpeed))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
