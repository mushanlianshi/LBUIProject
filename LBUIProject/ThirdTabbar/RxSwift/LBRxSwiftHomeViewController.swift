//
//  LBRxSwiftHomeViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/4.
//

import UIKit
import RxSwift

struct LBRxSwiftItem{
    var title = ""
    let vcType: UIViewController.Type
}

class LBRxSwiftHomeViewController: UIViewController {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var dataList = Observable.just(
        [
            LBRxSwiftItem.init(title: "RxSwift练习",vcType: LBRxSwiftPractiseViewController.self),
            LBRxSwiftItem.init(title: "异步多线程RxSwift",vcType: LBRxSwiftAsyncDependController.self),
            LBRxSwiftItem.init(title: "OrEmpty and share",vcType: LBRxSwiftOrEmptyShareController.self),
            LBRxSwiftItem.init(title: "Schedulers",vcType: LBRxSwiftSchedulersViewController.self),
            LBRxSwiftItem.init(title: "操作符Operators",vcType: LBRxSwiftOperatorsViewController.self),
            LBRxSwiftItem.init(title: "Rx实现列表",vcType: LBRxSwiftTableViewController.self),
        ]
    )
    
    lazy var tableView: UITableView = {
        let tab = UITableView.init(frame: view.bounds)
        tab.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        tab.delegate = self
//        tab.dataSource = self
        tab.backgroundColor = .white
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RxSwift"
        
        dataList.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)){
            row, element, cell in
            cell.textLabel?.text = element.title
        }.disposed(by: disposeBag)
        
        
        tableView.rx.modelSelected(LBRxSwiftItem.self).subscribe { item in
            let vcType = item.vcType
            let vc = vcType.init()
            self.navigationController?.pushViewController(vc, animated: true)
        } onError: { error in
            
        }.disposed(by: disposeBag)
        
        view.addSubview(tableView)

    }

}

