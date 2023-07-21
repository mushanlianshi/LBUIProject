//
//  LBSwiftUIHomeController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/19.
//

import UIKit
import SwiftUI

class LBSwiftUIHomeController: UIViewController {
    
    private lazy var collectionView: UICollectionView = {
        let width = view.bounds.width / 3
        let size = CGSize(width: width, height: width * 0.65)
        let collectionV = UICollectionView.blt.initFlowCollectionView(miniLineSpacing: 0, miniInterItemSpacing: 0, itemSize: size, scrollDirection: .vertical, delegate: self, dataSource: self)
        collectionV.register(LBSecondColumnListCell.self, forCellWithReuseIdentifier: LBSecondColumnListCell.blt_className)
        return collectionV
    }()
    
    private lazy var dataSources: [LBSwiftUIExampleType] = [
        .chart,
        .ScrollKit
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

}


extension LBSwiftUIHomeController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.blt.dequeueReusableCell(LBSecondColumnListCell.self, indexPath: indexPath)
        cell.title = dataSources[indexPath.row].rawValue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSources[indexPath.row]
        ///获取swiftUI展示的controller
//        let hostVC: UIHostingController<<#Content: View#>>!
//        var swiftView: any View
        let type = self.dataSources[indexPath.row]
        switch type {
        case .chart:
            self.navigationController?.pushViewController(UIHostingController(rootView: LBChartTabView()), animated: true)
        case .ScrollKit:
            self.navigationController?.pushViewController(UIHostingController(rootView: LBScrollKitHomeView()), animated: true)
        default:
            print("not matched ======")
        }
//        self.navigationController?.pushViewController(UIHostingController(rootView: swiftView), animated: true)
    }
    
}



enum LBSwiftUIExampleType: String {
    case chart = "图表Chart iOS16"
    case ScrollKit = "ScrollKit 列表"
}
