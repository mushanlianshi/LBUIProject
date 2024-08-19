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
        self.navigationController?.edgesForExtendedLayout = []
        print("LBLog viewDidLoad 4444")
        self.view.addSubview(tableView)
//        self.automaticallyAdjustsScrollViewInsets = false
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        animator.scrollView = tableView
        animator.dataSources = self
        scrollViewDidScroll(tableView)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
//            appearance.backgroundColor = UIColor.clear
            appearance.backgroundImage = UIImage.imageWithTintColor(color: .clear)
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
//            appearance.backgroundColor = UIColor.clear
            appearance.backgroundImage = UIImage.imageWithTintColor(color: .white)
            appearance.titleTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
        if #available(iOS 11.0, *) {
            print("LBLog tableView contentInset \(tableView.adjustedContentInset)")
        } else {
            // Fallback on earlier versions
        }
    }
    
    
//    preferredStatusBarStyle不被调用 是被NavigationController里拦截了  需要在naviController的childViewControllerForStatusBarStyle 返回topController来响应这个事件
    override var preferredStatusBarStyle: UIStatusBarStyle{
        print("LBLog animator progress \(self.animator.progress())")
        return self.animator.progress() > 0.25 ? .lightContent  : .default
    }
    
}


extension LBNavigatorAlphaChangeController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath) as? UITableViewCell else { return UITableViewCell() }
        
        cell.textLabel?.text = "indexPath row is 222 \(indexPath.row)"
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
//        return UIImage.imageWithTintColor(color: UIColor.blue.withAlphaComponent(progress))
        return UIImage.imageWithTintColor(color: UIColor.white.withAlphaComponent(progress))
    }
    
    func titleViewTintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor? {
//        return UIColor.red.withAlphaComponent(progress)
        return UIColor.blt.gradientColor(fromColor: UIColor.black, toColor: UIColor.red, progress: progress)
    }
    
    func tintColorOfAnimator(animator: LBNavigationBarScrollChangeAnimator, progress: CGFloat) -> UIColor? {
//        return UIColor.blue.withAlphaComponent(progress)
        return UIColor.blt.gradientColor(fromColor: UIColor.black, toColor: UIColor.blue, progress: progress)
    }
}
