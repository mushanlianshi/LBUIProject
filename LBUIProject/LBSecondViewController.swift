//
//  LBSecondViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/15.
//

import Foundation
import BLTUIKitProject
import UIKit
import BLTSwiftUIKit

class LBSecondViewController: LBBaseCollectionViewController{
    
    override var dataSources: [LBListItemModel]{
        get{
            [
                LBListItemModel.init(title: "notificationView", vcClass: LBNotificationViewController.self),
                LBListItemModel.init(title: "上下左右滑动控件", vcClass: LBTestScrollVerticalHorizontalController.self),
                LBListItemModel.init(title: "折叠", vcClass: LBExpandCloseLabelController.self),
                LBListItemModel.init(title: "stackview嵌套ScrollView", vcClass: UIStackViewInScrollViewController.self),
                LBListItemModel.init(title: "装饰、悬停的UICollectionLayout", vcClass: LBCollectionDecorationStickViewController.self),
                LBListItemModel.init(title: "跨多层响应传递的", vcClass: LBResponderTransferViewController.self),
                LBListItemModel.init(title: "仿微信、头条图片预览", vcClass: LBPreviewImageViewController.self),
                LBListItemModel.init(title: "动画合集", vcClass: LBAnimationHomeListViewController.self),
                LBListItemModel.init(title: "画图片", vcClass: LBDrawImageController.self),
                LBListItemModel.init(title: "抽屉效果", vcClass: LBDrawerSwiperAnimationController.self),
                LBListItemModel.init(title: "图片旋转", vcClass: LLImageClipController.self),
                LBListItemModel.init(title: "IGListKit装饰视图", vcClass: LBIGListKitDecorationViewController.self),
            ]
        }
        set{}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
    }
    
}



extension LBSecondViewController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
}



