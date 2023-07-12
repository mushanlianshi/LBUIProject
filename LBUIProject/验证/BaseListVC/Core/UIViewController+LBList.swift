//
//  UIViewController+LBList.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/25.
//

import Foundation
import MJRefresh

@objc enum LBListViewRefreshType: Int {
    case none = 0
    case onlyRefresh
    case onlyLoadMore
    case both
}



private var lbTableViewKey: Void?
private var lbCollectionViewKey: Void?
private var lbCollectionLayoutKey: Void?
private var lbViewModelKey: Void?

/// listView的分类
extension UIViewController{
    
    var lb_collectionLayout: UICollectionViewFlowLayout?{
        set{
            objc_setAssociatedObject(self, &lbCollectionLayoutKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &lbCollectionLayoutKey) as? UICollectionViewFlowLayout
        }
    }
    
    var lb_tableView: UITableView?{
        set{
            objc_setAssociatedObject(self, &lbTableViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &lbTableViewKey) as? UITableView
        }
    }
    
    var lb_collectionView: UICollectionView?{
        set{
            objc_setAssociatedObject(self, &lbCollectionViewKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &lbCollectionViewKey) as? UICollectionView
        }
    }
    
    var lb_viewModel: (any LBListViewModelProtocol)?{
        set{
            objc_setAssociatedObject(self, &lbViewModelKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get{
            return objc_getAssociatedObject(self, &lbViewModelKey) as? (any LBListViewModelProtocol)
        }
    }
    
    
    func addLBTableView(_ refreshType: LBListViewRefreshType = .both) {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        view.addSubview(tableView)
        self.lb_tableView = tableView
        setListRefreshType(refreshType: refreshType, listView: tableView)
    }
    
    func addLBCollectionView(_ refreshType: LBListViewRefreshType = .both) {
        let layout = UICollectionViewFlowLayout()
        self.lb_collectionLayout = layout
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
        self.lb_collectionView = collectionView
        setListRefreshType(refreshType: refreshType, listView: collectionView)
    }

    
    
    private func setListRefreshType(refreshType: LBListViewRefreshType = .both, listView: UIScrollView){
        func addRefreshHeader(){
            listView.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
                [weak self, weak listView] in
                ///1.底部正在刷新 结束加载更多  取消上次任务 从新刷新
                if let isFooterRefresh = listView?.mj_footer?.isRefreshing, isFooterRefresh{
                    listView?.mj_footer?.endRefreshing()
                    self?.cancelCurrentTask()
                }
                
                self?.loadDataIsFooter(isFooter: false)
            })
        }
        
        func addLoadMoreFooter(){
            listView.mj_footer = MJRefreshBackNormalFooter.init(refreshingBlock: {
                [weak self, weak listView] in
                ///正在下拉刷新  取消掉  开始加载更多
                if let isRefreshing = listView?.mj_header?.isRefreshing, isRefreshing{
                    listView?.mj_header?.endRefreshing()
                    self?.cancelCurrentTask()
                }
                self?.loadDataIsFooter(isFooter: true)
            })
        }
        
        switch refreshType {
        case .none:
            break
        case .onlyRefresh:
            addRefreshHeader()
        case .onlyLoadMore:
            addLoadMoreFooter()
        case .both:
            addRefreshHeader()
            addLoadMoreFooter()
        }
    }
    
    
    @objc func loadDataIsFooter(isFooter: Bool) {
        self.lb_viewModel?.loadDataIsFooter(isFooter, successBlock: {
            [weak self] in
            self?.closeRefreshOrLoadMoreAnimating()
            self?.judgeShowPlaceHolder()
        }, failureBlock: { [weak self] error in
            self?.closeRefreshOrLoadMoreAnimating()
        })
    }
    
    func cancelCurrentTask() {
        
    }
    
    func closeRefreshOrLoadMoreAnimating() {
        self.currentListView().mj_header?.endRefreshing()
        self.currentListView().mj_footer?.endRefreshing()
    }
    
    func judgeShowPlaceHolder() {
//        self.currentListView().reloadData()
        guard let vm = lb_viewModel else { return }
//        if vm.dataList.isEmpty {
            ///展位图
//        }else{
//            ///隐藏展位图
//        }
        if vm.hasMoreData {
            self.currentListView().mj_footer?.resetNoMoreData()
        }else{
            self.currentListView().mj_footer?.endRefreshingWithNoMoreData()
        }
    }
    
    private func currentListView() -> UIScrollView{
        guard let tableView = lb_tableView else { return self.lb_collectionView! }
        return tableView
    }
    
}
