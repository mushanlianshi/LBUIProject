//
//  BLTCommonListView.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2021/8/25.
//  Copyright © 2021 com.wanjian. All rights reserved.
//

import UIKit
import SnapKit


open class BLTCommonListCell<ItemType>: UITableViewCell {
    public lazy var lineView = UIView.blt_view(withBackgroundColor: UIColor.blt.eeColor())!
    
    public lazy var containerView = UIView.blt_view(withBackgroundColor: .white)!
    
    open var itemModel: ItemType?
    required public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        initSubviews()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func initSubviews(){
        
    }

}

public protocol BLTCommonListViewDelegate: AnyObject {
    func didSelectItem<ItemType>(item: ItemType, index: Int)
}


public class BLTCommonListViewConfig: NSObject{
    private static let shared = BLTCommonListViewConfig()
    @objc public var customSensorDataBlock: ((_ tableView: UITableView) -> Void)?
    public static func appearance() -> Self {
        return shared as! Self
    }
}

public class BLTCommonListView<ItemType, CellType: BLTCommonListCell<ItemType>>: UIView, UITableViewDelegate, UITableViewDataSource {
    
//    全局处理神策采集的，需要单独设置拿tableview去设置
    lazy var config: BLTCommonListViewConfig = BLTCommonListViewConfig.appearance()
    
    @objc public var customSensorDataBlock: ((_ tableView: UITableView) -> Void)?
    
    private var refreshBlock: (() -> Void)?
    private var loadMoreBlock: (() -> Void)?
    
    public var itemList: [ItemType] = []{
        didSet{
            self.tableView.reloadData()
        }
    }

    public var tableView: UITableView
    public weak var delegate: BLTCommonListViewDelegate?
    public var didSelectItemBlock: ((_ item: ItemType, _ index: Int) -> Void)?

    override init(frame: CGRect) {
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(frame: frame)
        setupViews()
        self.config.customSensorDataBlock?(tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews(){
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        addSubview(self.tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemList.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CellType? = tableView.dequeueReusableCell(withIdentifier: "cell") as? CellType
        if cell == nil {
            cell = CellType(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.itemModel = self.itemList[indexPath.row]
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model: ItemType = self.itemList[indexPath.row]
        self.delegate?.didSelectItem(item: model, index: indexPath.row)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let _ = newSuperview{
            self.customSensorDataBlock?(tableView)
        }
    }
}


