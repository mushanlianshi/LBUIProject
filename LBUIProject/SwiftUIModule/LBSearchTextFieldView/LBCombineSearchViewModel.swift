//
//  LBCombineSearchViewModel.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/31.
//
import Combine
import UIKit

class LBCombineSearchViewModel: ObservableObject {
    // MARK: - Properties
    /// searchText 必须可写：SwiftUI TextField 经 $viewModel.searchText 双向绑定（Binding 需 setter）
    @Published var searchText: String = ""
    @Published private(set) var searchResults: [SearchResult] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    /// 新网络层统一入口（Network/Core/LBNetworkProvider）
    private let weatherProvider = LBNetworkProvider<LBWeatherAPI>()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init() {
        setupBindings()
    }

    // MARK: - Bindings
    private func setupBindings() {
        // 搜索文本变化管道
        // 结构要点：
        // 1. inner 请求的 failure 若放行到外层 sink，会让整条订阅链终止（一次失败断流），
        //    所以在 inner 侧 catch 成空数组保活，错误经 handleEvents 单独写入 errorMessage
        // 2. map + switchToLatest（flatMapLatest 语义）：新查询发起时自动取消旧查询（搜索竞态）
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)  // 防抖 300ms
            .removeDuplicates()  // 去除重复
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }  // 非空检查
            ///filter过滤后，没有值，不会在往map通道走
            .filter { [weak self] query in
                /// 非中文输入（拼音字母/数字/英文等）：提示并拦截，不发请求
                guard Self.containsChinese(query) else {
                    self?.errorMessage = "请输入中国的城市"
                    self?.searchResults = []
                    return false
                }
                return true
            }
            .handleEvents(
                receiveOutput: { [weak self] _ in
                    debugPrint("LBLog 防抖后准备请求 query")
                    self?.isLoading = true
                    self?.errorMessage = nil
                }
            )
            .map { [weak self] query -> AnyPublisher<[SearchResult], Never> in
                guard let self = self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                debugPrint("LBLog query \(query)")
                return self.searchPublisher(query)
            }
            .switchToLatest()
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] results in
                    debugPrint("LBLog 搜索完成，共 \(results.count) 条")
                    /// isLoading 只能在这里复位：外层 $searchText 永不完成，
                    /// switchToLatest 的内层完成不会终结整链，receiveCompletion 不会来
                    self?.isLoading = false
                    self?.searchResults = results
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - 搜索（新网络层：并发请求下属县区天气）
    /// inner 管道输出 Never（错误全部就地处理），外层免 catch；
    /// 单县失败降级为 nil（compactMap 压掉），不拖垮整组
    private func searchPublisher(_ query: String) -> AnyPublisher<[SearchResult], Never> {
        guard let counties = LBWeatherAPI.counties(in: query) else {
            /// 城市未收录：写错误提示（主线程），返回空结果保活
            DispatchQueue.main.async { [weak self] in
                self?.errorMessage = LBSearchError.cityNotFound.localizedDescription
            }
            return Just([]).eraseToAnyPublisher()
        }
        let cityName = query.replacingOccurrences(of: "市", with: "").trimmingCharacters(in: .whitespaces)

        return Publishers.MergeMany(counties.map { county in
            weatherProvider.request(.countyWeather(latitude: county.latitude, longitude: county.longitude),
                                     type: OpenMeteoWeatherResponse.self)
                .map { response -> SearchResult? in
                    guard let current = response.currentWeather else { return nil }
                    return SearchResult(countyName: county.name,
                                         cityName: cityName,
                                         temperature: current.temperature,
                                         weatherDescription: LBWeatherAPI.weatherDescription(for: current.weatherCode),
                                         windSpeed: current.windSpeed,
                                         isDay: current.isDay == 1)
                }
                .catch { error -> Just<SearchResult?> in
                    debugPrint("LBLog \(county.name) 请求失败降级: \(error.localizedDescription)")
                    return Just(nil)
                }
                .eraseToAnyPublisher()
        })
        .collect()
        .map { (results: [SearchResult?]) in results.compactMap { $0 } }
        .eraseToAnyPublisher()
    }

    // MARK: - Public Methods
    func clearSearch() {
        searchText = ""
        searchResults = []
        errorMessage = nil
    }

    // MARK: - 校验
    /// 是否包含中文字符（CJK 统一表意区段 U+4E00...U+9FFF）
    /// 混输场景（如「杭州abc」）只要含中文即放行
    private static func containsChinese(_ text: String) -> Bool {
        text.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
    }
}
