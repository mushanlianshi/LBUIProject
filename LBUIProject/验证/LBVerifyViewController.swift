//
//  LBVerifyViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/24.
//

import UIKit

class LBVerifyViewController: UIViewController {

    lazy var collectionView: UICollectionView = {
        let width = view.bounds.width / 3
        let size = CGSize(width: width, height: width * 0.65)
        let collectionV = UICollectionView.blt.initFlowCollectionView(miniLineSpacing: 0, miniInterItemSpacing: 0, itemSize: size, scrollDirection: .vertical, delegate: self, dataSource: self)
        collectionV.register(LBSecondColumnListCell.self, forCellWithReuseIdentifier: LBSecondColumnListCell.blt_className)
        return collectionV
    }()
    
    lazy var dataSources = [
        LBListItemModel.init(title: "验证BaseListVC", vcClass: LBVerifyListController.self)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }

}


extension LBVerifyViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.blt.dequeueReusableCell(LBSecondColumnListCell.self, indexPath: indexPath)
        cell.title = dataSources[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSources[indexPath.row]
        guard let vcClass = item.vcClass as? UIViewController.Type else {
            return
        }
        self.navigationController?.pushViewController(vcClass.init(), animated: true)
    }
    
}
