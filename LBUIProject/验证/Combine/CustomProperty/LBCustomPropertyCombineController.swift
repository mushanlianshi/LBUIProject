//
//  LBCustomPropertyCombineController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/14.
//

import Foundation
import Combine

class LBCustomPropertyCombineController: UIViewController {
    
    private lazy var propertyView = LBCustomPropertyView()
    
    private lazy var viewModel = LBCustomPropertyCombineViewModel()
    
    private lazy var cancellables = Set<AnyCancellable>()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(propertyView)
        propertyView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        bindObserver()
        viewModel.fetchData()
    }
    
    func bindObserver() {
        propertyView.button.blt.bindValidSelectResult(viewModel.validState).store(in: &cancellables)
        propertyView.blt.bindCustomModel(viewModel.modelObserver).store(in: &cancellables)
    }
}
