//
//  LBCombineSearchView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/31.
//

import SwiftUI

struct LBCombineSearchView: View {
    @StateObject private var viewModel = LBCombineSearchViewModel()

    private let themeBlue = Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255)
    private let titleBlack = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    private let subTitleGray = Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255)
    private let bgGray = Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255)

    var body: some View {
        VStack(spacing: 0) {
            searchField

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)  // 撑满剩余空间，进度居中
            } else if let error = viewModel.errorMessage {
                errorView(error)
            } else if viewModel.searchResults.isEmpty {
                emptyView
            } else {
                /// 天气结果列表：debounce 300ms → 市名 -> 下属县区并发请求 -> 聚合展示
                List(viewModel.searchResults) { result in
                    SearchResultRow(result: result)
                        .listRowInsets(EdgeInsets(top: 6, leading: 14, bottom: 6, trailing: 14))
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        /// 根视图声明贪婪尺寸 + 顶部对齐：不写的话 VStack 按「理想尺寸」在全屏空间里
        /// 垂直居中——loading 等短内容分支时输入框会被顶到屏幕中间
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(bgGray)
        .navigationTitle("天气搜索")
        .navigationBarTitleDisplayMode(.inline)
        /// 右上角「坐标查询」入口：NavigationLink push 坐标查询页（同栈导航，返回手势可用）
        .navigationBarItems(trailing:
            NavigationLink {
                LBCityCoordinateSearchView()
            } label: {
                Text("坐标查询")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeBlue)
            }
        )
        /// 键盘避让关闭：键盘弹起时可视区压缩会让 hosting 内容重新垂直居中
        .ignoresSafeArea(.keyboard, edges: .bottom)
        /// 点击空白收起键盘：全局 resignFirstResponder（iOS 14 无 @FocusState 全场景方案）
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    // MARK: - 搜索框（绑定 viewModel.searchText，输入停止 300ms 自动发起请求）
    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(subTitleGray)
            TextField("输入城市名，如：杭州", text: $viewModel.searchText)
                .font(.system(size: 15))
                .autocorrectionDisabled()
            if !viewModel.searchText.isEmpty {
//                debugPrint("LBLog searchText \(viewModel.searchText)")
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

    // MARK: - 空态：引导提示（接口按市名查下属县区天气）
    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "cloud.sun")
                .font(.system(size: 44))
                .foregroundColor(themeBlue.opacity(0.6))
            Text("搜索城市查看下属区县天气")
                .font(.system(size: 15))
                .foregroundColor(titleBlack)
            Text("支持：杭州 / 北京 / 上海 / 广州\n输入停止 300ms 自动搜索（Combine debounce）")
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

// MARK: - 单条天气结果行
private struct SearchResultRow: View {

    let result: SearchResult

    private let titleBlack = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    private let subTitleGray = Color(red: 0x86 / 255, green: 0x86 / 255, blue: 0x86 / 255)
    private let themeBlue = Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255)

    var body: some View {
        HStack(spacing: 12) {
            /// 天气 emoji：昼夜区分（晴 ☀️/🌙，其余按描述映射）
            Text(weatherEmoji)
                .font(.system(size: 34))

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(result.countyName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(titleBlack)
                    Text(result.cityName + "市")
                        .font(.system(size: 12))
                        .foregroundColor(themeBlue)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(themeBlue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                Text("\(result.weatherDescription) · 风速 \(String(format: "%.1f", result.windSpeed)) km/h · \(result.isDay ? "白天" : "夜间")")
                    .font(.system(size: 13))
                    .foregroundColor(subTitleGray)
            }

            Spacer()

            /// 温度右对齐大字
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.0f", result.temperature))
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundColor(titleBlack)
                Text("℃")
                    .font(.system(size: 13))
                    .foregroundColor(subTitleGray)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    /// WMO 描述 -> emoji（配合 APIClient.weatherDescription 的中文）
    private var weatherEmoji: String {
        switch result.weatherDescription {
        case "晴", "基本晴": return result.isDay ? "☀️" : "🌙"
        case "局部多云", "阴": return result.isDay ? "⛅️" : "☁️"
        case "雾": return "🌫"
        case "毛毛雨", "冻毛毛雨": return "🌦"
        case "小雨", "中雨", "大雨", "冻雨": return "🌧"
        case "阵雨": return "🌧"
        case "小雪", "中雪", "大雪", "雪粒", "阵雪": return "❄️"
        case "雷暴", "雷暴伴冰雹": return "⛈"
        default: return "🌤"
        }
    }
}

#Preview {
    NavigationView {
        LBCombineSearchView()
    }
}
