//
//  BLTChooseListView.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2021/8/25.
//  Copyright © 2021 com.wanjian. All rights reserved.
//

import Foundation
import BLTUIKitProject

public class BLTChooseListView: UIView {
    private static let instanceListView = BLTChooseListView()
    public override class func appearance() -> Self {
        return instanceListView as! Self
    }
    
    @objc public var customSensorDataBlock:((_ tableView: UITableView) -> Void)?
    
    var itemH: CGFloat = 50;
    public var selectIndex: Int = 0{
        didSet{
            self.tableView.reloadData()
        }
    }
    
    public var selectImage: UIImage?
    public var normalImage: UIImage?
//
    public var titles = [String](){
        didSet{
            if titles.count == 0 {
                assert(titles.count != 0, "titles connot be nil")
            }
            self.tableView.reloadData()
            self.blt_height = itemH * CGFloat(titles.count)
        }
    }
    
    let tableView: UITableView
    
    public override init(frame: CGRect) {
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false;
        tableView.register(BLTChooseListCell.self, forCellReuseIdentifier: "BLTChooseListCell")
        addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.top.bottom.equalToSuperview()
        }
//        tableView.addObserver(self, forKeyPath: "contentSize", options: [.new, .old], context: nil)
    }
    
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        guard let _ = newSuperview else { return }
        
        if self.customSensorDataBlock == nil{
            self.customSensorDataBlock = BLTChooseListView.appearance().customSensorDataBlock
        }
        self.customSensorDataBlock?(tableView)
    }
    
    
    // 重写响应方法
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "contentSize" {
//            if let new = change?[NSKeyValueChangeKey.newKey] {
//                if let size = new as? CGSize {
//                    self.blt_height = size.height;
//                }
//             }
//        }
//    }
    
//    deinit {
//        tableView.removeObserver(self, forKeyPath: "contentSize")
//    }
}


extension BLTChooseListView: UITableViewDelegate, UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chooseCell: BLTChooseListCell = tableView.dequeueReusableCell(withIdentifier: "BLTChooseListCell", for: indexPath) as! BLTChooseListCell
        chooseCell.title = self.titles[indexPath.row]
        chooseCell.refreshCheckImage(normalImage: normalImage ?? BLTChooseListView.appearance().normalImage, selectImage: selectImage ?? BLTChooseListView.appearance().selectImage)
        if self.selectIndex == indexPath.row {
            chooseCell.checked = true;
        }else{
            chooseCell.checked = false;
        }
        return chooseCell
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50;
    }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectIndex = indexPath.row
        self.tableView.reloadData()
    }
    
}



class BLTChooseListCell: UITableViewCell {
    var title = ""{
        didSet{
            self.titleLab.text = title
        }
    }
    var checkBtn = UIButton()
    
    var titleLab = UILabel.blt_label(with: UIFontPFFontSize(15), textColor: UIColor.blt.sixsixBlackColor())!
    var checked = false{
        didSet{
            self.checkBtn.isSelected = checked
        }
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        self.checkBtn.isUserInteractionEnabled = false
        self.titleLab.numberOfLines = 0;
        
        self.contentView.addSubview(checkBtn)
        self.contentView.addSubview(self.titleLab)
        self.checkBtn.snp.makeConstraints { (make) in
            make.left.equalTo(self)
            make.centerY.equalToSuperview()
        }
        
        self.titleLab.snp.makeConstraints { (make) in
            make.left.equalTo(self.checkBtn.snp_right).offset(10)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
        }
        
        checkBtn.setContentHuggingPriority(.required, for: .horizontal)
        checkBtn.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    func refreshCheckImage(normalImage: UIImage?, selectImage: UIImage?) {
        checkBtn.setImage(normalImage, for: .normal)
        checkBtn.setImage(selectImage, for: .selected)
    }
}

