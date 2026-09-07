//
//  DeliveryActivityManager.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/7.
//

import Foundation
import ActivityKit

/// 外卖配送 Live Activity 单例管理器（产品化架构）
///
/// 职责：
/// - 多订单并发：[订单ID: 模拟器] 字典，每个订单独立 Activity + Timer，互不干扰
/// - 跨页面存活：Timer/Activity 由单例持有，发起页面退出配送继续
/// - 状态回收：监听 activityStateUpdates，用户手动清除/系统超时的订单自动出栈
/// - 冷启动恢复：App 重启后接管残留 Activity（demo 无后端统一收尾；真实产品由 APNs 接管）
///
/// 更新模式（pushType: .token 服务端驱动）：
/// Activity.request 传 pushType: .token → pushTokenUpdates 拿到 pushToken → 上报服务端与订单绑定 →
/// 服务端状态机变更时按 token 推 APNs（payload 带 content-state JSON）→
/// 系统直接更新/结束卡片，App 进程被杀也不受影响；本地 update 仅作前台加速
@available(iOS 16.1, *)
final class DeliveryActivityManager {

    static let shared = DeliveryActivityManager()

    /// 进行中的订单模拟器（订单ID → 模拟器）。访问全在主线程（Timer/ActivityKit 回调）
    private var simulators: [String: DeliveryOrderSimulator] = [:]

    /// 页面状态回调：订单ID / 最新状态 / 进行中订单数（页面用它刷新 UI）
    var onOrderUpdate: ((String, LBDeliveryAttributes.ContentState, Int) -> Void)?

    /// 进行中订单数（锁屏可堆叠展示多个；灵动岛紧凑态只显示最新一个，长按可切换）
    var activeOrderCount: Int { simulators.count }

    /// 当前订单快照（页面列表数据源）：订单ID + 最近状态，按发起时间排序
    var orderSnapshots: [(id: String, state: LBDeliveryAttributes.ContentState)] {
        simulators.values
            .sorted { $0.startedAt < $1.startedAt }
            .map { ($0.orderID, $0.lastState) }
    }

    private init() {}

    // MARK: - 发起订单
    /// 发起新订单配送模拟，返回订单ID（如「订单3251」）；实时活动未开启/发起失败返回 nil
    @discardableResult
    func startDelivery() -> String? {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            debugPrint("LBLog 实时活动未开启")
            return nil
        }
        let orderID = "订单\(Int.random(in: 1000...9999))"
        guard let simulator = DeliveryOrderSimulator(
            orderID: orderID,
            onTick: { [weak self] id, state in
                self?.onOrderUpdate?(id, state, self?.activeOrderCount ?? 0)
            },
            onEnd: { [weak self] id in
                self?.removeOrder(id)
            }) else {
            return nil
        }
        simulators[orderID] = simulator
        simulator.start()
        debugPrint("LBLog 发起 \(orderID)，当前 \(simulators.count) 个订单进行中")
        return orderID
    }

    // MARK: - 结束订单
    /// 结束指定订单：终态「已送达/已结束」，卡片保留 5 分钟自动清（期间可手动滑掉）
    func endDelivery(orderID: String, delivered: Bool) {
        guard simulators[orderID] != nil else { return }
        simulators[orderID]?.finish(delivered: delivered)
        removeOrder(orderID)
    }

    /// 结束全部订单（如退出登录等场景）
    func endAll() {
        Array(simulators.keys).forEach { endDelivery(orderID: $0, delivered: true) }
    }

    /// 订单是否还在进行中
    func contains(orderID: String) -> Bool {
        simulators[orderID] != nil
    }

    // MARK: - 深链详情查询
    /// 订单详情数据（深链落地的详情页用）：静态属性（骑手/目的地）+ 最近动态状态
    /// 订单已被回收（结束/用户滑掉）返回 nil，详情页据此展示终态
    func orderInfo(orderID: String) -> (attributes: LBDeliveryAttributes,
                                        state: LBDeliveryAttributes.ContentState)? {
        guard let simulator = simulators[orderID] else { return nil }
        return (simulator.attributes, simulator.lastState)
    }

    // MARK: - 内部
    private func removeOrder(_ orderID: String) {
        simulators[orderID]?.cleanup()
        simulators.removeValue(forKey: orderID)
        onOrderUpdate?(orderID,
                       .init(remainingDistance: 0, progress: 1,
                             statusText: "已结束", isDelivered: true),
                       activeOrderCount)
    }
}

