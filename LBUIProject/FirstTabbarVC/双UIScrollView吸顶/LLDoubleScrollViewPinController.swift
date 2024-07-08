//
//  LLDoubleScrollViewPinController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/5/31.
//

import UIKit
import BLTUIKitProject

class LLDoubleScrollViewPinController: UIViewController {

    lazy var rootScrollView: LBRootScrollView = {
        let scrollView = LBRootScrollView()
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        scrollView.showsVerticalScrollIndicator = false
//        scrollView.delegate = self
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "scrollview 嵌套吸顶的"
        view.addSubview(rootScrollView)
        rootScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addChildController()
        
        let array = [String]()
        
        for index in 0...array.count - 1{
            print("LBLog index ==== \(index)")
        }
        
    }

    
    private func addChildController(){
        
        let headerLab = UILabel.blt_label(withTitle: "和我腹黑我饿哈佛我和佛无法我饿粉红我和发哦我和佛号万佛湖我饿哈佛潍坊文化佛我和佛我为哈佛我和佛号我饿粉红我耳环佛为哈佛我和佛华为佛我废话我会疯耦合我沃勒哈佛为哈佛我我和范围ofhow哈佛我饿哈佛文浩覅和我佛我饿哈佛我饿哈佛我佛hi偶尔发我和我饿哈佛我和佛后无法", font: UIFontPFFontSize(16), textColor: UIColor.black)!
        headerLab.numberOfLines = 0
        headerLab.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 150)
        rootScrollView.addSubview(headerLab)
        
        let pinLab = UILabel.blt_label(withTitle: "悬浮label", font: UIFontPFMediumFontSize(16), textColor: UIColor.black)!
        pinLab.backgroundColor = UIColor.lightGray
        pinLab.frame = CGRect(x: 0, y: headerLab.frame.maxY, width: view.bounds.width, height: 50)
        rootScrollView.addSubview(pinLab)
        
        
        let firstVC = LLDoubleScrollViewChildListController()
        firstVC.page = 1
        let secondVC = LLDoubleScrollViewChildListController()
        secondVC.page = 2
        let thirdVC = LLDoubleScrollViewChildListController()
        thirdVC.page = 3
        firstVC.rootScrollView = rootScrollView
        secondVC.rootScrollView = rootScrollView
        thirdVC.rootScrollView = rootScrollView
        
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.isScrollEnabled = true
        rootScrollView.addSubview(scrollView)
        scrollView.addSubview(firstVC.view)
        scrollView.addSubview(secondVC.view)
        scrollView.addSubview(thirdVC.view)
        self.addChild(firstVC)
        self.addChild(secondVC)
        self.addChild(thirdVC)
        
        self.rootScrollView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        headerLab.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalToSuperview()
            make.height.equalTo(150)
        }
        
        pinLab.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(headerLab.snp_bottom)
            make.height.equalTo(50)
        }
        
        scrollView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.top.equalTo(pinLab.snp_bottom)
            make.height.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        firstVC.view.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(pinLab.snp_bottom)
            make.height.equalTo(view)
            make.width.equalTo(view)
        }
        
        secondVC.view.snp.makeConstraints { make in
            make.left.equalTo(firstVC.view.snp_right)
            make.top.equalTo(firstVC.view)
            make.width.height.equalTo(firstVC.view)
        }
        
        thirdVC.view.snp.makeConstraints { make in
            make.left.equalTo(secondVC.view.snp_right)
            make.top.equalTo(secondVC.view)
            make.width.height.equalTo(secondVC.view)
        }
        scrollView.contentSize = CGSize(width: view.bounds.size.width * 3, height: 0)
        
    }
    
}



//extension LLDoubleScrollViewPinController: UIScrollViewDelegate{
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("LBLog scrollview is \(scrollView)")
//    }
//}








class LLDoubleScrollViewChildListController: UIViewController{
    
    var page = 0
    
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
//        containerScrollView.contentSize = CGSize(width: view.bounds.size.width, height: 2000)
        
//        view.addSubview(tableView)
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
    }
}

extension LLDoubleScrollViewChildListController: UIScrollViewDelegate{
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("LBLog scrollview111 \(scrollView.blt_className)")
////        如果滑动的位置超过containerScrollViewOffsetY rootScrollView不可以滑动
//        print("LBLog root contentOffset \(rootScrollView?.contentOffset.y) , \(tableView.contentOffset.y) ,\(containerScrollViewOffsetY)")
//        print("LBLog root can scroll \(canRootScrollViewScroll()),\(canContainerScrollViewScroll())")
//        if scrollView === rootScrollView {
//            if canRootScrollViewScroll(){
//                tableView.contentOffset.y = 0
//                return
//            }
//            // 4. scrollView 不能滚动，保持 contentOffset 不变
//            scrollView.contentOffset.y = containerScrollViewOffsetY
//        } else if scrollView === tableView {
//            if canContainerScrollViewScroll(){
//                rootScrollView?.contentOffset.y = containerScrollViewOffsetY
//                return
//            }
//            // 3. containerScrollView 不能滚动，保持 contentOffset 不变
//            tableView.contentOffset.y = 0
//        }
//    }
//
//    var containerScrollViewOffsetY: CGFloat {
//           return tableView.convert(tableView.bounds, to: rootScrollView).minY
//       }
//
//       func canRootScrollViewScroll() -> Bool {
//           return tableView.contentOffset.y == 0
//       }
//
//       func canContainerScrollViewScroll() -> Bool {
//           return rootScrollView!.contentOffset.y >= containerScrollViewOffsetY
//       }
    
}

extension LLDoubleScrollViewChildListController: UITableViewDelegate, UITableViewDataSource{
    
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
