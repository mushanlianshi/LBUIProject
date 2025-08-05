//
//  LBTestScrollVerticalHorizontalController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/2/17.
//

import Foundation
import BLTUIKitProject
import UIKit
import MJRefresh


class LBTestScrollVerticalHorizontalController2: UIViewController {
    
    lazy var titleLab = UILabel.blt_label(withTitle: "问候我饿粉红我二号位佛偶吼吼", font: UIFontPFFontSize(16), textColor: .black)!
    
    lazy var tableView: SYVerticalHorizontalTableView = {
        let view = SYVerticalHorizontalTableView.init(leftContentWidth: self.view.bounds.size.width * 0.3, rightContentWidth: self.view.bounds.size.width * 1.2)!;
        view.syDelegate = self;
        view.syDataSource = self;
        view.mj_header = MJRefreshNormalHeader.init(refreshingBlock: {
            print("LBLog begin refreshing ========")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                view.mj_header?.endRefreshing()
            }
        })
        view.mj_footer = MJRefreshAutoNormalFooter.init(refreshingBlock: {
            print("LBLog begin loadmore ========")
        })
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(titleLab)
        view.addSubview(tableView)
        titleLab.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100)
        tableView.frame = CGRect(x: 0, y: 100, width: self.view.bounds.width, height: self.view.bounds.height - 100)
//        titleLab.snp.ma
//        tableView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        let mirror = Mirror.init(reflecting: tableView)
        for item in mirror.children {
            print("LBLog mirro is \(item.label)  \(item.value)")
        }
    }
    
    func processScrollOffset(_ offset: CGPoint){
        if offset.y > 50 {
            return
        }
        titleLab.frame = CGRect(x: 0, y: -offset.y, width: self.view.bounds.width, height: 100)
        tableView.frame = CGRect(x: 0, y: 100 - offset.y, width: self.view.bounds.width, height: self.view.bounds.height - 100 + offset.y)
    }
    
}


extension LBTestScrollVerticalHorizontalController2: SYVerticalHorizontalTableDelegate,SYVerticalHorizontalTableDataSource{
    func tableView(_ tableView: SYVerticalHorizontalTableView!, numberOfRowsInSection section: Int) -> Int {
        return 50;
    }
    
    func tableView(_ tableView: SYVerticalHorizontalTableView!, cellForRowAt indexPath: IndexPath!, position: SYVerticalHorizontalCellPosition) -> UITableViewCell! {
        var cell: LBTestScrollVerticalHorizontalCell2? = tableView.dequeueReusableCell(withIdentifier: LBTestScrollVerticalHorizontalCell2.blt_className) as? LBTestScrollVerticalHorizontalCell2 ?? nil
        if (cell == nil){
            cell = LBTestScrollVerticalHorizontalCell2.init(style: .default, reuseIdentifier: LBTestScrollVerticalHorizontalCell2.blt_className)
        }
        if position == .left {
            cell?.titleLab.text = "left cell \(indexPath.row)"
        }else{
            cell?.titleLab.text = "right cell right cell right cell right cell right cell \(indexPath.row)"
        }
        return cell!
    }
    
    func tableView(_ tableView: SYVerticalHorizontalTableView!, heightForRowAt indexPath: IndexPath!) -> CGFloat {
        return 50;
    }
    
    
}


class LBTestScrollVerticalHorizontalCell2: UITableViewCell {
    lazy var titleLab = UILabel.blt_label(withTitle: "", font: UIFontPFFontSize(16), textColor: .black)!
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints({ make in
            make.left.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
        })
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
