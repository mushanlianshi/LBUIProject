//
//  LBRefreshableListViewModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/17.
//

import Foundation

/// SwiftUI List 下拉刷新/上拉加载 demo 的 ViewModel
///
/// 数据源：复用 LBCombineSearchViewModel 的天气接口链路
/// （LBWeatherAPI.counties 城市表 + countyWeather 接口），拉全部城市的县区天气。
/// 接口无分页参数 → 客户端分页（全量缓存 + 切片），与 LBCityCoordinateSearchView 同策略
///
/// 网络层已用 async 直调版（LBNetworkProvider+Async 的 requestAsync）——
/// continuation 桥接下沉到网络层全局一座，VM 从回调嵌套直译为顺序代码
///
/// @MainActor：refreshable 的 async 闭包在后台线程执行——@Published 赋值若发生在
/// 后台线程，SwiftUI 运行时告警"Publishing changes from background threads"。
/// 类级 @MainActor 让编译器强制本类所有方法（含状态更新）在主线程执行，
/// async 入口被调用时 Swift 会自动 hop 到主线程
@MainActor
final class LBRefreshableListViewModel: ObservableObject {

    // MARK: - State
    /// 列表展示数据（分页累积）
    @Published private(set) var results: [SearchResult] = []
    /// 下拉刷新中（首载 loading 行判断用；下拉刷新的菊花由系统 refreshable 托管）
    @Published private(set) var isRefreshing = false
    /// 加载更多中（底部进度条展示）
    @Published private(set) var isLoadingMore = false
    /// 状态描述（调试/演示用）
    @Published var statusText = "下拉刷新加载数据"

    // MARK: - Paging
    /// 全量缓存（一次网络请求拉齐，loadMore 从这里切片）
    private var allResults: [SearchResult] = []
    /// 已加载到的缓存偏移
    private var loadedCount = 0
    /// 每页条数
    private let pageSize = 5
    /// 演示：缓存切片循环的轮次（每轮 refresh 重置）
    private var cycle = 0

    // MARK: - Network
    private let weatherProvider = LBNetworkProvider<LBWeatherAPI>()
    /// 演示用城市序列
    private let cities = ["杭州", "北京", "上海", "广州"]

    init() {}

    // MARK: - 下拉刷新（真网络请求，async 直译：无 continuation）
    /// await 返回 = 网络完成（成功或失败），refreshable 菊花转到此刻为止
    func refresh() async {
        isRefreshing = true
        statusText = "正在刷新…"

        let fresh = await fetchAllCitiesWeather()
        allResults = fresh
        loadedCount = 0
        cycle = 0
        results = Array(fresh.prefix(pageSize))
        loadedCount = results.count
        isRefreshing = false
        statusText = fresh.isEmpty
            ? "刷新失败/无数据，下拉重试"
            : "刷新成功 \(fresh.count) 条 · 上拉加载更多"
    }

    // MARK: - 上拉加载更多（缓存切片，无新请求）
    /// 触发时机：列表滚动到倒数第 N 条（onAppear 检测，见 View）。
    /// 缓存耗尽时循环补位（cycle+1 轮从头再切，模拟无限数据流）
    func loadMoreIfNeeded(current item: SearchResult) async {
        // 防重入：正在加载时重复触发直接忽略（滚动回弹会连发 onAppear）
        guard !isLoadingMore, !isRefreshing else { return }
        // 只在"快见底"时触发（倒数第 2 条出现）
        guard let index = results.firstIndex(where: { $0.id == item.id }),
              index >= results.count - 2 else { return }

        isLoadingMore = true
        // 模拟网络往返 0.6s（真实产品此处为分页请求的耗时）
        try? await Task.sleep(nanoseconds: 600_000_000)

        if allResults.isEmpty {
            // 首次进入未刷新过：自动触发一次全量加载（免得白屏）
            await refresh()
        } else {
            let remaining = allResults.dropFirst(loadedCount % max(allResults.count, 1))
            let nextPage = Array(remaining.prefix(pageSize))
            // 缓存耗尽：循环切片（从头再切——模拟无限数据流）
            let page = nextPage.isEmpty ? Array(allResults.prefix(pageSize)) : nextPage
            let offset = nextPage.isEmpty ? 0 : loadedCount
            loadedCount = offset + page.count
            if nextPage.isEmpty { cycle += 1 }
            results.append(contentsOf: page)
            statusText = "已加载 \(results.count) 条（第 \(cycle + 1) 轮）"
        }
        isLoadingMore = false
    }

    // MARK: - 网络请求（async 直译版：单县失败降级跳过，不拖垮整组）
    private func fetchAllCitiesWeather() async -> [SearchResult] {
        let allCounties: [(city: String, county: LBWeatherAPI.County)] = cities.flatMap { city in
            (LBWeatherAPI.counties(in: city) ?? []).map { (city, $0) }
        }
        // 并发拉全部县区：TaskGroup 每个子任务一个请求，
        // 单个失败返回 nil（压掉），等价旧 Combine 版的 MergeMany+collect+catch
        return await withTaskGroup(of: SearchResult?.self) { group in
            for pair in allCounties {
                group.addTask { [weatherProvider] in
                    do {
                        let response = try await weatherProvider.requestAsync(
                            .countyWeather(latitude: pair.county.latitude,
                                           longitude: pair.county.longitude),
                            type: OpenMeteoWeatherResponse.self)
                        guard let current = response.currentWeather else { return nil }
                        
                        return SearchResult(countyName: pair.county.name,
                                            cityName: pair.city,
                                            temperature: current.temperature,
                                            weatherDescription: LBWeatherAPI.weatherDescription(for: current.weatherCode),
                                            windSpeed: current.windSpeed,
                                            isDay: current.isDay == 1)
                    } catch {
                        debugPrint("LBLog \(pair.county.name) 请求失败降级: \(error.localizedDescription)")
                        return nil
                    }
                }
            }
            var list: [SearchResult] = []
            for await result in group {
                if let result { list.append(result) }
            }
            return list
        }
    }
}
