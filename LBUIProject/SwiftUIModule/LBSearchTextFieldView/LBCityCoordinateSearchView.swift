//
//  LBCityCoordinateSearchView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import SwiftUI
import Combine

// MARK: - ViewModel
/// 城市坐标查询：输入中文城市名 → debounce → Geocoding 接口 → 坐标/行政/海拔/人口列表。
/// 管道结构与 LBCombineSearchViewModel 一致：防抖 / 中文校验 / switchToLatest 竞态保护 /
/// catch 保活 / 值到达复位 isLoading（外层流永不完成，receiveCompletion 不会来）
private final class LBCityCoordinateSearchViewModel: ObservableObject {

    @Published var searchText: String = ""
    @Published private(set) var results: [LBGeocodingResponse.GeoResult] = []
    @Published private(set) var isLoading: Bool = false
    @Published var errorMessage: String?

    private let weatherProvider = LBNetworkProvider<LBWeatherAPI>()
    private var cancellables = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .filter { [weak self] query in
                guard Self.containsChinese(query) else {
                    self?.errorMessage = "请输入中国的城市"
                    self?.results = []
                    return false
                }
                return true
            }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
                self?.errorMessage = nil
            })
            .map { [weak self] query -> AnyPublisher<[LBGeocodingResponse.GeoResult], Never> in
                guard let self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                debugPrint("LBLog 坐标查询 query \(query)")
                return self.searchPublisher(query)
            }
            .switchToLatest()
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] list in
                self?.isLoading = false
                self?.results = list
                if list.isEmpty {
                    self?.errorMessage = "未找到相关地点"
                }
            })
            .store(in: &cancellables)
    }

    private func searchPublisher(_ query: String) -> AnyPublisher<[LBGeocodingResponse.GeoResult], Never> {
        weatherProvider.request(.cityCoordinate(name: query), type: LBGeocodingResponse.self)
            .map { $0.results ?? [] }
            .catch { error -> Just<[LBGeocodingResponse.GeoResult]> in
                debugPrint("LBLog 坐标查询失败: \(error.localizedDescription)")
                return Just([])
            }
            .eraseToAnyPublisher()
    }

    private static func containsChinese(_ text: String) -> Bool {
        text.unicodeScalars.contains { (0x4E00...0x9FFF).contains($0.value) }
    }

    func clearSearch() {
        searchText = ""
        results = []
        errorMessage = nil
    }
}

// MARK: - View
/// 城市坐标查询页（入口：天气搜索页右上角「坐标查询」按钮）
struct LBCityCoordinateSearchView: View {

    @StateObject private var viewModel = LBCityCoordinateSearchViewModel()

    private let themeBlue = Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255)
    private let titleBlack = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    private let subTitleGray = Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255)
    private let bgGray = Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255)

    var body: some View {
        VStack(spacing: 0) {
            searchField

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.results.isEmpty {
                emptyView
            } else {
                List(viewModel.results) { result in
                    CityCoordinateRow(result: result)
                        .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(bgGray)
        .navigationTitle("坐标查询")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - 搜索框
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(subTitleGray)
            TextField("输入城市名，如：成都", text: $viewModel.searchText)
                .font(.system(size: 15))
                .autocorrectionDisabled()
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.clearSearch()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(subTitleGray.opacity(0.6))
                }
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
    }

    // MARK: - 空态
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "location.circle")
                .font(.system(size: 44))
                .foregroundColor(themeBlue.opacity(0.6))
            Text("搜索城市查看坐标与信息")
                .font(.system(size: 15))
                .foregroundColor(titleBlack)
            Text("全国城市/县区均支持（Open-Meteo Geocoding）\n输入停止 300ms 自动搜索")
                .font(.system(size: 13))
                .foregroundColor(subTitleGray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - 错误视图
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(.orange)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(titleBlack)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 单条城市信息卡片
private struct CityCoordinateRow: View {

    let result: LBGeocodingResponse.GeoResult

    private let titleBlack = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    private let subTitleGray = Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255)
    private let themeBlue = Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255)

    /// 信息行（图标 + 标题 + 值）
    private func infoLine(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(icon)
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(subTitleGray)
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(titleBlack)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(themeBlue)
                Text(result.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(titleBlack)
                if let country = result.country {
                    Text(country)
                        .font(.system(size: 12))
                        .foregroundColor(themeBlue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeBlue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Spacer()
            }

            /// 经纬度（等宽字体，坐标对齐）
            HStack(spacing: 12) {
                Text(String(format: "纬度 %.4f", result.latitude))
                Text(String(format: "经度 %.4f", result.longitude))
            }
            .font(.system(size: 14, weight: .medium, design: .monospaced))
            .foregroundColor(titleBlack)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(themeBlue.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 6))

            /// 行政区划
            if let admin = adminText {
                infoLine(icon: "🗺", title: "行政区", value: admin)
            }
            if let elevation = result.elevation {
                infoLine(icon: "⛰", title: "海拔", value: String(format: "%.0f 米", elevation))
            }
            if let population = result.population {
                infoLine(icon: "👥", title: "人口", value: Self.formattedPopulation(population))
            }
            if let timezone = result.timezone {
                infoLine(icon: "🕐", title: "时区", value: timezone)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    /// 省市拼接（如「浙江 · 杭州市」，缺省字段自动跳过）
    private var adminText: String? {
        [result.admin1, result.admin2]
            .compactMap { $0 }
            .filter { $0 != result.name }
            .joined(separator: " · ")
            .nonEmpty
    }

    /// 人口千分位格式化（9236032 → 923.6 万）
    private static func formattedPopulation(_ value: Int) -> String {
        if value >= 10_000 {
            return String(format: "%.1f 万", Double(value) / 10_000)
        }
        return "\(value)"
    }
}

private extension String {
    /// 空串转 nil（配合 adminText 过滤空拼接结果）
    var nonEmpty: String? { isEmpty ? nil : self }
}
