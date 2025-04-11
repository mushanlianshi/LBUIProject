//
//  LBCombineSampleListController.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/4/2.
//

import Foundation
import Combine

class LBCombineSampleListController: UIViewController {
    
    private lazy var viewModel = LBCombineSampleListViewModel()
    
    // 管理sink声明周期的
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var tableView: UITableView = {
        let tab = UITableView.blt.initTableView(.plain)
        tab.delegate = self
        tab.dataSource = self
        tab.rowHeight = 44
        tab.blt.registerReusableCell(cell: UITableViewCell.self)
        return tab
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        viewModel.loadData()
        viewModel.dataSources.publisher.receive(on: DispatchQueue.main).sink { [weak self] value in
            print("LBLog value is \(value.title)")
            self?.tableView.reloadData()
        }.store(in: &cancellables)
//        viewModel.$dataSources.receive(on: DispatchQueue.main).sink { [weak self] value in
//            print("LBLog value is \(value)")
//            self?.tableView.reloadData()
//        }.store(in: &cancellables)
    }
}


extension LBCombineSampleListController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.blt.dequeueReusableCell(UITableViewCell.self, indexPath: indexPath)
        let model = viewModel.dataSources[indexPath.row]
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModel.dataSources[indexPath.row]
        guard let vc = model.vcClass as? UIViewController.Type else { return  }
        let controller = vc.init()
        controller.navigationItem.title = model.title
        controller.view.backgroundColor = .white
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}
