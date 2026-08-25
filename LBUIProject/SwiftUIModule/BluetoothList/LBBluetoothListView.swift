//
//  LBBluetoothListView.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/24.
//

import SwiftUI
import UIKit
import SnapKit

// MARK: - 数据模型
struct LBBluetoothDeviceModel: Identifiable {
    let id = UUID()
    let name: String
}

/// 蓝牙列表页（SwiftUI 版）
/// 还原 lanhu 设计稿「蓝牙列表」：上方白卡展示当前选中设备（蓝色对勾），
/// 下方「其它」分组卡片展示未选设备（右侧「未连接」），行间 0.5pt #DDD 分割线。
/// 交互：单选——点击下方设备即切换为选中（原选中设备自动回到下方）；
/// 点击上方已选设备可取消选中（回到下方），全部未选时上方显示占位。
struct LBBluetoothListView: View {

    @Environment(\.presentationMode) private var presentationMode

    @State private var devices: [LBBluetoothDeviceModel] = [
        LBBluetoothDeviceModel(name: "LANYA_66"),
        LBBluetoothDeviceModel(name: "AB_AABB"),
        LBBluetoothDeviceModel(name: "JD_NING"),
        LBBluetoothDeviceModel(name: "KB_SKFILV"),
    ]

    /// 当前选中设备 id，nil 表示全部未选（设计稿默认 LANYA_66 选中）
    @State private var selectedID: UUID?

    /// 右上角「UIKitCell」按钮选中时，行内容用 UIKit 视图实现；否则用纯 SwiftUI
    @State private var useUIKitCell = false

    private var selectedDevice: LBBluetoothDeviceModel? {
        guard let selectedID else { return nil }
        return devices.first { $0.id == selectedID }
    }

    private var otherDevices: [LBBluetoothDeviceModel] {
        devices.filter { $0.id != selectedID }
    }

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    selectedCard
                    otherSection
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
            .background(Color(red: 0xF4 / 255, green: 0xF6 / 255, blue: 0xF9 / 255))
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .onAppear {
            selectedID = devices.first?.id
        }
    }

    // MARK: - 自定义导航栏（白色背景，返回 + 标题绝对居中 + 右侧 UIKitCell 切换按钮）
    private var navBar: some View {
        ZStack {
            Text("蓝牙列表")
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
            HStack(spacing: 0) {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255))
                        .frame(width: 44, height: 44)
                }
                Spacer()
                kitCellToggleButton(title: "UIKitCell", isOn: useUIKitCell) {
                    withAnimation(.easeInOut(duration: 0.25)) { useUIKitCell.toggle() }
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 44)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.black.opacity(0.06))
                .frame(height: 0.5)
        }
    }

    /// 切换按钮：选中时蓝底白字高亮，未选中蓝字描边（样式对齐 UIKit 版的 swiftUICell 按钮）
    private func kitCellToggleButton(title: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(isOn ? .white : Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255))
                .padding(.horizontal, 10)
                .frame(height: 30)
                .background(isOn ? Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255), lineWidth: 1)
                )
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
                    if useUIKitCell {
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
        if useUIKitCell {
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

// MARK: - UIKit 行视图容器（右上角 UIKitCell 按钮选中时启用）
/// 用 UIKit 实现的行内容（BLT 约定创建控件，SnapKit 布局），
/// 经 UIViewRepresentable 桥接到 SwiftUI，三种渲染状态与 SwiftUI 行内容一一对应
private class LBBluetoothUIKitRowContainer: UIView {

    enum RowMode {
        case selected       // 上卡片选中态：设备名 + 蓝色对勾
        case normal         // 「其它」分组行：设备名 + 未连接
        case placeholder    // 上卡片空态占位
    }

    /// 设备名 14pt #333 medium
    private lazy var nameLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.mediumFont(14), textColor: .blt.threeThreeBlackColor())
        return label
    }()

    /// 「未连接」14pt #777
    private lazy var statusLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(14), textColor: UIColor.blt.hexColor(0x777777))
        return label
    }()

    /// 选中对勾（项目蓝还原设计稿 duihao 图层）
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage(systemName: "checkmark")?.withTintColor(UIColor.blt.hexColor(0x0E8AFD), renderingMode: .alwaysOriginal))
        return imageView
    }()

    /// 行底部分割线 0.5pt #DDD，左缩进 12
    private lazy var separatorLine: UIView = {
        let view = UIView.blt.initWithBackgroundColor(color: UIColor.blt.hexColor(0xDDDDDD))
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupSubview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        addSubview(nameLabel)
        addSubview(statusLabel)
        addSubview(checkImageView)
        addSubview(separatorLine)

        nameLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.centerY.equalToSuperview()
        }
        statusLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
        }
        checkImageView.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-12)
            make.centerY.equalToSuperview()
            make.width.equalTo(16)
            make.height.equalTo(12)
        }
        separatorLine.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(12)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }

    // MARK: - 渲染（每次恢复基础色，避免占位态灰字污染其它状态）
    func render(name: String, mode: RowMode, showsSeparator: Bool = false) {
        switch mode {
        case .selected:
            nameLabel.text = name
            nameLabel.textColor = .blt.threeThreeBlackColor()
            statusLabel.isHidden = true
            checkImageView.isHidden = false
            separatorLine.isHidden = true
        case .normal:
            nameLabel.text = name
            nameLabel.textColor = .blt.threeThreeBlackColor()
            statusLabel.text = "未连接"
            statusLabel.isHidden = false
            checkImageView.isHidden = true
            separatorLine.isHidden = !showsSeparator
        case .placeholder:
            nameLabel.text = "暂未选择设备"
            nameLabel.textColor = .blt.ninenineBlackColor()
            statusLabel.isHidden = true
            checkImageView.isHidden = true
            separatorLine.isHidden = true
        }
    }
}

// MARK: - UIViewRepresentable 桥接
private struct LBBluetoothUIKitRow: UIViewRepresentable {

    let name: String
    let mode: LBBluetoothUIKitRowContainer.RowMode
    /// 普通态是否绘制行底部分割线（末行无）
    var showsSeparator: Bool = false

    func makeUIView(context: Context) -> LBBluetoothUIKitRowContainer {
        LBBluetoothUIKitRowContainer(frame: .zero)
    }

    func updateUIView(_ uiView: LBBluetoothUIKitRowContainer, context: Context) {
        uiView.render(name: name, mode: mode, showsSeparator: showsSeparator)
    }
}

#Preview {
    LBBluetoothListView()
}
