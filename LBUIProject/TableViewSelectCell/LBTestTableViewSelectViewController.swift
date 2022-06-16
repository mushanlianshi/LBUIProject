//
//  LBTestTableViewSelectViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/5/27.
//

import UIKit
import BLTUIKitProject
import BLTSwiftUIKit

class LBTestTableViewSelectListModel{
    var selected: Bool = false
    var title = ""
}

class LBTestTableViewSelectListCell: UITableViewCell{
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        textLabel?.textColor = UIColor.black
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     var itemModel: LBTestTableViewSelectListModel?{
         didSet{
             textLabel?.text = itemModel?.title
         }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        contentView.backgroundColor = selected ? UIColor.systemPink.withAlphaComponent(0.5) : UIColor.white
        itemModel?.selected = selected
        print("LBLot model select \(itemModel?.title)  \(itemModel?.selected)")
    }
    
}

class LBTestTableViewSelectViewController: UIViewController {

    lazy var dataSources: [LBTestTableViewSelectListModel] = {
        var array = [LBTestTableViewSelectListModel]()
        for index in 0...100 {
            let model = LBTestTableViewSelectListModel()
            model.title = "row \(index)"
            array.append(model)
        }
        return array
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero)
        table.register(LBTestTableViewSelectListCell.self, forCellReuseIdentifier: "LBTestTableViewSelectListCell")
        table.rowHeight = 44
        table.delegate = self
        table.dataSource = self
//        可以多选
        table.allowsMultipleSelection = true
        return table
    }()
    
    var isAll: Bool = false{
        didSet{
            allIndexPaths().forEach { indexPath in
                if isAll{
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
//                    self.tableView(tableView, didSelectRowAt: indexPath)
                }else{
                    tableView.deselectRow(at: indexPath, animated: false)
                }
                dataSources.forEach { modal in
                    modal.selected = true
                }
                printSelectState()
            }
        }
    }
    
    lazy var sureButton: UIButton = {
        let button = UIButton.blt.initWithTitle(title: "确定", font: UIFontPFFontSize(16), color: UIColor.white, target: self, action: #selector(sureSelectModel))
        button.backgroundColor = UIColor.blt.ffRedColor()
        return button
    }()
    
    lazy var allButton: UIButton = {
        let button = UIButton()
        button.setTitle("全选", for: .normal)
        button.setTitle("取消", for: .selected)
        button.addTarget(self, action: #selector(allButtonClicked), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: allButton)
        view.addSubview(tableView)
        view.addSubview(sureButton)
        deleteNilTest()
    }
    
    
    private func deleteNilTest(){
        let array = ["123", nil, "234"]
        let t1 = array.compactMap( { $0 } )
        
        let array2 = ["123", nil, "234"]
        let t2 = array2.compactMap( { Int($0 ?? "ee") } )
        
        print("LBLog array  \(t1)")
        print("LBLog array2  \(t2)")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sureButton.frame = CGRect(x: 0, y: self.view.bounds.height - 50, width: self.view.bounds.width, height: 50)
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: sureButton.frame.minY)
    }
    
    @objc func allButtonClicked(){
        allButton.isSelected = !allButton.isSelected
        isAll = allButton.isSelected
    }
    
    func allIndexPaths() -> [IndexPath]{
        var array = [IndexPath]()
        for index in 0...(dataSources.count - 1){
            let indexPath = IndexPath.init(row: index, section: 0)
            array.append(indexPath)
        }
        return array
    }
    
    func printSelectState(){
        for(index, model) in dataSources.enumerated(){
            print("LBLog model selected state \(index) \(model.selected)")
        }
    }
    
    @objc func sureSelectModel() {
        dataSources.filter { modal in
            return modal.selected
        }.forEach { model in
            print("LBLog sure model is \(model.title)")
        }
    }
    
}

extension LBTestTableViewSelectViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "LBTestTableViewSelectListCell", for: indexPath) as? LBTestTableViewSelectListCell else { return UITableViewCell() }
        cell.itemModel = dataSources[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("LBLog cancel select row \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("LBLog select row \(indexPath.row)")
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let array = tableView.indexPathsForSelectedRows, array.contains(indexPath){
            tableView.deselectRow(at: indexPath, animated: true)
            return nil
        }
        return indexPath
    }
    
    
}
