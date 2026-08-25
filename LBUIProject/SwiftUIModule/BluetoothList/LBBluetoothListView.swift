//
//  LBBluetoothListView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/24.
//

import SwiftUI
import UIKit
import SnapKit
import MJRefresh

// MARK: - 数据模型
struct LBBluetoothDeviceModel: Identifiable {
    let id = UUID()
    let name: String
}

// MARK: - 页面共享状态
/// useUIKitCell 放 ObservableObject 而非 @State：
/// 切换按钮在 UIKit 导航栏（LBBluetoothListHostingController），行实现在 SwiftUI，
/// 状态由两者共享——按钮点击改 here，SwiftUI 经 @ObservedObject 自动刷新
class LBBluetoothListViewModel: ObservableObject {
    /// true：行内容用 UIKit 视图实现；false：纯 SwiftUI
    @Published var useUIKitCell = false
}

/// 蓝牙列表页（SwiftUI 版）
/// 还原 lanhu 设计稿「蓝牙列表」：上方白卡展示当前选中设备（蓝色对勾），
/// 下方「其它」分组卡片展示未选设备（右侧「未连接」），行间 0.5pt #DDD 分割线。
/// 交互：单选——点击下方设备即切换为选中（原选中设备自动回到下方）；
/// 点击上方已选设备可取消选中（回到下方），全部未选时上方显示占位。
struct LBBluetoothListView: View {

    @ObservedObject var viewModel: LBBluetoothListViewModel

    @State private var devices: [LBBluetoothDeviceModel] = [
        LBBluetoothDeviceModel(name: "LANYA_66"),
        LBBluetoothDeviceModel(name: "AB_AABB"),
        LBBluetoothDeviceModel(name: "JD_NING"),
        LBBluetoothDeviceModel(name: "KB_SKFILV"),
    ]

    /// 当前选中设备 id，nil 表示全部未选（设计稿默认 LANYA_66 选中）
    @State private var selectedID: UUID?

    private var selectedDevice: LBBluetoothDeviceModel? {
        guard let selectedID else { return nil }
        return devices.first { $0.id == selectedID }
    }

    private var otherDevices: [LBBluetoothDeviceModel] {
        devices.filter { $0.id != selectedID }
    }

