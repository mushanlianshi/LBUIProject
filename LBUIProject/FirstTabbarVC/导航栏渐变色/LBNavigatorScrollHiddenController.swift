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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "导航栏渐变"
        self.view.addSubview(tableView)
        animator.scrollView = tableView
        animator.animationBlock = {
            [weak self] animator, isHidden in
            self?.navigationController?.setNavigationBarHidden(isHidden, animated: true)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = self.view.bounds
        print("LBLog self.view frame \(self.view.frame)")
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


