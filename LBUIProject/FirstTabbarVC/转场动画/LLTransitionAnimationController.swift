//
//  LLTransitionAnimationController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/7/22.
//

import Foundation
import UIKit
import BLTUIKitProject
import Hero

//转场动画
class LLTransitionAnimationController: UIViewController{
    
    private lazy var dataSources = [LBSkeletonListModel]()
    
//    动画的label
    private var iconIV: UIImageView?
    private var titleLab: UILabel?
    
    lazy var tableView: UITableView = {
        let table = UITableView.init()
        table.dataSource = self
        table.delegate = self
        table.showsVerticalScrollIndicator = false
        table.register(LBSkeletonListCell.self, forCellReuseIdentifier: LBSkeletonListCell.blt_className)
        table.estimatedRowHeight = 120.0
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationItem.title = "转场动画"
        tableView.isSkeletonable = true
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for index in 0...60{
            let model = LBSkeletonListModel.init(title: "title + \(index)", content: "问候为合法欧文哈佛我饿哈佛我和佛为回复我腹黑我合肥我发好哦维护费我哈佛我饿粉红我耳环佛为合肥和违法我腹黑我二号房+ \(index)")
            self.dataSources.append(model)
        }
        self.tableView.reloadData()
    }
    
    deinit {
        print("LBLog LBSkeletonViewController dealloc ")
    }
}


extension LLTransitionAnimationController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LBSkeletonListCell.blt_className, for: indexPath) as? LBSkeletonListCell else { return UITableViewCell() }
        cell.listModel = dataSources[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? LBSkeletonListCell else { return }
        self.iconIV?.hero.id = nil
        self.titleLab?.hero.id = nil
        
        self.iconIV = cell.iconIV
        self.titleLab = cell.titleLab
        self.iconIV?.hero.id = .iconKey
        self.titleLab?.hero.id = .titleKey
        let vc = LLTransitionAnimationDetailController()
        vc.hero.isEnabled = true
        vc.modalPresentationStyle = .fullScreen
//        添加特效
//        vc.iconIV.hero.modifiers = [.spring(stiffness: 250, damping: 200), .scale(x: 0.5, y: 0.5, z: 0.5)]
//        vc.titleLab.hero.modifiers = [.fade]
        present(vc, animated: true, completion: nil)
    }
    
    
}



class LLTransitionAnimationDetailController: UIViewController{
    lazy var iconIV: UIImageView = {
        let iconIV = UIImageView()
        iconIV.blt_layerCornerRaduis = 5
        iconIV.image = UIImageNamed("face")
        iconIV.contentMode = .scaleAspectFill
        return iconIV
    }()
    
    lazy var titleLab = UILabel.blt_label(withTitle: "test title", font: UIFontPFFontSize(16), textColor: UIColor.black)!
    
    lazy var backButton: UIButton = {
        let button = UIButton.blt_button(withTitle: "返回", font: UIFontPFFontSize(16), titleColor: UIColor.black, target: self, selector: #selector(backButtonClicked))!
        button.backgroundColor = UIColor.blt.hexColor(0xeeeeee)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(iconIV)
        view.addSubview(titleLab)
        view.addSubview(backButton)
        iconIV.hero.id = .iconKey
        titleLab.hero.id = .titleKey
        setConstraints()
    }
    
    private func setConstraints(){
        backButton.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.top.equalTo(40)
        }
        
        iconIV.snp.makeConstraints { make in
            make.left.equalTo(40)
            make.top.equalTo(backButton.snp_bottom).offset(60)
            make.width.height.equalTo(50)
        }
        
        titleLab.snp.makeConstraints { make in
            make.left.equalTo(iconIV.snp_right).offset(15)
            make.top.equalTo(iconIV)
            make.right.equalTo(-15)
        }
    }
    
    @objc func backButtonClicked() {
        self.dismiss(animated: true, completion: nil)
    }
}



fileprivate extension String{
    static let iconKey = "iconKey"
    static let titleKey = "titleKey"
}