    var body: some View {
        LBRefreshScrollView(content: VStack(alignment: .leading, spacing: 0) {
            selectedCard
            otherSection
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .frame(maxWidth: .infinity, alignment: .leading),
        onRefresh: handleRefresh,
        onLoadMore: handleLoadMore)
        .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
        .background(Color.white)
        .onAppear {
            selectedID = devices.first?.id
        }
    }

    // MARK: - MJRefresh 下拉刷新 / 上拉加载
    /// 下拉刷新：模拟请求，重置为初始设备列表
    private func handleRefresh(_ scrollView: UIScrollView) {
        print("LBLog bluetooth swiftui header refresh begin")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.25)) {
                devices = [
                    LBBluetoothDeviceModel(name: "LANYA_66"),
                    LBBluetoothDeviceModel(name: "AB_AABB"),
                    LBBluetoothDeviceModel(name: "JD_NING"),
                    LBBluetoothDeviceModel(name: "KB_SKFILV"),
                ]
                selectedID = devices.first?.id
            }
            scrollView.mj_header?.endRefreshing()
            scrollView.mj_footer?.resetNoMoreData()
            print("LBLog bluetooth swiftui header refresh done, count \(devices.count)")
        }
    }

    /// 上拉加载：每次追加 2 个新设备，超过 30 个提示没有更多
    /// （上限比 UIKit 版的 12 大：SwiftUI 版 footer 只在内容满屏后出现，需保证内容能超过屏幕高度）
    private func handleLoadMore(_ scrollView: UIScrollView) {
        print("LBLog bluetooth swiftui footer load more begin")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if devices.count >= 30 {
                scrollView.mj_footer?.endRefreshingWithNoMoreData()
                print("LBLog bluetooth swiftui no more data")
                return
            }
            withAnimation(.easeInOut(duration: 0.25)) {
                let count = devices.count
                devices.append(LBBluetoothDeviceModel(name: "NEW_DEVICE_\(count + 1)"))
                devices.append(LBBluetoothDeviceModel(name: "NEW_DEVICE_\(count + 2)"))
            }
            scrollView.mj_footer?.endRefreshing()
            print("LBLog bluetooth swiftui load more done, count \(devices.count)")
        }
    }

    // MARK: - 上卡片：当前选中设备（对勾标记），点击可取消选中
    private var selectedCard: some View {
        Group {
            if let device = selectedDevice {
                rowContent(name: device.name, mode: .selected)
                    .frame(height: 54)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) { selectedID = nil }
                    }
            } else {
                /// 全部未选时的占位（保持卡片布局稳定）
                rowContent(name: "", mode: .placeholder)
                    .frame(height: 54)
            }
        }
        .background(Color.white)
    }

    // MARK: - 下方「其它」分组：未选中的设备列表
    private var otherSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("其它")
                .font(.system(size: 13))
                .foregroundColor(Color(red: 0x66 / 255, green: 0x66 / 255, blue: 0x66 / 255))
                .padding(.horizontal, 12)
                .padding(.top, 14)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                ForEach(Array(otherDevices.enumerated()), id: \.element.id) { index, device in
                    if viewModel.useUIKitCell {
                        /// UIKit 模式：分割线由 UIKit 行视图内部底部绘制
                        deviceRow(device, showsSeparator: index < otherDevices.count - 1)
                    } else {
                        /// SwiftUI 模式：行间独立插入分割线
                        deviceRow(device, showsSeparator: false)
                        if index < otherDevices.count - 1 {
                            separator
                        }
                    }
                }
                if otherDevices.isEmpty {
                    Text("暂无其它设备")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                        .frame(maxWidth: .infinity, minHeight: 51, alignment: .leading)
                        .padding(.horizontal, 12)
                }
            }
            .background(Color.white)
        }
    }

    // MARK: - 设备行：名称 + 未连接，点击设为选中（单选，原选中自动回到下方）
    private func deviceRow(_ device: LBBluetoothDeviceModel, showsSeparator: Bool) -> some View {
        rowContent(name: device.name, mode: .normal, showsSeparator: showsSeparator)
            .frame(height: 51)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.25)) {
                    selectedID = device.id
                }
            }
    }

    // MARK: - 行内容双实现分发
    /// useUIKitCell 为 true 时行内容用 UIKit 视图（UIViewRepresentable），否则用纯 SwiftUI
    @ViewBuilder
    private func rowContent(name: String, mode: LBBluetoothUIKitRowContainer.RowMode, showsSeparator: Bool = false) -> some View {
        if viewModel.useUIKitCell {
            LBBluetoothUIKitRow(name: name, mode: mode, showsSeparator: showsSeparator)
        } else {
            swiftUIRowContent(name: name, mode: mode)
        }
    }

    /// 纯 SwiftUI 行内容（原实现，三种渲染状态）
    @ViewBuilder
    private func swiftUIRowContent(name: String, mode: LBBluetoothUIKitRowContainer.RowMode) -> some View {
        switch mode {
        case .selected:
            HStack {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255))
            }
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        case .normal:
            HStack {
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                Spacer()
                Text("未连接")
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0x77 / 255, green: 0x77 / 255, blue: 0x77 / 255))
            }
            .padding(.horizontal, 12)
        case .placeholder:
            Text("暂未选择设备")
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
        }
    }

    /// 行间分割线：0.5pt #DDD，左缩进 12
    private var separator: some View {
        Rectangle()
            .fill(Color(red: 0xDD / 255, green: 0xDD / 255, blue: 0xDD / 255))
            .frame(height: 0.5)
            .padding(.leading, 12)
    }
    


//然是神奇美妙的。自然文学的作者________在读者面前的，是含有风景、声音及心绪的多维画面。这三者相互交织，相辅相成，形成了自然文学的独特之处，也________出独特的审美情趣和美学价值。依次填入划横线处最恰当的一项是：
//
//    展现 引申
//
//    呈现 衍生
//
//    描摹 演化
//
//    描绘 发展
}







#Preview {
    LBBluetoothListView(viewModel: LBBluetoothListViewModel())
}
