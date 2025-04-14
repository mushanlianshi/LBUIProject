//
//  ListRefreshViewController.swift
//  JXPagingView
//
//  Created by jiaxin on 2018/8/28.
//  Copyright © 2018年 jiaxin. All rights reserved.
//

import UIKit
import JXPagingView
import JXSegmentedView

class ListRefreshViewController: JXPagingBaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.isNeedHeader = true
        self.isNeedFooter = true
        dataSource.titles = ["1111","2222","3333"]
    }

    override func preferredPagingView() -> JXPagingView {
        return JXPagingListRefreshView(delegate: self, listContainerType: .scrollView)
    }

    //用于测试每次点击segment切换，都触发子列表的下拉刷新
/*
    override func segmentedView(_ segmentedView: JXSegmentedView, didSelectedItemAt index: Int) {
        super.segmentedView(segmentedView, didSelectedItemAt: index)

        guard let list = pagingView.validListDict[index] as? ListViewController else {
            return
        }
        list.tableView.mj_header?.beginRefreshing()
    }
 */
}
