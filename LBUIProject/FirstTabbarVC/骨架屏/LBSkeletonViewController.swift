//
//  LBSkeletonViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/22.
//

import Foundation
import UIKit
import SkeletonView

class LBSkeletonViewController: UIViewController{
    
    lazy var dataSources = [LBSkeletonListModel]()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init()
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.register(LBSkeletonListCell.self, forCellReuseIdentifier: LBSkeletonListCell.blt_className)
//        约束自适应高度  需要个值来处理骨架屏  就不能用automaticDimension
//        table.estimatedRowHeight = 120
//        table.estimatedRowHeight = UITableView.automaticDimension
//        table.rowHeight = UITableView.automaticDimension
//        tableview.sectionHeaderHeight = UITableView.automaticDimension
//        tableview.sectionFooterHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120.0
//        tableview.estimatedSectionFooterHeight = 20.0
//        tableview.estimatedSectionHeaderHeight = 20.0
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isSkeletonable = true
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tableView.showAnimatedSkeleton()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            for index in 0...60{
                let model = LBSkeletonListModel.init(title: "title + \(index)", content: "问候为合法欧文哈佛我饿哈佛我和佛为回复我腹黑我合肥我发好哦维护费我哈佛我饿粉红我耳环佛为合肥和违法我腹黑我二号房+ \(index)")
                self.dataSources.append(model)
            }
//            隐藏掉效果
            self.tableView.hideSkeleton()
            self.tableView.reloadData()
        }
    }
    
    deinit {
        print("LBLog LBSkeletonViewController dealloc ")
    }
}


extension LBSkeletonViewController: SkeletonTableViewDataSource, UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LBSkeletonListCell.blt_className, for: indexPath) as? LBSkeletonListCell else { return UITableViewCell() }
        cell.listModel = dataSources[indexPath.row]
        return cell
    }
    
//    处理骨架屏需要遵守的协议
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return LBSkeletonListCell.blt_className
    }
    
//    需要几个可以填满屏幕
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
//    几个section 默认有实现
    func numSections(in collectionSkeletonView: UITableView) -> Int {
        return 1
    }
}
