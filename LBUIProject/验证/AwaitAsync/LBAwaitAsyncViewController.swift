//
//  LBAwaitAsyncViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/21.
//

import UIKit
import SnapKit

/// 模拟接口异常
enum LBHouseRequestError: Error {
    case brokerRequestFailed(String)
}

/// 模拟接口异常
enum LBHouseOtherRequestError: Error {
    case otherFailed(String)
}

class LBAwaitAsyncViewController: UIViewController {

    // MARK: - Subviews
    /// 顺序 await：先房源详情后评价列表，总耗时 ≈ 两个任务之和（5s + 5s = 10s）
    private lazy var serialButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "顺序执行await任务", font: .blt.mediumFont(15), color: .white, target: self, action: #selector(serialButtonTapped))
        button.backgroundColor = UIColor.blt.hexColor(0x0E8AFD)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()

    /// 并发 await：async let 两个任务同时跑，总耗时 ≈ 单个任务（5s）
    private lazy var concurrentButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "并发执行await任务", font: .blt.mediumFont(15), color: .white, target: self, action: #selector(concurrentButtonTapped))
        button.backgroundColor = UIColor.blt.hexColor(0x34C77B)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()

    /// 并发 await 中有任务失败：try await 整体抛错进入 catch
    private lazy var failureButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "await中有任务失败", font: .blt.mediumFont(15), color: .white, target: self, action: #selector(failureButtonTapped))
        button.backgroundColor = UIColor.blt.hexColor(0xFD890E)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true
        return button
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Await Async关键字"
        setupSubview()
    }

    private func setupSubview() {
        view.addSubview(serialButton)
        view.addSubview(concurrentButton)
        view.addSubview(failureButton)

        serialButton.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
            make.centerY.equalToSuperview().offset(-60)
            make.height.equalTo(44)
        }
        concurrentButton.snp.makeConstraints { make in
            make.left.right.height.equalTo(serialButton)
            make.top.equalTo(serialButton.snp.bottom).offset(24)
        }
        failureButton.snp.makeConstraints { make in
            make.left.right.height.equalTo(serialButton)
            make.top.equalTo(concurrentButton.snp.bottom).offset(24)
        }
        Task {
            await testAysnc()
        }
    }
    
    private func testAysnc() async   {
        let value = await requestHouseDetail()
        print("LBLog 接受数据线程 \(Thread.current)")
        print("LBLog value is \(value)")
    }

    // MARK: - 模拟接口（withCheckedContinuation + GCD，与项目既有 async demo 写法一致）

    /// 房源详情：模拟 5 秒后返回
    func requestHouseDetail() async -> [String: String] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                print("LBLog requestHouseDetail 回调线程 \(Thread.current)")
                continuation.resume(returning: [
                    "name": "红树湾 3 室 2 厅",
                    "location": "杭州市滨江区江虹路 88 号",
                ])
            }
        }
    }

    /// 评价列表：模拟 5 秒后返回
    func requestHouseEvaluatedList(houseName: String?) async -> [[String: String]] {
        debugPrint("LBLog houseName \(String(describing: houseName))")
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                print("LBLog requestHouseEvaluatedList 回调线程 \(Thread.current)")
                continuation.resume(returning: [
                    ["title": "采光很好", "content": "南北通透，客厅落地窗采光满分", "time": "2026-08-20"],
                    ["title": "交通方便", "content": "地铁口 300 米，通勤 20 分钟", "time": "2026-08-18"],
                ])
            }
        }
    }

    /// 请求失败任务：模拟 2 秒后接口异常（比另两个任务先失败，验证 catch 时机）
    func requestHouseBroker() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                print("LBLog requestHouseBroker 回调线程 \(Thread.current)")
                continuation.resume(throwing: LBHouseRequestError.brokerRequestFailed("经纪人服务连接超时"))
            }
        }
    }
    
    /// 请求失败任务：模拟 2 秒后接口异常（比另两个任务先失败，验证 catch 时机）
    func requestHouseOtherFailed() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                print("LBLog requestHouseBroker 回调线程 \(Thread.current)")
                continuation.resume(throwing: LBHouseOtherRequestError.otherFailed("经纪人服务连接超时"))
            }
        }
    }

    // MARK: - Actions

    /// 顺序执行：两个 await 依次等待，总耗时 = 5s + 5s ≈ 10s
    @objc private func serialButtonTapped() {
        let start = CFAbsoluteTimeGetCurrent()
        print("LBLog ===== 顺序await任务 点击 =====")
        Task {
            let detail = await requestHouseDetail()
            print("LBLog 顺序await 房源详情 \(detail)")
            let list = await requestHouseEvaluatedList(houseName: detail["name"])
            print("LBLog 顺序await 评价列表 \(list)")
            print("LBLog 接受数据线程 \(Thread.current)")
            print("LBLog 顺序await任务 完成，总耗时 \(String(format: "%.1f", CFAbsoluteTimeGetCurrent() - start))s")
        }
    }

    /// 并发执行：async let 同时发起，各自 await 取结果，总耗时 ≈ 5s
    @objc private func concurrentButtonTapped() {
        let start = CFAbsoluteTimeGetCurrent()
        print("LBLog ===== 并发await任务 点击 =====")
        Task {
            async let detail = requestHouseDetail()
            async let list = requestHouseEvaluatedList(houseName: nil)
            // 两个 await 时任务早已并行跑完/在跑，不会串行等待
            let houseDetail = await detail
            let evaluatedList = await list
            print("LBLog 并发await 房源详情 \(houseDetail)")
            print("LBLog 并发await 评价列表 \(evaluatedList)")
            print("LBLog 接受数据线程 \(Thread.current)")
            print("LBLog 并发await任务 完成，总耗时 \(String(format: "%.1f", CFAbsoluteTimeGetCurrent() - start))s")
        }
    }

    /// 并发 + 失败：三个任务 async let 并发，broker 2s 先抛错 → 整组 try await 抛错进 catch。
    /// 结构化并发语义：async let 兄弟任务在其中一个抛错后会被隐式取消；
    /// 本 demo 用 GCD 模拟不支持响应取消，detail/list 实际仍会在后台跑完但结果被丢弃，
    /// 真实实现（Task.sleep）中会真正中断
    @objc private func failureButtonTapped() {
        let start = CFAbsoluteTimeGetCurrent()
        print("LBLog ===== await中有任务失败 点击 =====")
        Task {
            do {
                async let detail = requestHouseDetail()
                async let list = requestHouseEvaluatedList(houseName: nil)
                async let broker = try requestHouseBroker()
                async let otherFailed = try requestHouseOtherFailed()
                let (houseDetail, evaluatedList, brokerName, other) = try await (detail, list, broker, otherFailed)
                print("LBLog 接受数据线程 \(Thread.current)")
                print("LBLog 失败场景 全部成功 \(houseDetail) \(evaluatedList) \(brokerName) \(other)")
            } catch {
                print("LBLog 失败场景 捕获错误 \(error)")
                print("LBLog 接受数据线程 \(Thread.current)")
                print("LBLog await中有任务失败 完成，总耗时 \(String(format: "%.1f", CFAbsoluteTimeGetCurrent() - start))s")
            }
        }
    }
}
