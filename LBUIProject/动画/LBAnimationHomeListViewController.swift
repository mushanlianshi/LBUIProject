//
//  LBAnimationHomeListViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/16.
//

import Foundation

///动画入口controller
class LBAnimationHomeListViewController: LBBaseCollectionViewController {
    
    override var dataSources: [LBListItemModel]{
        get{
            [
                LBListItemModel.init(title: "翻卡片", vcClass: LBFlipCardViewController.self),
                LBListItemModel.init(title: "tableView滚动动画", vcClass: LBScrollViewAnimatingExampleController.self),
                LBListItemModel.init(title: "倒计时动画的", vcClass: LBCutDownNumberAnimationController.self),
                LBListItemModel.init(title: "文字渐入渐出动画", vcClass: LBAnimationRandomFadeTextController.self),
            ]
        }
        set{}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "动画合集"
    }
}
