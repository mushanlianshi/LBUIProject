//
//  LBResponderTransferViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/27.
//

import UIKit
import BLTSwiftUIKit

extension BLTResponderEvent{
    static let clickEvent = BLTResponderEvent(rawValue: 1)
}

///根据响应链找到遵守BLTResponderTransferProtocol 协议的来响应  可以做到跨层级
class LBResponderTransferViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "跨层级传递"
        view.backgroundColor = .white
        self.addLBTableView(.none)
        self.lb_tableView?.blt.registerReusableCell(cell: LBResponderTransferListCell.self)
        self.lb_tableView?.rowHeight = 60
        self.lb_tableView?.delegate = self
        self.lb_tableView?.dataSource = self
        self.lb_tableView?.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
    

}


extension LBResponderTransferViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: LBResponderTransferListCell = tableView.blt.dequeueReusableCell(indexPath: indexPath)
//        let cell = tableView.blt.dequeueReusableCell(LBResponderTransferListCell.self, indexPath: indexPath)
        cell.indexPath = indexPath
        return cell
    }
    
    
    
}


extension LBResponderTransferViewController: BLTResponderTransferProtocol{
    func receiveEvent(_ eventType: BLTSwiftUIKit.BLTResponderEvent, obj: Any?) {
        print("LBLog event type \(eventType)  \(String(describing: obj))")
    }
    
    
}




class LBResponderTransferListCell: UITableViewCell {
    
    lazy var titleLab = UILabel.blt.initWithFont(font: .blt.normalFont(16), textColor: .blt.threeThreeBlackColor())
    lazy var clickBtn = UIButton.blt.initWithTitle(title: "click", font: .blt.mediumFont(15), color: .white, target: self, action: #selector(clickButtonClicked))
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        clickBtn.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        clickBtn.backgroundColor = .blt.ffRedColor()
        contentView.addSubview(titleLab)
        contentView.addSubview(clickBtn)
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.bottom.equalToSuperview()
        }
        
        clickBtn.snp.makeConstraints { make in
            make.right.equalTo(-15)
            make.centerY.equalToSuperview()
        }
    }
    
    var indexPath: IndexPath?{
        didSet{
            guard let iPath = indexPath else { return }
            titleLab.text = "IndexPath Row is \(iPath.row)"
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    @objc private func clickButtonClicked(){
        self.blt.transferEvent(.clickEvent, obj: indexPath)
    }
}
