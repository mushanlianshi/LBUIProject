//
//  LBNetworkBus.swift
//  LBUIProject
//
//  Created by liu bin on 2026/9/1.
//

import Combine

// MARK: - 网络层事件总线
/// 网络层只广播、不碰 UI（单一职责）：
/// - 5005 会话失效：Provider 已自动清 token（即「退出登录」的全部默认动作），
///   UI 层默认不做任何处理；需要弹窗/提示时在全局位置订阅 sessionExpired
/// - 5000 需要登录：需要跳转登录页时，在 AppDelegate / Router 订阅 needLogin
///   执行跳转（demo 项目无登录页，未订阅即无动作）
enum LBNetworkBus {

    /// code = 5005：会话失效（token 已清）
    static let sessionExpired = PassthroughSubject<Void, Never>()

    /// code = 5000：需要登录（跳登录页由订阅方执行）
    static let needLogin = PassthroughSubject<Void, Never>()

    /// 全局订阅入口：真实 App 在 AppDelegate.didFinishLaunching 里调用一次
    /// 示例：
    /// LBNetworkBus.observeGlobalEvents()
    static func observeGlobalEvents() {
        sessionExpired
            .sink { debugPrint("LBLog 网络层 sessionExpired：token 已清，UI 默认不处理") }
            .store(in: &globalCancellables)

        needLogin
            .sink { debugPrint("LBLog 网络层 needLogin：此处替换为跳转登录页") }
            .store(in: &globalCancellables)
    }

    private static var globalCancellables = Set<AnyCancellable>()
}