// MARK: - 单订单模拟器
/// 一个订单 = 一个 Activity + 一个 Timer（每 5 秒一拍，75 秒自动送达）
@available(iOS 16.1, *)
private final class DeliveryOrderSimulator {

    let orderID: String

    /// 发起时的静态属性（骑手/目的地，深链详情页展示用）
    private(set) var attributes: LBDeliveryAttributes!

    private var activity: Activity<LBDeliveryAttributes>?
    private var stateTask: Task<Void, Never>?
    /// pushToken 监听任务（token 异步就绪 + 可能被系统更换，需持续监听）
    private var tokenTask: Task<Void, Never>?
    private var timer: Timer?
    private var elapsed: TimeInterval = 0
    private var isFinished = false
    /// 发起时间戳（列表排序用）
    private(set) var startedAt: TimeInterval = Date().timeIntervalSince1970
    /// 最近一次状态（页面快照展示）
    private(set) var lastState: LBDeliveryAttributes.ContentState

    private let totalDuration: TimeInterval = 75
    private let updateInterval: TimeInterval = 5
    private let totalDistance: Double = 5.0

    private let onTick: (String, LBDeliveryAttributes.ContentState) -> Void
    private let onEnd: (String) -> Void

    init?(orderID: String,
          onTick: @escaping (String, LBDeliveryAttributes.ContentState) -> Void,
          onEnd: @escaping (String) -> Void) {
        self.orderID = orderID
        self.onTick = onTick
        self.onEnd = onEnd
        self.lastState = .init(remainingDistance: totalDistance,
                               progress: 0,
                               statusText: "骑手已接单，正在取餐",
                               isDelivered: false)

        let attributes = LBDeliveryAttributes(orderID: orderID,
                                              destination: "滨江星耀城",
                                              riderName: "骑手 · 张师傅")
        self.attributes = attributes
        let state = LBDeliveryAttributes.ContentState(remainingDistance: totalDistance,
                                                      progress: 0,
                                                      statusText: "骑手已接单，正在取餐",
                                                      isDelivered: false)
        do {
            /// pushType: .token = 服务端驱动模式：
            /// 1. pushToken 异步就绪（observePushToken 监听）→ 上报服务端与订单绑定
            /// 2. 此后服务端按 token 推 APNs 即可更新/结束卡片，App 被杀也生效
            /// 3. 本地 update 与远程推送并存，系统按 timestamp 新者生效
            /// 注意：模拟器无 APNs 环境，pushToken 可能永远不下发（真机才完整可用）
            let created = try Activity.request(attributes: attributes,
                                                contentState: state,
                                                pushType: .token)
            activity = created
            observeState(created)
            observePushToken(created, orderID: orderID)
        } catch {
            debugPrint("LBLog \(orderID) Activity 发起失败 \(error)")
            return nil
        }
    }

