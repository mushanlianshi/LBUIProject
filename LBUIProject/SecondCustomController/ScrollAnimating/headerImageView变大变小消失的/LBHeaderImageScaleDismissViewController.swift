//
//  LBHeaderImageScaleDismissViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/19.
//

import UIKit

final class LBHeaderImageScaleDismissViewController: UIViewController {
    
    private lazy var headerView = LBHeaderImageScaleDismissHeaderView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 350))
    
    private lazy var tableView: UITableView = {
        let view = UITableView.init(frame: .zero)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .white
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "headerImageView变大变小消失的"
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.tableHeaderView = headerView
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension LBHeaderImageScaleDismissViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y;
        print("LBLog contentOffsetY is \(contentOffsetY)")
        headerView.scrollDidScroll(contentOffsetY)
//        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 200 + contentOffsetY)
    }
}

extension LBHeaderImageScaleDismissViewController: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "IndexPath \(indexPath.row)";
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
}
