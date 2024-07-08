//
//  LBScrollViewAnimatingExampleController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/19.
//

import UIKit

class LBScrollViewAnimatingExampleController: LBBaseCollectionViewController {
    
    override var dataSources: [LBListItemModel]{
        get{
            [
                LBListItemModel.init(title: "向上隐藏 向下展示效果的", vcClass: LBListScrollAnimatingController.self),
                LBListItemModel.init(title: "headerImageView变大变小消失的", vcClass: LBHeaderImageScaleDismissViewController.self),
            ]
        }
        set{}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "列表滚动效果的"
        collectionView.reloadData()
    }

}

