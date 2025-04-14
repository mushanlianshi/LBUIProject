//
//  LBInnerScrollView.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/14.
//

import Foundation
import SMSwiftBasicKit

class LBInnerScrollView: LBBaseView{
    
    var scrollViewDidScrollBlock: ((_ scrollView: UIScrollView) -> Void)?
    
    lazy var innerScrollView: UITableView = {
        let table = UITableView()
        table.showsVerticalScrollIndicator = false
        table.delegate = self
        table.dataSource = self
        table.contentSize = CGSize(width: BLT_SCREEN_WIDTH, height: 2000)
        table.blt.registerReusableCell(cell: UITableViewCell.self)
        table.rowHeight = 44
        return table
    }()
    
    override func initSubView() {
        addSubview(innerScrollView)
        innerScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension LBInnerScrollView: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.blt.dequeueReusableCell(UITableViewCell.self, indexPath: indexPath)
        cell.textLabel?.text = "第\(indexPath.row)行"
        cell.textLabel?.font = .blt.mediumFont(16)
        cell.textLabel?.textColor = .blt.threeThreeBlackColor()
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print("LBLog LBInnerScrollView did scroll")
        scrollViewDidScrollBlock?(scrollView)
    }
}
