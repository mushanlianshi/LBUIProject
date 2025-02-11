//
//  LBCombineViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/1/8.
//

import UIKit
import Combine

class LBCombineViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    lazy var viewModel = LBCombineViewModel()
    
    lazy var combineView = LBCombineView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Swift 原生的Combine"
        
        view.addSubview(combineView)
        combineView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
        }
        bindSubject()
    }
    
    func bindSubject() {
        viewModel.modelSubject.assign(to: \.model, on: combineView).store(in: &cancellables)
        
        // 使用 Combine 将 UIButton 点击事件转为 Publisher
        combineView.changeBtn.publisher(for: .touchUpInside).sink { [weak self] button in
//            debugPrint("LBLog cancellables \(String(describing: self?.cancellables))")
            self?.viewModel.changeModel()
        }.store(in: &cancellables)
        
        
        combineView.textField.publisherForTextChanged().sink { text in
//            debugPrint("LBLog textField  \(String(describing: text))")
        }.store(in: &cancellables)
        
    }
    
    
}
