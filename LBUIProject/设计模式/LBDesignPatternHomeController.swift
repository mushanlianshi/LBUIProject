//
//  LBDesignPatternHomeController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/6.
//

import UIKit
import BLTSwiftUIKit
import BLTUIKitProject

struct LBItemModel {
    var name: String
    var classType: UIViewController.Type
}
class LBDesignPatternHomeController: UIViewController {
    
    lazy var itemList: [LBItemModel] = {
        return [
            LBItemModel.init(name: "装饰者模式", classType: LBDecoratorModelViewController.self)
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.addLBCollectionView(.none)
        self.lb_collectionView?.blt.registerReusableCell(cell: LBDesignPatternHomeListCell.self)
        self.lb_collectionView?.delegate = self
        self.lb_collectionView?.dataSource = self
        self.lb_collectionLayout?.itemSize = CGSize(width: floor(view.bounds.width / 3), height: 80)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.lb_collectionView?.frame = view.bounds
    }
}



extension LBDesignPatternHomeController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.blt.dequeueReusableCell(LBDesignPatternHomeListCell.self, indexPath: indexPath)
        cell.titleLab.text = self.itemList[indexPath.row].name
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = self.itemList[indexPath.row]
        let vc = item.classType.init()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}



class LBDesignPatternHomeListCell: UICollectionViewCell {
    lazy var titleLab: BLTContentInsetLabel = {
        let label = BLTContentInsetLabel.blt.initWithFont(font: .blt.mediumFont(15), textColor: .blt.threeThreeBlackColor(), numberOfLines: 0)
        label.contentEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLab)
        titleLab.snp.makeConstraints { make in
            make.right.left.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
