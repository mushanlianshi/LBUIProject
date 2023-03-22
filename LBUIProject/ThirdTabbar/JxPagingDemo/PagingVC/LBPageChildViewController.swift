//
//  LBPageChildViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/21.
//

import UIKit
import MJRefresh

protocol LBPageChildProtocol {
    
    func childScrollViewDidScroll(callBack: @escaping((_ scrollView: UIScrollView) -> Void))
    
    func listSuperView() -> UIView
    func listScrollView() -> UIScrollView
}

class LBPageChildViewController: UIViewController {
    
    private var didScrollBlock:((_ scrollView: UIScrollView) -> Void)?

    lazy var list: [Int] = {
        var list = [Int]()
        let tmpList = 0...100
        tmpList.forEach({ list.append($0) })
        return list
    }()
    
    lazy var tableView: UITableView = {
        let view = UITableView.init(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            print("LBLog footer load more")
        })
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
        view.addObserver(self, forKeyPath: "frame", options: [.old, .new], context: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("LBLog change is \(change) \(self)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("LBLog view frame \(view.frame)")
        tableView.frame = view.bounds
    }

}

extension LBPageChildViewController: LBPageChildProtocol{
    
    func childScrollViewDidScroll(callBack: @escaping ((UIScrollView) -> Void)) {
        self.didScrollBlock = callBack
    }
    
    func listSuperView() -> UIView {
        return self.view
    }
    
    func listScrollView() -> UIScrollView {
        return self.tableView
    }
}

extension LBPageChildViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScrollBlock?(scrollView)
    }
}

extension LBPageChildViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
            cell?.textLabel?.textColor = .black
        }
        cell?.textLabel?.text = "index row is \(list[indexPath.row])"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = LBPageChildViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}
