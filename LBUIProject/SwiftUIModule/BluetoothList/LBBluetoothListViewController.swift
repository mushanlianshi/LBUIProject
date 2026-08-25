//
//  LBBluetoothListViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/8/24.
//

import UIKit
import SnapKit
import SwiftUI
import MJRefresh

// MARK: - 数据模型
class LBBluetoothDevice: NSObject {
    let id: UUID
    let name: String

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        super.init()
    }
}

/// 蓝牙列表页（UIKit 版，遵守 BLTUIKit 控件创建约定）
/// 还原 lanhu 设计稿「蓝牙列表」：上方白卡展示当前选中设备（蓝色对勾），
/// 下方「其它」分组卡片展示未选设备（右侧「未连接」），行间 0.5pt #DDD 分割线。
/// 交互：单选——点击下方设备即切换为选中（原选中设备自动回到下方）；
/// 点击上方已选设备可取消选中（回到下方），全部未选时上方显示占位。
class LBBluetoothListViewController: UIViewController {

    /// 全量设备，选中状态由 selectedID 表达（单选）
    private var devices: [LBBluetoothDevice] = [
        LBBluetoothDevice(name: "LANYA_66"),
        LBBluetoothDevice(name: "AB_AABB"),
        LBBluetoothDevice(name: "JD_NING"),
        LBBluetoothDevice(name: "KB_SKFILV"),
    ]

    /// 当前选中设备 id，nil 表示全部未选
    private var selectedID: UUID?

    /// 右上角「swiftUICell」按钮选中时，列表 cell 用 SwiftUI 实现；否则用 UIKit cell
    private var useSwiftUICell = false

    private var selectedDevice: LBBluetoothDevice? {
        devices.first { $0.id == selectedID }
    }

    private var otherDevices: [LBBluetoothDevice] {
        devices.filter { $0.id != selectedID }
    }

    /// 右上角切换按钮：选中时蓝底白字高亮，未选中蓝字描边
    private lazy var swiftUICellButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "swiftUICell", font: .blt.mediumFont(13), color: UIColor.blt.hexColor(0x0E8AFD), target: self, action: #selector(toggleSwiftUICellTapped))
        button.frame = CGRect(x: 0, y: 0, width: 88, height: 30)
        button.layer.cornerRadius = 4
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blt.hexColor(0x0E8AFD).cgColor
        return button
    }()

    /// 表格整体左右缩进 14 形成卡片边距，cell 白底即卡片
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.rowHeight = 51
        /// iOS 15+ plain 样式默认在每个 section header 上方额外垫 22pt，必须关掉，
        /// 否则「其它」标题离上方卡片间距异常大（24 footer + 22 系统垫层 + 8 label 上边距）
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.estimatedSectionFooterHeight = 0
        tableView.register(LBBluetoothDeviceCell.self, forCellReuseIdentifier: NSStringFromClass(LBBluetoothDeviceCell.self))
        tableView.register(LBBluetoothSwiftUICell.self, forCellReuseIdentifier: NSStringFromClass(LBBluetoothSwiftUICell.self))
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "蓝牙列表"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: swiftUICellButton)
        view.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        /// 设计稿默认 LANYA_66 选中
        selectedID = devices.first?.id
        setupSubview()
    }

    private func setupSubview() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(14)
            make.right.equalToSuperview().offset(-14)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        setupRefresh()
    }

    // MARK: - MJRefresh 下拉刷新 / 上拉加载
    private func setupRefresh() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            self?.headerRefresh()
        })
        tableView.mj_footer = MJRefreshBackNormalFooter(refreshingBlock: { [weak self] in
            self?.footerLoadMore()
        })
    }

    /// 下拉刷新：模拟请求，重置为初始设备列表
    private func headerRefresh() {
        print("LBLog bluetooth header refresh begin")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.devices = [
                LBBluetoothDevice(name: "LANYA_66"),
                LBBluetoothDevice(name: "AB_AABB"),
                LBBluetoothDevice(name: "JD_NING"),
                LBBluetoothDevice(name: "KB_SKFILV"),
            ]
            self.selectedID = self.devices.first?.id
            self.tableView.mj_footer?.resetNoMoreData()
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
            print("LBLog bluetooth header refresh done, count \(self.devices.count)")
        }
    }

    /// 上拉加载：每次追加 2 个新设备，超过 12 个提示没有更多
    private func footerLoadMore() {
        print("LBLog bluetooth footer load more begin")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            if self.devices.count >= 16 {
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
                print("LBLog bluetooth no more data")
                return
            }
            let count = self.devices.count
            self.devices.append(contentsOf: [
                LBBluetoothDevice(name: "NEW_DEVICE_\(count + 1)"),
                LBBluetoothDevice(name: "NEW_DEVICE_\(count + 2)"),
                LBBluetoothDevice(name: "NEW_DEVICE_\(count + 3)"),
            ])
            self.tableView.reloadData()
            self.tableView.mj_footer?.endRefreshing()
            print("LBLog bluetooth load more done, count \(self.devices.count)")
        }
    }

    // MARK: - 交互
    /// 单选切换：选中新设备，原选中设备自动回到「其它」列表
    private func selectDevice(_ device: LBBluetoothDevice) {
        selectedID = device.id
        reloadWithAnimation()
    }

    /// 取消选中：设备回到「其它」列表，上方显示占位
    private func deselectCurrent() {
        selectedID = nil
        reloadWithAnimation()
    }

    private func reloadWithAnimation() {
        UIView.transition(with: tableView, duration: 0.25, options: .transitionCrossDissolve) {
            self.tableView.reloadData()
        }
    }

    // MARK: - swiftUICell 切换
    /// 右上角按钮：切换 cell 的 SwiftUI / UIKit 实现
    @objc private func toggleSwiftUICellTapped() {
        useSwiftUICell.toggle()
        refreshSwiftUICellButton()
        reloadWithAnimation()
    }

    /// 选中时蓝底白字高亮，未选中蓝字透底
    private func refreshSwiftUICellButton() {
        if useSwiftUICell {
            swiftUICellButton.backgroundColor = UIColor.blt.hexColor(0x0E8AFD)
            swiftUICellButton.setTitleColor(.white, for: .normal)
        } else {
            swiftUICellButton.backgroundColor = .clear
            swiftUICellButton.setTitleColor(UIColor.blt.hexColor(0x0E8AFD), for: .normal)
        }
    }
}

