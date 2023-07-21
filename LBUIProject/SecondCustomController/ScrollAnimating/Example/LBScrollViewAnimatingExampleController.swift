//
//  LBScrollViewAnimatingExampleController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/19.
//

import UIKit

class LBScrollViewAnimatingExampleController: UIViewController {

    lazy var collectionView: UICollectionView = {
        let width = view.bounds.width
        let size = CGSize(width: width, height: 55)
        let collectionV = UICollectionView.blt.initFlowCollectionView(miniLineSpacing: 0, miniInterItemSpacing: 0, itemSize: size, scrollDirection: .vertical, delegate: self, dataSource: self)
        collectionV.register(LBSecondColumnListCell.self, forCellWithReuseIdentifier: LBSecondColumnListCell.blt_className)
        return collectionV
    }()
    
    lazy var dataSources = [
        LBListItemModel.init(title: "向上隐藏 向下展示效果的", vcClass: LBListScrollAnimatingController.self),
        LBListItemModel.init(title: "headerImageView变大变小消失的", vcClass: LBHeaderImageScaleDismissViewController.self),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "列表滚动效果的"
        view.backgroundColor = .white
        self.view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}

extension LBScrollViewAnimatingExampleController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LBSecondColumnListCell.blt_className, for: indexPath) as? LBSecondColumnListCell else { return UICollectionViewCell() }
        cell.title = dataSources[indexPath.row].title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.dataSources[indexPath.row]
        if let vc = model.vcClass as? UIViewController.Type{
            self.navigationController?.pushViewController(vc.init(), animated: true)
        }
    }
}
