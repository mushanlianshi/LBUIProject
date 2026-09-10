//
//  LBDeliveryOrderDetailViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/7.
//

import UIKit
import SnapKit

/// 点击灵动岛/锁屏卡片深链落地的订单详情页
/// 数据来自 DeliveryActivityManager：配送中实时刷新（onOrderUpdate 单播，可见页面持有回调）；
/// 订单已被回收（结束/滑掉）则 manager 查不到，展示终态文案
@available(iOS 16.1, *)
class LBDeliveryOrderDetailViewController: UIViewController {

    /// 深链携带的订单号（路由去重也用它）
    let orderID: String

    // MARK: - Subviews（BLTUIKit 约定创建）
    private lazy var cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    private lazy var riderIconLabel: UILabel = {
        let label = UILabel()
        label.text = "🛵"
        label.font = .systemFont(ofSize: 40)
        label.textAlignment = .center
        return label
    }()

    private lazy var riderLabel: UILabel = {
        UILabel.blt.initWithFont(font: .blt.mediumFont(17), textColor: .blt.threeThreeBlackColor())
    }()

    private lazy var destinationLabel: UILabel = {
        UILabel.blt.initWithFont(font: .blt.normalFont(14), textColor: .blt.sixsixBlackColor())
    }()

    private lazy var distanceLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.mediumFont(34), textColor: .blt.threeThreeBlackColor())
        label.textAlignment = .center
        return label
    }()

    private lazy var progressView: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.progressTintColor = UIColor.blt.hexColor(0x0E8AFD)
        progress.trackTintColor = UIColor.blt.hexColor(0xE8EEF5)
        progress.layer.cornerRadius = 2
        progress.layer.masksToBounds = true
        return progress
    }()

    private lazy var statusLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(14), textColor: .blt.sixsixBlackColor())
        label.textAlignment = .center
        return label
    }()

    private lazy var orderIDLabel: UILabel = {
        let label = UILabel.blt.initWithFont(font: .blt.normalFont(13), textColor: .blt.sixsixBlackColor())
        label.textAlignment = .center
        return label
    }()

    // MARK: - Lifecycle
    init(orderID: String) {
        self.orderID = orderID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "订单详情"
        view.backgroundColor = UIColor.blt.hexColor(0xF4F6F9)
        setupSubviews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // onOrderUpdate 单播（最后绑定者生效）：详情页可见期间由本页持有回调
        bindManager()
        render()
    }

    deinit {
        DeliveryActivityManager.shared.onOrderUpdate = nil
    }

    private func setupSubviews() {
        view.addSubview(cardView)
        cardView.addSubview(riderIconLabel)
        cardView.addSubview(riderLabel)
        cardView.addSubview(destinationLabel)
        cardView.addSubview(distanceLabel)
        cardView.addSubview(progressView)
        cardView.addSubview(statusLabel)
        view.addSubview(orderIDLabel)

        cardView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
        }
        riderIconLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(24)
        }
        riderLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(riderIconLabel.snp.bottom).offset(10)
        }
        destinationLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(riderLabel.snp.bottom).offset(6)
        }
        distanceLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(destinationLabel.snp.bottom).offset(28)
        }
        progressView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(-24)
            make.top.equalTo(distanceLabel.snp.bottom).offset(18)
            make.height.equalTo(4)
        }
        statusLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(progressView.snp.bottom).offset(12)
            make.bottom.equalToSuperview().offset(-24)
        }
        orderIDLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cardView.snp.bottom).offset(20)
        }
    }

    // MARK: - 实时刷新
    private func bindManager() {
        DeliveryActivityManager.shared.onOrderUpdate = { [weak self] id, _, _ in
            DispatchQueue.main.async {
                guard let self, id == self.orderID else { return }
                self.render()
            }
        }
    }

    /// 渲染：配送中展示实时数据；订单已回收展示终态
    private func render() {
        orderIDLabel.text = "订单号 · \(orderID)"
        guard let info = DeliveryActivityManager.shared.orderInfo(orderID: orderID) else {
            riderLabel.text = "配送已完成"
            destinationLabel.text = "感谢您的耐心等待"
            distanceLabel.text = "0.0 km"
            distanceLabel.textColor = UIColor.blt.hexColor(0x34C77B)
            progressView.setProgress(1, animated: false)
            progressView.progressTintColor = UIColor.blt.hexColor(0x34C77B)
            statusLabel.text = "订单已结束（灵动岛/锁屏卡片保留 5 分钟后自动清除）"
            
            distanceLabel.isHidden = true
            progressView.isHidden = true
            
            return
        }
        riderLabel.text = info.attributes.riderName
        destinationLabel.text = "目的地 · \(info.attributes.destination)"
        distanceLabel.text = String(format: "%.1f km", info.state.remainingDistance)
        progressView.setProgress(Float(info.state.progress), animated: true)
        statusLabel.text = info.state.statusText
    }
}

// MARK: - 深链路由
/// 灵动岛/锁屏卡片点击 → openURL 回调 → 本路由解析 orderID → 切 Tab 并 push 订单详情页
/// 类本身不做版本限制（AppDelegate 直接调用无可用性告警），push 前内部做 16.1 检查
final class LBDeliveryDeepLinkRouter: NSObject {

    /// 处理 lbuiproject://deliveryDetail?orderID=xxx
    @objc static func handleOpenURL(_ url: URL) {
        guard url.scheme == "lbuiproject", url.host == "deliveryDetail" else { return }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let orderID = components.queryItems?.first(where: { $0.name == "orderID" })?.value,
              !orderID.isEmpty else {
            debugPrint("LBLog 配送深链缺少 orderID：\(url.absoluteString)")
            return
        }
        debugPrint("LBLog 配送深链回跳订单 \(url)")
        DispatchQueue.main.async {
            pushOrderDetail(orderID: orderID)
        }
    }

    /// 切到「SwiftUI」Tab（配送 demo 挂在 index 4）并 push 订单详情；
    /// 同订单详情页已在栈中则直接弹到它（避免重复堆叠）
    private static func pushOrderDetail(orderID: String) {
        guard #available(iOS 16.1, *) else {
            debugPrint("LBLog 低于 16.1 无 Live Activity，忽略配送深链")
            return
        }
        guard let window = UIApplication.shared.windows.first(where: { $0.isKeyWindow }),
              let tabBar = window.rootViewController as? UITabBarController else {
            debugPrint("LBLog 深链路由失败：未取到 TabBarController")
            return
        }
        tabBar.selectedIndex = 4
        guard let nav = tabBar.selectedViewController as? UINavigationController else { return }
        if let existing = nav.viewControllers.first(where: {
            ($0 as? LBDeliveryOrderDetailViewController)?.orderID == orderID
        }) {
            nav.popToViewController(existing, animated: true)
        } else {
            nav.pushViewController(LBDeliveryOrderDetailViewController(orderID: orderID), animated: true)
        }
    }
}
