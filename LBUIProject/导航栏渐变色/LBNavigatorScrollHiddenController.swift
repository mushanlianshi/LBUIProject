//
//  LBNavigatorScrollHiddenController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/23.
//

import Foundation
import UIKit

class LBNavigatorScrollHiddenController: UIViewController {
    
    lazy var animator = LBNavigationBarScrollHiddenAnimator()
    
    lazy var tableView: UITableView = {
        let tab = UITableView.init()
        tab.delegate = self
        tab.dataSource = self
        tab.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tab
    }()
    
    var testView: UIView? = {
       let view = UIView()
        view.backgroundColor = .lightGray
        view.frame = CGRect(x: 100, y: 100, width: 80, height: 40)
        print("LBlog testView =======")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "导航栏渐变"
        self.view.addSubview(tableView)
        animator.scrollView = tableView
        animator.animationBlock = {
            [weak self] animator, isHidden in
            self?.navigationController?.setNavigationBarHidden(isHidden, animated: true)
        }
        self.view.addSubview(testView!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            [weak self] in
            self?.testView?.removeFromSuperview()
            self?.testView = nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                [weak self] in
                print("lblog 2222 \(self?.testView)")
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
    }
    
}


extension LBNavigatorScrollHiddenController: UITableViewDelegate, UITableViewDataSource{
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
        animator.scrollViewDidScroll(scrollView: scrollView)
    }
    
}


