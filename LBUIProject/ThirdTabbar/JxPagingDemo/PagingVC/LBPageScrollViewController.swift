//
//  LBPageScrollViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/21.
//

import UIKit
import MJRefresh

let BLT_SCREEN_HEIGHT = UIScreen.main.bounds.height

let BLT_SCREEN_WIDTH = UIScreen.main.bounds.width

let BLT_SCREEN_STATUS_BAR_HEIGHT = UIApplication.shared.statusBarFrame.size.height

let BLT_SCREEN_NAVI_HEIGHT = BLT_SCREEN_STATUS_BAR_HEIGHT + 44

func BLT_SCREEN_BOTTOM_SAFE_OFFSET() -> CGFloat{
    if #available(iOS 11.0, *) {
        if let window = UIApplication.shared.delegate?.window {
            return window?.safeAreaInsets.bottom ?? 0
        }
        return 0
    } else {
        return 0
    }
}

class LBPageScrollViewController: UIViewController {
    
    private let contentHeight = UIScreen.main.bounds.size.height - UIApplication.shared.statusBarFrame.height - 44 - BLT_SCREEN_BOTTOM_SAFE_OFFSET() - 60
    
    private var currentScrollListView: UIScrollView?
    
    lazy var childList: [LBPageChildProtocol] = {
        let firstVC = LBPageChildViewController()
        let secondVC = LBPageChildViewController()
        let thirdVC = LBPageChildViewController()
        firstVC.view.blt_showBorderColor(.red)
        secondVC.view.blt_showBorderColor(.black)
        thirdVC.view.blt_showBorderColor(.blue)
        return [firstVC, secondVC, thirdVC]
    }()

    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        return view
    }()
    
    lazy var headerIV: UIImageView = {
        let image: UIImage = UIImage.init(named: "pageView1")!
        let iv = UIImageView.init(image: image)
        let height = Int(self.view.bounds.width * image.size.height / image.size.width)
        iv.frame = CGRect(x: 0, y: 0, width: Int(self.view.bounds.width), height: height)
        return iv
    }()
    
    lazy var segmentView: LBPageSegmentView = {
        let view = LBPageSegmentView.init(titleList: ["title 1", "title 2", "title 3"])
        view.clickBlock = {
            [weak self] index in
        }
        return view
    }()
    
    lazy var tableView: LBMutiScrollTableView = {
        let view = LBMutiScrollTableView.init(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        view.backgroundColor = .white
        view.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            print("LBLog refresh =======")
        })
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildVC()
        self.view.addSubview(tableView)
        tableView.tableHeaderView = headerIV
//        headerIV.snp.makeConstraints { make in
//            make.width.equalTo(self.view)
//        }
//        headerIV.layoutIfNeeded()
//        tableView.tableHeaderView = headerIV
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func addChildVC(){
        ///scrollView 添加VC.view的时候   如果没有设置scrollView的frame或则约束就添加VC.view导致VC.View的大小异常，可能是翻倍。 可屏蔽下面这段设置frame尝试
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: contentHeight)
        for (index, vc) in childList.enumerated(){
            vc.listSuperView().frame = CGRect(x: CGFloat(index) * self.view.bounds.size.width, y: 0, width: self.view.bounds.size.width, height: contentHeight)
//            self.addChild(vc)
            var next: UIResponder? = vc.listSuperView()
            while next != nil {
                if let vc = next as? UIViewController{
                    self.addChild(vc)
                    break
                }
                next = next?.next
            }
            
            scrollView.addSubview(vc.listSuperView())
            vc.childScrollViewDidScroll { [weak self] scrollView in
                self?.currentScrollListView = scrollView
                self?.processChildListViewDidScroll(scrollView: scrollView)
            }
            print("LBLog vc.listSuperView()  \(vc.listSuperView().frame) \(vc)")
        }
        scrollView.contentSize = CGSize(width: self.view.bounds.size.width * CGFloat(childList.count), height: 0)
    }
    
    private func maxContentOffsetY() -> CGFloat{
        return self.headerIV.bounds.height
    }
}


extension LBPageScrollViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        processMainTableViewDidScroll(scrollView)
    }
}

extension LBPageScrollViewController{
    func processChildListViewDidScroll(scrollView: UIScrollView) {
//        print("LBLog scrollView content offsetY \(scrollView.contentOffset.y)")
        //判断mainTableview contentOffset 是不是大于maxContentOffsetY
        if tableView.contentOffset.y < maxContentOffsetY(){
            scrollView.contentOffset = .zero
        }
        else {
            tableView.contentOffset.y = maxContentOffsetY()
        }
    }
    
    func processMainTableViewDidScroll(_ scrollView: UIScrollView)  {
//        print("LBLog maintableview content offset y \(tableView.contentOffset.y)")
        guard let currentScrollView = self.currentScrollListView else { return }
        if currentScrollView.contentOffset.y > 0 {
            tableView.contentOffset.y = maxContentOffsetY()
        }
        if tableView.contentOffset.y < maxContentOffsetY() {
            childList.forEach { vc in
                vc.listScrollView().contentOffset = .zero
            }
        }
        
        //修复listView往上小幅滚动的
        if tableView.contentOffset.y > maxContentOffsetY() && currentScrollView.contentOffset.y == 0 {
            tableView.contentOffset.y = maxContentOffsetY()
        }
    }
}

extension LBPageScrollViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        }
        if scrollView.superview == nil {
            cell?.contentView.addSubview(scrollView)
            scrollView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.segmentView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentHeight
    }
    
}
