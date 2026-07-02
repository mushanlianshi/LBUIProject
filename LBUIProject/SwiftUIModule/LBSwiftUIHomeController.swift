//
//  LBSwiftUIHomeController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/7/19.
//

import UIKit
import SwiftUI

class LBSwiftUIHomeController: LBBaseCollectionViewController {
    
    private lazy var swiftUIDataList: [(type: LBSwiftUIExampleType, view: Any)] = [
        (.chart, AnyView(LBChartTabView())),
        (.ScrollKit, AnyView(LBScrollKitHomeView())),
        (.swiftUIAnimation, AnyView(LBSwiftUIAnimationView())),
        (.mixSwiftUIView, LBMixSwiftUIViewController.self),
        (.mixSwiftUIView, LBCombineViewController.self),
        (.selectList, AnyView(LBSelectListPage())),
        (.addUIKitView, AnyView(LBAddUIKitViewPage())),
        (.mixSwiftUIView, LBSwiftUIRefreshListController.self),
        (.swiftUIEnvironmentData, AnyView(LBSwiftUIEnvironmentDataInjectPage())),
        (.swiftUIEnvironmentData, AnyView(LBSwiftUIEnvironmentDataInjectPage())),
//        (.navigationMix, AnyView(LBNavigationMixHomeView())),
    ]

    
    override func viewDidLoad() {
        collectionView.blt.registerReusableCell(cell: LBBaseColumnListCell.self)
        super.viewDidLoad()
        view.backgroundColor = .white
    }

}


extension LBSwiftUIHomeController{
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return swiftUIDataList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.blt.dequeueReusableCell(LBBaseColumnListCell.self, indexPath: indexPath)
        cell.title = swiftUIDataList[indexPath.row].type.rawValue
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ///获取swiftUI展示的controller
//        let hostVC: UIHostingController<<#Content: View#>>!
        let type = self.swiftUIDataList[indexPath.row].type
        
//        if type == .navigationMix{
//            if #available(iOS 16.0, *) {
//                let root = LBNavigationMixRootContainerView()
//                let vc = UIHostingController(rootView: root)
//                // 关键：统一 UIKit 导航样式
//                vc.navigationItem.title = "";
////                vc.navigationItem.largeTitleDisplayMode = .never;
//                self.navigationController?.pushViewController(vc, animated: true)
//            } else {
//                
//            };
//        }
//        else
        if type == .mixSwiftUIView {
            let vcType = self.swiftUIDataList[indexPath.row].view as! UIViewController.Type
            self.navigationController?.pushViewController(vcType.init(), animated: true)
        }else{
            let view = self.swiftUIDataList[indexPath.row].view as! AnyView
            self.navigationController?.pushViewController(LBCustomHostingController(rootView: view), animated: true)
        }
        
        
//        self.navigationController?.pushViewController(UIHostingController(rootView: swiftView), animated: true)
    }
    
}



enum LBSwiftUIExampleType: String {
    case chart = "图表Chart iOS16"
    case ScrollKit = "ScrollKit 列表"
    case swiftUIAnimation = "swiftUI动画"
    case mixSwiftUIView = "内嵌SwiftUI view"
    case selectList = "列表点击选中"
    case addUIKitView = "加载UIKit中的控件"
    case swiftUIEnvironmentData = "swiftUI中环境变量注册、存取"
//    case navigationMix = "混合导航栏"
}
