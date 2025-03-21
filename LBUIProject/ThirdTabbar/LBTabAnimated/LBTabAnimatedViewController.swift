//
//  LBTabAnimatedViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/3/21.
//

import UIKit
import TABAnimated

class LBTabAnimatedViewController: UIViewController {
    
    
    lazy var dataList = [Int]()
    
    private lazy var tableView: UITableView = {
        let tab = UITableView.blt.initTableView(.plain)
        tab.delegate = self
        tab.dataSource = self
        ///  使用约束需要设置这两行
        tab.estimatedRowHeight = 120;
        tab.rowHeight = UITableView.automaticDimension;
        
        tab.blt.registerReusableCell(cell: LBTabAnimatedCell.self)
        tab.backgroundColor = .blt.eeColor()
        tab.separatorStyle = .none
        
//        tab.tabAnimated = TABTableAnimated(cellClass: LBTabAnimatedOCCell.self, cellHeight: 120)
        // 卡片样式
        tab.tabAnimated = TABTableAnimated(cellClass: LBTabAnimatedCardOCCell.self, cellHeight: 140)
        tab.tabAnimated?.canLoadAgain = true
//        tab.tabAnimated?.cellHeight = 100
        tab.tabAnimated?.superAnimationType = .shimmer
        tab.tabAnimated?.adjustBlock = {
            manager in
            /// 设置索引为0的第一个元素 往上移5， 高度100
            manager.animation()?(0)?.up()(5)?.height()(100);
            /// 设置索引为1的第er个元素 往上移5，宽度铺满， 1行，高度18
            manager.animation()?(1)?.reducedWidth()(1)?.line()(1)?.height()(18);
            manager.animation()?(2)?.up()(0)?.reducedWidth()(80)?.height()(18);
            manager.animation()?(3)?.line()(1)?.reducedWidth()(120)?.height()(16);
        }
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 是否开启动画坐标标记，如果开启，也仅在debug环境下有效。
        // 开启后，会在每一个动画元素上增加一个红色的数字，该数字表示该动画元素所在下标，方便快速定位某个动画元素。
        TABAnimated.shared().openAnimationTag = true;
        TABAnimated.shared().shimmerAnimation.shimmerDuration = 1.5
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        startAnimated()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "重新动画", style: .done, target: self, action: #selector(startAnimated))
    }

    @objc private func startAnimated() {
        tableView.tabAnimated?.canLoadAgain = true
        tableView.tab_startAnimation {
            // 请求数据
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                [weak self] in
                self?.endAnimated()
            })
        }
    }
    
    private func endAnimated(){
        dataList.append(contentsOf: Array(0...100))
        tableView.tab_endAnimationEaseOut()
    }
    
}


extension LBTabAnimatedViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.blt.dequeueReusableCell(LBTabAnimatedCell.self, indexPath: indexPath)
        cell.cellModel = "\(dataList[indexPath.row])"
        return cell
    }
    
    
}
