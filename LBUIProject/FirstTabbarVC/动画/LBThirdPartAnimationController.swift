//
//  LBThirdPartAnimationController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/22.
//

import Foundation
import UIKit
import ViewAnimator
import BLTUIKitProject
import Spring

//第三方库做的动画
class LBThirdPartAnimationController: UIViewController{
    
    lazy var dataSources = [LBSkeletonListModel]()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init()
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.register(LBSkeletonListCell.self, forCellReuseIdentifier: LBSkeletonListCell.blt_className)
        table.estimatedRowHeight = 120.0
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
        
//      ViewAnimator框架做的动画
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            for index in 0...60{
                let model = LBSkeletonListModel.init(title: "title + \(index)", content: "问候为合法欧文哈佛我饿哈佛我和佛为回复我腹黑我合肥我发好哦维护费我哈佛我饿粉红我耳环佛为合肥和违法我腹黑我二号房+ \(index)")
                self.dataSources.append(model)
            }
    //            隐藏掉效果
            self.tableView.hideSkeleton()
            self.tableView.reloadData()
            let fromAnimation = AnimationType.vector(CGVector(dx: 0, dy: 100))
//            let zoomAnimation = AnimationType.zoom(scale: 0.2)
            print("LBLog visicells \(self.tableView.visibleCells)")
            UIView.animate(views: self.tableView.visibleCells, animations: [fromAnimation], delay: 0.5)
        }
        
        let fallButton = SpringButton.blt_button(withTitle: "fall", font: UIFontPFFontSize(16), titleColor: UIColor.white, target: self, selector: #selector(fullButtonClicked(button:)))!
        fallButton.backgroundColor = UIColor.blue.withAlphaComponent(0.8)
        fallButton.blt_layerCornerRaduis = 30
        view.addSubview(fallButton)
        fallButton.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.top.equalTo(80)
            make.width.height.equalTo(60)
        }
        
    }
    
//    Spring框架做的动画
    @objc func fullButtonClicked(button: SpringButton){
        button.animation = Spring.AnimationPreset.Fall.rawValue
        button.curve = Spring.AnimationCurve.EaseIn.rawValue
        button.duration = 1.0
        print("LBLog force \(button.force)")
//        幅度
        button.force = 1.1
        button.animate()
    }
    
    deinit {
        print("LBLog LBSkeletonViewController dealloc ")
    }
}


extension LBThirdPartAnimationController: UITableViewDataSource, UITableViewDelegate{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LBSkeletonListCell.blt_className, for: indexPath) as? LBSkeletonListCell else { return UITableViewCell() }
        cell.listModel = dataSources[indexPath.row]
        return cell
    }
    
}