// MARK: - UITableViewDataSource / Delegate
extension LBBluetoothListViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    /// section 0：当前选中设备（固定 1 行，空态显示占位）；section 1：「其它」分组
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : otherDevices.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// swiftUICell 按钮选中时走 SwiftUI 实现，否则走 UIKit cell
        if useSwiftUICell {
            let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LBBluetoothSwiftUICell.self), for: indexPath) as! LBBluetoothSwiftUICell
            cell.render(rowView: makeSwiftUIRowView(for: indexPath))
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LBBluetoothDeviceCell.self), for: indexPath) as! LBBluetoothDeviceCell
        if indexPath.section == 0 {
            if let device = selectedDevice {
                cell.renderSelected(device: device)
            } else {
                cell.renderEmptyPlaceholder()
            }
        } else {
            cell.renderNormal(device: otherDevices[indexPath.row], showsSeparator: indexPath.row < otherDevices.count - 1)
        }
        return cell
    }

    /// 构造 SwiftUI 行视图：三种渲染状态与 UIKit cell 对齐
    private func makeSwiftUIRowView(for indexPath: IndexPath) -> LBBluetoothSwiftUIRowView {
        if indexPath.section == 0 {
            if let device = selectedDevice {
                return LBBluetoothSwiftUIRowView(name: device.name, mode: .selected)
            }
            return LBBluetoothSwiftUIRowView(name: "", mode: .placeholder)
        }
        let device = otherDevices[indexPath.row]
        return LBBluetoothSwiftUIRowView(name: device.name, mode: .normal, showsSeparator: indexPath.row < otherDevices.count - 1)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard selectedDevice != nil else { return }
            deselectCurrent()
        } else {
            selectDevice(otherDevices[indexPath.row])
        }
    }

    // MARK: - section 头尾：制造卡片间距与「其它」分组标题
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = UIView()
            header.backgroundColor = .clear
            let label = UILabel.blt.initWithFont(font: .blt.normalFont(13), textColor: .blt.sixsixBlackColor())
            label.text = "其它"
            header.addSubview(label)
            label.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(12)
                make.left.equalToSuperview().offset(12)
                make.bottom.equalToSuperview().offset(-12)
            }
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 0.01 : 36
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        0.01
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        indexPath.section == 0 ? 54 : 51
    }
}

