//
//  LBThirdSDKController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/27.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class LBThirdSDKController: UIViewController {
    
    lazy var disposeBag = DisposeBag()
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var tableView22: UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    lazy var listDataSources: [[String : Any]] = {
        return [[.title : "RxSwift", .controller : LBThirdSDKController.self],
                [.title : "自定义反转Sequence", .controller : LBCustomReverseSequenceController.self],
                [.title : "自定义操作符", .controller : LBCustomOperatorController.self]
               ]
    }()

    
    override func viewDidLoad() {
//        super.viewDidLoad()
        initTableView()
        print("LBLog reduce is \(test(input: 1,2,3,4))")
    }
    
    func initTableView() {
        view.addSubview(tableView)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let items: Observable<[[String : Any]]> = Observable.create { observer in
            observer.onNext(
                self.listDataSources
            )
            return Disposables.create()
        }
        
        
        
        
        items.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)){
            (row, element, cell) in
            cell.textLabel?.text = element[.title] as? String
        }
        
        tableView.rx.modelSelected([String : Any].self).subscribe(onNext: {
            element in
            self.pushPage(element)
        }).disposed(by: disposeBag)
        
    }
    
    
    func pushPage(_ info: [String : Any]) {
        guard let tmp = info[.controller] as? UIViewController.Type else { return }
        let vc = tmp.init()
        vc.view.backgroundColor = .white
        vc.title = info[.title] as? String
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func test(input: Int...) -> Int{
        let result = input.reduce(100) { x, y in
            print("LBLog x is \(x) y is \(y)")
            return x + y
        }
        return result
    }

}


fileprivate extension String{
    static let title = "title"
    static let controller = "controller"
}
