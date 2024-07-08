//
//  LBSwiftUIHomeController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/19.
//

import UIKit
import SwiftUI

class LBSwiftUIHomeController: LBBaseCollectionViewController {
    
    private lazy var swiftUIDataList: [LBSwiftUIExampleType] = [
        .chart,
        .ScrollKit
    ]
    
    private lazy var swiftUIDataList22: [(type: LBSwiftUIExampleType, view: AnyView)] = [
        (.chart, AnyView(LBChartTabView())),
        (.ScrollKit, AnyView(LBScrollKitHomeView())),
        (.swiftUIAnimation, AnyView(LBSwiftUIAnimationView()))
    ]
    
    override func viewDidLoad() {
        collectionView.blt.registerReusableCell(cell: LBBaseColumnListCell.self)
        super.viewDidLoad()
        view.backgroundColor = .white
    }

}


extension LBSwiftUIHomeController{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return swiftUIDataList22.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.blt.dequeueReusableCell(LBBaseColumnListCell.self, indexPath: indexPath)
        cell.title = swiftUIDataList22[indexPath.row].type.rawValue
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ///获取swiftUI展示的controller
//        let hostVC: UIHostingController<<#Content: View#>>!
//        var swiftView: any View
        let view = self.swiftUIDataList22[indexPath.row].view
        self.navigationController?.pushViewController(UIHostingController(rootView: view), animated: true)
        return
        
        let type = self.swiftUIDataList[indexPath.row]
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
    case swiftUIAnimation = "swiftUI动画"
}
