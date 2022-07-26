//
//  LBNavigatorAlphaChangeController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/22.
//

import UIKit

class LBNavigatorAlphaChangeController: UIViewController {
    
    lazy var animator = LBNavigationBarScrollChangeAnimator()
    
    lazy var tableView: UITableView = {
        let tab = UITableView.init()
        tab.delegate = self
        tab.dataSource = self
        tab.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tab
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "导航栏渐变"
        self.view.addSubview(tableView)
        animator.scrollView = tableView
        animator.dataSources = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
    }
    
    
//    preferredStatusBarStyle不被调用 是被NavigationController里拦截了  需要在naviController返回topController来响应这个事件
    override var preferredStatusBarStyle: UIStatusBarStyle{
        print("LBLog animator progress \(self.animator.progress())")
        return self.animator.progress() > 0.25 ? .lightContent  : .default
    }
    
}


extension LBNavigatorAlphaChangeController: UITableViewDelegate, UITableViewDataSource{
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
        animator.scrollViewDidScroll(scrollView)
    }
    
}


extension LBNavigatorAlphaChangeController: LBNavigationBarScrollDataSourcesProtocol{
    func backgroundImageOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIImage? {
        self.setNeedsStatusBarAppearanceUpdate()
        return UIImage.imageWithTintColor(color: UIColor.blue.withAlphaComponent(progress))
    }
    
    func titleViewTintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor? {
        return UIColor.blt.gradientColor(fromColor: UIColor.black, toColor: UIColor.white, progress: progress)
    }
    
    func tintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor? {
        return UIColor.blt.gradientColor(fromColor: UIColor.black, toColor: UIColor.white, progress: progress)
    }
}
