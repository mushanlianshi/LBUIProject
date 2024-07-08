//
//  LBDragDownNextPageViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/24.
//

import Foundation


//
//  LBNavigatorAlphaChangeController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/22.
//

import UIKit
import BLTUIKitProject
import MJRefresh

class LBDragDownNextPageViewController: UIViewController {
    
    lazy var secondPageView: LBDragDownSecondPageView = {
        let view = LBDragDownSecondPageView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 0))
        view.backHomeBlock = {
            [weak self] in
            self?.pushNormalPageView()
        }
        self.view.addSubview(view)
        return view
    }()
    
    lazy var imageView: UIImageView = {
       let iv = UIImageView()
        iv.image = UIImageNamed("face")
        iv.contentMode = .scaleAspectFill
        iv.frame = CGRect(x: 0, y: -200, width: view.bounds.width, height: 200)
        iv.clipsToBounds = true
        return iv
    }()
    
    lazy var tableView: UITableView = {
        let tab = UITableView.init()
        tab.delegate = self
        tab.dataSource = self
        tab.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            print("LBLog mj_refresh ===")
        })
        tab.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "下拉翻页的"
        tableView.addSubview(imageView)
        tableView.sendSubviewToBack(imageView)
//        tableView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
    }
    
    
    private func pullUpPageView(){
        UIView.animate(withDuration: 0.3) {
            self.secondPageView.snp.remakeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.tableView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(self.secondPageView.snp.bottom)
                make.height.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func pushNormalPageView(){
        UIView.animate(withDuration: 0.3) {
            self.secondPageView.snp.remakeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(0)
            }
            self.tableView.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.top.equalTo(self.secondPageView.snp_bottom)
                make.height.equalToSuperview()
            }
            self.view.layoutIfNeeded()
        }
    }

    
}


extension LBDragDownNextPageViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as? UITableViewCell else { return UITableViewCell() }
        
        cell.textLabel?.text = "indexPath row is \(indexPath.row)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        print("LBlog scrollview content offset \(scrollView.contentOffset.y) \(decelerate)")
        if scrollView.contentOffset.y < -150{
            self.pullUpPageView()
        }
    }
    
}
