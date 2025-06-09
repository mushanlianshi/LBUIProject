//
//  LBSwiftUIRefreshListController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/5/9.
//

import Foundation
import SwiftUI

class LBSwiftUIRefreshListController: UIViewController{
    
    private let viewModel = LBSwiftUIRefreshListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "列表上拉加载 下拉刷新"
//        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "", style: <#T##UIBarButtonItem.Style#>, target: <#T##Any?#>, action: <#T##Selector?#>)
        initListView()
    }
    
    func initListView() {
        let listView = LBSwiftUIRefreshListView.init(viewModel: viewModel) {
            [weak self] scrollView in
            self?.viewModel.refreshData(successBlock: {
                scrollView.mj_header?.endRefreshing()
            })
        } loadMoreBlock: {
            [weak self] scrollView in
            self?.viewModel.loadMoreData {
                scrollView.mj_footer?.endRefreshing()
            }
        }

        let hostVC = UIHostingController(rootView: listView)
        self.view.addSubview(hostVC.view)
        hostVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
}
