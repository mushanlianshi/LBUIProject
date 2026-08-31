//
//  LBCombineViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/1/8.
//

import UIKit
import Combine

enum LBTestEnum1{
    case one
    case two(_ name: String)
//    var property: String?
}

class LBCombineViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    lazy var viewModel = LBCombineViewModel()
    
    lazy var combineView = LBCombineView()

    /// 滚动限流演示：KVO publisher + throttle
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .blt.f6BackgroundColor()
        return scrollView
    }()

    override func viewDidLoad() {

        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Swift 原生的Combine"

        view.addSubview(combineView)
        combineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        setupScrollView()
        bindSubject()
    }

    // MARK: - 滚动限流演示
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(combineView.snp.bottom).offset(12)
        }
        /// 10 个色块撑起 contentSize，制造可滚动内容
        var lastView: UIView?
        for index in 0..<20 {
            let label = UILabel.blt.initWithText(text: "滚动块 \(index + 1)", font: .blt.mediumFont(16), textColor: .white)
            label.textAlignment = .center
            label.backgroundColor = UIColor.blt.hexColor(0x0E8AFD).withAlphaComponent(0.1 + 0.9 * CGFloat(index) / 9)
            scrollView.addSubview(label)
            label.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(14)
                make.right.equalToSuperview().offset(-14)
                make.height.equalTo(80)
                if let lastView {
                    make.top.equalTo(lastView.snp.bottom).offset(10)
                } else {
                    make.top.equalToSuperview().offset(10)
                }
            }
            lastView = label
        }
        lastView?.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-20)
        }
    }

    /// UIScrollView 不是 UIControl（项目 UIControl 扩展覆盖不到），
    /// 用 Combine 原生 KVO publisher 把 contentOffset 转成数据流再限流。
    /// throttle(50ms, latest: true)：滚动期间每 50ms 至多透传一次最新 offset。
    /// 注意 scheduler 必须用 DispatchQueue.main 而非 RunLoop.main：
    /// 滚动时主 RunLoop 切到 UITrackingRunLoopMode，default mode 的调度
    /// 全部挂起（NSTimer 滚动暂停同源问题），throttle 的窗口计时器不执行，
    /// 表现为滚动全程沉默、停稳后才补一条；GCD 主队列不受 mode 影响
    private func bindScrollViewThrottle() {
        scrollView.publisher(for: \.contentOffset)
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .sink { offset in
                print("LBLog throttle 50ms contentOffset (\(Int(offset.x)), \(Int(offset.y)))")
            }
            .store(in: &cancellables)
    }
    
    func bindSubject() {
        viewModel.modelSubject.assign(to: \.model, on: combineView).store(in: &cancellables)
        /// assign(to:on:) 会强持有目标对象：目标是 view 层级时恰好安全（controller 本就持有 view），
        /// 但目标一旦换成 viewModel 等互绑场景就是循环引用。统一改用 [weak self] 的 sink 手动赋值，
        /// 弱引用目标，规避强持有
//        viewModel.modelSubject.sink { [weak self] model in
//            self?.combineView.model = model
//        }.store(in: &cancellables)
        
        // 使用 Combine 将 UIButton 点击事件转为 Publisher
        combineView.changeBtn.publisher(for: .touchUpInside).sink { [weak self] button in
//            debugPrint("LBLog cancellables \(String(describing: self?.cancellables))")
            self?.viewModel.changeModel()
        }.store(in: &cancellables)
        
        
        combineView.textField.publisherForTextChanged().sink { text in
//            debugPrint("LBLog textField  \(String(describing: text))")
        }.store(in: &cancellables)

        bindScrollViewThrottle()
    }
    
    
}