// MARK: - Cell（BLTUIKit 约定创建控件）
private class LBBluetoothDeviceCell: UITableViewCell {

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

    /// 选中对勾：渐变蓝（设计稿 duihao 图层），取项目蓝还原
    private lazy var checkImageView: UIImageView = {
        let imageView = UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage(systemName: "checkmark")?.withTintColor(UIColor.blt.hexColor(0x0E8AFD), renderingMode: .alwaysOriginal))
        return imageView
    }()

    /// 行间分割线 0.5pt #DDD，左缩进 12
    private lazy var separatorLine: UIView = {
        let view = UIView.blt.initWithBackgroundColor(color: UIColor.blt.hexColor(0xDDDDDD))
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
        setupSubview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        contentView.addSubview(nameLabel)
        contentView.addSubview(statusLabel)
        contentView.addSubview(checkImageView)
        contentView.addSubview(separatorLine)

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

    // MARK: - 渲染
    /// 上卡片选中态：设备名 + 对勾
    func renderSelected(device: LBBluetoothDevice) {
        nameLabel.text = device.name
        nameLabel.textColor = .blt.threeThreeBlackColor()
        statusLabel.isHidden = true
        checkImageView.isHidden = false
        separatorLine.isHidden = true
    }

    /// 「其它」分组行：设备名 + 未连接 + 分割线（末行无）
    func renderNormal(device: LBBluetoothDevice, showsSeparator: Bool) {
        nameLabel.text = device.name
        nameLabel.textColor = .blt.threeThreeBlackColor()
        statusLabel.text = "未连接"
        statusLabel.isHidden = false
        checkImageView.isHidden = true
        separatorLine.isHidden = !showsSeparator
    }

    /// 全部未选时上卡片占位
    func renderEmptyPlaceholder() {
        nameLabel.text = "暂未选择设备"
        nameLabel.textColor = .blt.ninenineBlackColor()
        statusLabel.isHidden = true
        checkImageView.isHidden = true
        separatorLine.isHidden = true
    }
}

// MARK: - SwiftUI 版 Cell（右上角 swiftUICell 按钮选中时启用）
/// 内嵌 UIHostingController 承载 SwiftUI 行视图；复用时直接替换 rootView 刷新
private class LBBluetoothSwiftUICell: UITableViewCell {

    private var hostingController: UIHostingController<LBBluetoothSwiftUIRowView>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func render(rowView: LBBluetoothSwiftUIRowView) {
        if let hostingController {
            hostingController.rootView = rowView
        } else {
            let controller = UIHostingController(rootView: rowView)
            controller.view.backgroundColor = .clear
            contentView.addSubview(controller.view)
            controller.view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            hostingController = controller
        }
    }
}

// MARK: - SwiftUI 行视图（样式与 UIKit cell 三种渲染状态一一对应）
private struct LBBluetoothSwiftUIRowView: View {

    enum RowMode {
        case selected       // 上卡片选中态：设备名 + 蓝色对勾
        case normal         // 「其它」分组行：设备名 + 未连接
        case placeholder    // 上卡片空态占位
    }

    let name: String
    let mode: RowMode
    /// 普通态是否显示底部分割线（末行无）
    var showsSeparator: Bool = false

    private let nameColor = Color(red: 0x33 / 255, green: 0x33 / 255, blue: 0x33 / 255)
    private let statusColor = Color(red: 0x77 / 255, green: 0x77 / 255, blue: 0x77 / 255)
    private let placeholderColor = Color(red: 0x99 / 255, green: 0x99 / 255, blue: 0x99 / 255)
    private let separatorColor = Color(red: 0xDD / 255, green: 0xDD / 255, blue: 0xDD / 255)
    private let checkColor = Color(red: 0x0E / 255, green: 0x8A / 255, blue: 0xFD / 255)

    var body: some View {
        HStack {
            switch mode {
            case .selected:
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(nameColor)
                Spacer()
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(checkColor)
            case .normal:
                Text(name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(nameColor)
                Spacer()
                Text("未连接")
                    .font(.system(size: 14))
                    .foregroundColor(statusColor)
            case .placeholder:
                Text("暂未选择设备")
                    .font(.system(size: 14))
                    .foregroundColor(placeholderColor)
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .bottom) {
            if showsSeparator && mode == .normal {
                Rectangle()
                    .fill(separatorColor)
                    .frame(height: 0.5)
                    .padding(.leading, 12)
            }
        }
    }
}
