//
//  LBGPUImageFilterViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/27.
//

import UIKit
import RxSwift

class LBGPUImageFilterViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.showsVerticalScrollIndicator = false
        view.rowHeight = 55
        return view
    }()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var listDataSources: [[String : Any]] = {
        return [[.title : "GPUImage图片滤镜", .controller : LBImageFilterController.self],
                [.title : "GPUImage视频滤镜", .controller : LBVideoFilterController.self],
                [.title : "选择视频添加滤镜", .controller : LBSelectVideoFilterViewController.self]
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        initTableView()
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
        }.disposed(by: disposeBag)
        
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

}
