//
//  LLDoubleScrollViewPinController1.swift
//  LBUIProject
//
//  Created by liu bin on 2022/5/31.
//

import UIKit

class LLDoubleScrollViewPinController1: UIViewController {
    let rootScrollView = LBRootScrollView()
    let headerView = UIView()
    
    let scrollViewSuperView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    
    let label = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
    }
    
    func setupUI() {
        rootScrollView.showsVerticalScrollIndicator = false
        
        let rootView = UIView()
        view.addSubview(rootView)
        rootView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rootView.addSubview(rootScrollView)
        rootScrollView.addSubview(headerView)
        rootScrollView.addSubview(scrollViewSuperView)
        
        rootScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        rootScrollView.delegate = self
        //        rootScrollView.bounces = false
        
        headerView.backgroundColor = .blue
        headerView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.width.equalTo(rootView)
            make.height.equalTo(300)
        }
        
        
        scrollViewSuperView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.height.equalTo(rootView)
        }
        
        let vc1 = LLDoubleScrollViewChildListController1()
        let vc2 = LLDoubleScrollViewChildListController1()
        let vc3 = LLDoubleScrollViewChildListController1()
        vc1.page = 0
        vc1.delegate = self
        vc2.page = 1
        vc2.delegate = self
        vc3.page = 2
        vc3.delegate = self
        scrollViewSuperView.addSubview(vc1.view)
        scrollViewSuperView.addSubview(vc2.view)
        scrollViewSuperView.addSubview(vc3.view)
        scrollViewSuperView.contentSize = CGSize(width: view.frame.width * 3, height: 0)
        
        vc1.view.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(headerView.snp_bottom)
            make.height.equalTo(view)
            make.width.equalTo(view)
        }
        
        vc2.view.snp.makeConstraints { make in
            make.left.equalTo(vc1.view.snp_right)
            make.top.equalTo(vc1.view)
            make.width.height.equalTo(vc1.view)
        }
        
        vc3.view.snp.makeConstraints { make in
            make.left.equalTo(vc2.view.snp_right)
            make.top.equalTo(vc2.view)
            make.width.height.equalTo(vc2.view)
        }
        self.addChild(vc1)
        self.addChild(vc2)
        self.addChild(vc3)
        
    }
    
    var containerScrollViewOffsetY: CGFloat {
        return scrollViewSuperView.convert(scrollViewSuperView.bounds, to: rootScrollView).minY
    }
    
    func canRootScrollViewScroll() -> Bool {
        return scrollViewSuperView.contentOffset.y == 0
    }
    
    func canContainerScrollViewScroll() -> Bool {
        return rootScrollView.contentOffset.y >= containerScrollViewOffsetY
    }
}

extension LLDoubleScrollViewPinController1: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil{
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "row \(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    
}

extension LLDoubleScrollViewPinController1: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if canContainerScrollViewScroll(){
            scrollView.contentOffset.y = containerScrollViewOffsetY
        }
    }
}

extension LLDoubleScrollViewPinController1: LLDoubleScrollViewChildListScrollDelegate{
    func childScrollViewDidScroll(scrollView: UIScrollView) {
        
        if canRootScrollViewScroll(){
            scrollView.contentOffset.y = 0
        }
        //子listView不可以滚动
        
    }
}




















protocol LLDoubleScrollViewChildListScrollDelegate {
    func childScrollViewDidScroll(scrollView: UIScrollView)
}

class LLDoubleScrollViewChildListController1: UIViewController{
    
    var page = 0
    var delegate: LLDoubleScrollViewChildListScrollDelegate?
    
    weak var rootScrollView: UIScrollView?{
        didSet{
            rootScrollView?.delegate = self
        }
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.bounces = false
        tableView.showsVerticalScrollIndicator = false
        tableView.sectionHeaderHeight = 0.01
        tableView.sectionFooterHeight = 0.01
        return tableView
    }()
    
    lazy var containerScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if page == 1{
            view.backgroundColor = UIColor.systemPink.withAlphaComponent(0.5)
        }else if page == 2{
            view.backgroundColor = UIColor.lightGray
        }
        
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LLDoubleScrollViewChildListController1: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let delegate = self.delegate else { return }
        delegate.childScrollViewDidScroll(scrollView: scrollView)
    }
}


extension LLDoubleScrollViewChildListController1: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text = "page is " + String(page)
        cell?.detailTextLabel?.text = "indexPath row is \(indexPath.row)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
}
