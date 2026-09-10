//
//  LBDeliverySimulateViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/7.
//

import UIKit
import SnapKit
import UserNotifications

/// 入口 wrapper（无版本限制）：iOS 16.1+ 转发真实页面，低版本展示提示。
/// 真实页面类因引用 ActivityKit 类型必须整类 @available(16.1)，不能直接经反射
/// 无参构造注册（低版本实例化崩溃），所以入口注册本 wrapper
class LBDeliveryEntryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if #available(iOS 16.1, *) {
            let vc = LBDeliverySimulateViewController()
            addChild(vc)
            view.addSubview(vc.view)
            vc.view.snp.makeConstraints { $0.edges.equalToSuperview() }
            vc.didMove(toParent: self)
        } else {
            let label = UILabel.blt.initWithText(text: "Live Activity 需要 iOS 16.1 及以上系统",
                                                 font: .blt.normalFont(15),
                                                 textColor: .blt.sixsixBlackColor(),
                                                 textAlignment: .center)
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.left.equalToSuperview().offset(20)
                make.right.equalToSuperview().offset(-20)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 标题由真实页面设置；低版本占位标题
        if #available(iOS 16.1, *) {} else {
            navigationItem.title = "外卖配送灵动岛"
        }
    }
}

/// 外卖配送 Live Activity 模拟页（产品化升级版）
/// Activity/Timer 全部由 DeliveryActivityManager 单例持有，页面退出配送继续；
/// 支持多订单并发：每点一次「开始配送」= 新订单（独立灵动岛/锁屏卡片，锁屏堆叠展示）。
/// 结束演示：左滑结束单个订单 / 「全部结束」批量收尾
@available(iOS 16.1, *)
class LBDeliverySimulateViewController: UIViewController {

    /// 列表 cell 高度
    private let rowHeight: CGFloat = 64

    // MARK: - Subviews（BLTUIKit 约定创建）
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .white
        tableView.separatorStyle = .none
        tableView.rowHeight = rowHeight
        tableView.register(OrderCell.self, forCellReuseIdentifier: NSStringFromClass(OrderCell.self))
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    private lazy var startButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "开始配送（新订单）", font: .blt.mediumFont(16), color: .white, target: self, action: #selector(startButtonTapped))
        button.backgroundColor = UIColor.blt.hexColor(0x0E8AFD)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()

