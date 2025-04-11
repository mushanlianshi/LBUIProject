//
//  LBLoginCombineController.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/1/9.
//

import Foundation
import Combine

class LBLoginCombineController: UIViewController {
    
    private lazy var loginView = LBLoginCombineContentView()
    
    private lazy var viewModel = LBLoginCombineViewModel()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "登录"
        view.addSubview(loginView)
        loginView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bindSubject()
    }
    
    func bindSubject() {
        // iOS14 才能用assign to
//        loginView.codeTF.blt.publisherForTextChanged().eraseToAnyPublisher().assign(to: &viewModel.$code)
        
        loginView.phoneTF.blt.publisherForTextChanged().assign(to: \.phone, on: viewModel).store(in: &viewModel.cancellables)
        
        loginView.codeTF.blt.publisherForTextChanged().sink { [weak self] text in
            self?.viewModel.code = text
        }.store(in: &viewModel.cancellables)
        
        loginView.agreeBtn.blt.publisher(for: .touchUpInside).sink { [weak self] button in
            button.isSelected = !button.isSelected
            self?.viewModel.isAgree = button.isSelected
        }.store(in: &viewModel.cancellables)
        
        
        /// 融合三个发布者
        /// 融合三个发布者
//        Publishers.CombineLatest3(viewModel.phoneValidPublisher, viewModel.codeValidPublisher, viewModel.$isAgree)
//            .map { $0 && $1 && $2 }               // 筛选逻辑
//            .receive(on: RunLoop.main)              // 在主线程接受
//            .assign(to: \.isEnabled, on: toLogin)   // 结果分配
//            .store(in: &subscriptions)              // 返回值Cancellable对象储存在全局容器中
        
        Publishers.CombineLatest3(viewModel.phoneValidPublisher, viewModel.codeValidPublisher, viewModel.$isAgree)
            .map{ $0 && $1 && $2}
//            .receive(on: RunLoop.main)
            .sink { result in
                debugPrint("LBLog result is \(result) \(Thread.current)")
            }.store(in: &viewModel.cancellables)
        
        Publishers.CombineLatest3(viewModel.phoneValidPublisher, viewModel.codeValidPublisher, viewModel.$isAgree)
            .map{ $0 && $1 && $2}
//            .receive(on: RunLoop.main)
            .assign(to: \.isEnabled, on: loginView.loginBtn)
            .store(in: &viewModel.cancellables)
        
        
    }
    
}