    // MARK: - 生命周期
    func start() {
        let timer = Timer(timeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        guard !isFinished else { return }
        elapsed += updateInterval
        let progress = min(elapsed / totalDuration, 1)
        let distance = max(totalDistance * (1 - progress), 0)

        if elapsed >= totalDuration {
            // 75 秒自然送达
            lastState = .init(remainingDistance: 0, progress: 1,
                              statusText: "订单已送达", isDelivered: true)
            update(distance: 0, progress: 1, statusText: "订单已送达", isDelivered: true)
            finish(delivered: true)
            onEnd(orderID)
        } else {
            let state = LBDeliveryAttributes.ContentState(remainingDistance: distance,
                                                          progress: progress,
                                                          statusText: "骑手正在飞奔中",
                                                          isDelivered: false)
            lastState = state
            update(distance: distance, progress: progress, statusText: "骑手正在飞奔中", isDelivered: false)
            onTick(orderID, state)
        }
    }

    /// 终止（外部结束 / 自然送达）。幂等
    func finish(delivered: Bool) {
        guard !isFinished else { return }
        isFinished = true
        update(distance: 0, progress: 1,
               statusText: delivered ? "订单已送达" : "配送已结束",
               isDelivered: true)
        endActivity(delivered: delivered)
    }

    /// 清理 Timer 与监听（订单出栈/用户滑掉时调用）。幂等
    func cleanup() {
        isFinished = true
        timer?.invalidate()
        timer = nil
        stateTask?.cancel()
        stateTask = nil
        tokenTask?.cancel()
        tokenTask = nil
    }

    // MARK: - Activity 操作
    private func update(distance: Double, progress: Double, statusText: String, isDelivered: Bool) {
        let state = LBDeliveryAttributes.ContentState(remainingDistance: distance,
                                                      progress: progress,
                                                      statusText: statusText,
                                                      isDelivered: isDelivered)
        Task { [activity] in
            await activity?.update(using: state)
        }
    }

    private func endActivity(delivered: Bool) {
        let finalState = LBDeliveryAttributes.ContentState(remainingDistance: 0,
                                                           progress: 1,
                                                           statusText: delivered ? "订单已送达" : "配送已结束",
                                                           isDelivered: true)
        Task { [activity] in
            /// 结束态保留 5 分钟自动清（美团交互：期间用户也可手动滑掉）
            await activity?.end(using: finalState,
                                dismissalPolicy: .after(Date().addingTimeInterval(5 * 60)))
        }
    }

    // MARK: - 状态监听（用户手动清除/系统超时 → 回收订单）
    private func observeState(_ activity: Activity<LBDeliveryAttributes>) {
        stateTask = Task { [weak self] in
            for await state in activity.activityStateUpdates {
                guard let self else { return }
                switch state {
                case .dismissed, .ended:
                    debugPrint("LBLog \(self.orderID) 被用户清除/系统结束")
                    await MainActor.run {
                        self.onEnd(self.orderID)
                    }
                default:
                    break
                }
            }
        }
    }

    // MARK: - pushToken 监听（服务端驱动模式核心）
    /// token 异步就绪，且系统可能更换（推送环境变化等），必须持续监听整条流
    /// 真实产品：拿到 token 后连同 orderID 上报服务端绑定，之后服务端按 token 推 APNs：
    /// - 更新：payload 带 content-state JSON（字段与 ContentState 一一对应）
    /// - 结束：payload 带 "event": "end"（系统直接移除灵动岛/锁屏卡片，无需唤醒 App）
    private func observePushToken(_ activity: Activity<LBDeliveryAttributes>, orderID: String) {
        tokenTask = Task { [weak self] in
            for await data in activity.pushTokenUpdates {
                guard !data.isEmpty else { continue }
                /// 二进制 token 转 16 进制字符串（APNs 推送要求此格式）
                let token = data.map { String(format: "%02x", $0) }.joined()
                debugPrint("LBLog \(orderID) pushToken 就绪：\(token)")
                self?.reportPushToken(orderID: orderID, token: token)
            }
        }
    }

    /// 上报服务端占位（demo 无后端，仅打印）。
    /// 真实产品替换为网络请求：POST /api/order/bindActivityToken { orderID, pushToken }，
    /// 之后骑手位置/送达等事件由服务端按 token 推 APNs，App 死活均生效
    private func reportPushToken(orderID: String, token: String) {
        // TODO: 接入真实后端时替换为网络上报
        debugPrint("LBLog [上报占位] \(orderID) → pushToken \(token)")
    }
}