    private lazy var endAllButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "全部结束", font: .blt.mediumFont(16), color: UIColor.blt.hexColor(0xFD890E), target: self, action: #selector(endAllButtonTapped))
        button.backgroundColor = UIColor.blt.hexColor(0xFFF5F3)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.blt.hexColor(0xFD890E).cgColor
        return button
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel.blt.initWithText(text: "点击「开始配送」发起实时活动，可多次点击模拟多订单\n锁屏卡片堆叠；灵动岛显示最新订单，长按可切换\n桌面长按空白处可添加「订单配送」小组件（小/中尺寸）",
                                            font: .blt.normalFont(13),
                                            textColor: .blt.sixsixBlackColor(),
                                            textAlignment: .center)
        label.numberOfLines = 0
        return label
    }()

    /// 页面展示的订单快照（orderID → 最近状态）
    private var orderStates: [(id: String, state: LBDeliveryAttributes.ContentState)] = []

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "外卖配送灵动岛"
        view.backgroundColor = .white
        setupSubview()
        bindManager()
    }

    private func setupSubview() {
        view.addSubview(tableView)
        view.addSubview(startButton)
        view.addSubview(endAllButton)
        view.addSubview(statusLabel)

        statusLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(tableView.snp.top).offset(-12)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(120)
            make.bottom.equalTo(startButton.snp.top).offset(-24)
        }
        startButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview().offset(-80)
            make.height.equalTo(44)
        }
        endAllButton.snp.makeConstraints { make in
            make.left.right.height.equalTo(startButton)
            make.top.equalTo(startButton.snp.bottom).offset(16)
        }
    }

    // MARK: - 绑定管理器
    private func bindManager() {
        DeliveryActivityManager.shared.onOrderUpdate = { [weak self] _, _, count in
            DispatchQueue.main.async {
                self?.orderStates = DeliveryActivityManager.shared.orderSnapshots
                self?.tableView.reloadData()
                self?.statusLabel.text = count > 0
                    ? "\(count) 个订单配送中 · 距离实时更新（锁屏/灵动岛可见）\n左滑可结束单个订单"
                    : "点击「开始配送」发起实时活动，可多次点击模拟多订单"
            }
        }
    }

    /// 页面出现时同步一次（管理器里可能有跨页面存活的订单）
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // onOrderUpdate 是单播回调（最后绑定者生效）：
        // 详情页 push 时会覆盖绑定，这里重新绑回，保证从详情页返回后列表继续刷新
        bindManager()
        orderStates = DeliveryActivityManager.shared.orderSnapshots
        tableView.reloadData()
    }

    // MARK: - Actions
    @objc private func startButtonTapped() {
        guard let orderID = DeliveryActivityManager.shared.startDelivery() else {
            statusLabel.text = "发起失败：实时活动未开启（设置 > Face ID 与密码 > 实时活动）"
            return
        }
        statusLabel.text = "已发起 \(orderID)，可在锁屏/灵动岛查看"
        requestNotificationPermissionIfNeeded()
    }

    /// 全部结束（演示批量结束场景）
    @objc private func endAllButtonTapped() {
        DeliveryActivityManager.shared.endAll()
        statusLabel.text = "全部订单已结束（结束态保留 5 分钟自动清）"
    }

    private func requestNotificationPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
            }
        }
    }

    deinit {
        DeliveryActivityManager.shared.onOrderUpdate = nil
    }
}

// MARK: - UITableViewDataSource / Delegate
@available(iOS 16.1, *)
extension LBDeliverySimulateViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderStates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(OrderCell.self), for: indexPath) as! OrderCell
        let item = orderStates[indexPath.row]
        cell.render(orderID: item.id, state: item.state)
        return cell
    }

    /// 左滑结束单个订单（演示按订单ID定向结束）
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let endAction = UITableViewRowAction(style: .destructive, title: "结束") { [weak self] _, indexPath in
            guard let self else { return }
            let orderID = self.orderStates[indexPath.row].id
            DeliveryActivityManager.shared.endDelivery(orderID: orderID, delivered: true)
        }
        return [endAction]
    }
}

// MARK: - Cell（BLTUIKit 约定创建）
@available(iOS 16.1, *)
private class OrderCell: UITableViewCell {

    private lazy var orderLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.mediumFont(15), textColor: .blt.threeThreeBlackColor())
        return label
    }()

    private lazy var detailLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(13), textColor: .blt.sixsixBlackColor())
        return label
    }()

    private lazy var iconView: UIImageView = {
        let imageView = UIImageView.blt.initWithMode(mode: .scaleAspectFit, image: UIImage(systemName: "bicycle")?.withTintColor(UIColor.blt.hexColor(0x0E8AFD), renderingMode: .alwaysOriginal))
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupSubview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubview() {
        contentView.addSubview(iconView)
        contentView.addSubview(orderLabel)
        contentView.addSubview(detailLabel)

        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(24)
        }
        orderLabel.snp.makeConstraints { make in
            make.left.equalTo(iconView.snp.right).offset(10)
            make.top.equalToSuperview().offset(12)
        }
        detailLabel.snp.makeConstraints { make in
            make.left.equalTo(orderLabel)
            make.top.equalTo(orderLabel.snp.bottom).offset(4)
        }
    }

    func render(orderID: String, state: LBDeliveryAttributes.ContentState) {
        orderLabel.text = orderID
        detailLabel.text = state.isDelivered
            ? "已送达"
            : String(format: "距目的地 %.1f km · %@", state.remainingDistance, state.statusText)
    }
}

// MARK: - 通知（保留模拟推送链路占位）
@available(iOS 16.1, *)
extension LBDeliverySimulateViewController: UNUserNotificationCenterDelegate {
}
