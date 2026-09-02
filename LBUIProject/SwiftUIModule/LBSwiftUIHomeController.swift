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
        (.mixSwiftUIView, LBTestBookingGiftPackController.self),
        (.mixSwiftUIView, LBTestBookingGiftPackController2.self),
        (.selectList, AnyView(LBTestSwiftListView(clickBlock: {}))),
        (.aiCameraHome, AnyView(AICamereHomeView())),
        (.aiCameraSetting, AnyView(AICamereSettingView())),
        (.shareBarCode, AnyView(LBShareBarCodeView())),
        (.shareManagement, AnyView(LBShareManagementView())),
        (.shareManagement, LBShareManagementViewController.self),
        (.bluetoothList, LBBluetoothListHostingController.self),
        (.bluetoothList, LBBluetoothListViewController.self),
        (.combineSearch, AnyView(LBCombineSearchView())),
//        (.navigationMix, AnyView(LBNavigationMixHomeView())),
    ]

    
    override func viewDidLoad() {
        collectionView.blt.registerReusableCell(cell: LBBaseColumnListCell.self)
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let deferResult = testDefer()
        debugPrint("LBLog testDeferValue is \(deferResult)")
        testCapture()
    }
    
    
    private func testDefer() -> Int{
        var value = 10
        defer {
            value = 20
            print("LBLog defer:", value)
        }
        return value
    }
    
    private func testCapture() {
        var a = 0
        var b = 0
        let closure = { [a] in
            print("LBLog closure capture \(a), \(b)")
        }

        a = 10
        b = 10
        closure()
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
        }else if let vcType = self.swiftUIDataList[indexPath.row].view as? UIViewController.Type {
            // 兼容任意 type 挂 UIKit 控制器
            self.navigationController?.pushViewController(vcType.init(), animated: true)
        }else{
            let view = self.swiftUIDataList[indexPath.row].view as! AnyView
            self.navigationController?.pushViewController(LBCustomHostingController(rootView: view), animated: true)
        }
//        某社区是一个老旧小区，共有居民3200户，常住人口约8000人。其中60岁以上老年人占总人口的18%
//        ，有空巢老人27名。社区内配套设施老旧，缺乏无障碍设施，部分楼栋没有电梯。近年来，社区居民
//        就老旧小区改造、增设无障碍、加装电梯等问题反映强烈。经过社区居委会召开居民会议征求意见，
//        超过80%的居民同意进行旧区改造。但在实施过程中，部分低层住户因采光、噪音等问题反对加装电
//        梯，部分居民对改造方案中的停车位调整意见不一。同时，改造资金需要多方筹集，仅靠政府补贴不
//        足以完成全部改造任务。
//        问题：
//        1. 请分析该社区旧区改造面临的主要矛盾和问题。（10分） 风景  颠簸  城隍庙
//        2. 作为社区工作者，你将如何协调各方利益主体，推进改造工作顺利进行？（10分）

        
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
    case aiCameraHome = "摄像头列表"
    case aiCameraSetting = "摄像头-设置"
    case shareBarCode = "二维码配网"
    case shareManagement = "分享管理"
    case bluetoothList = "蓝牙列表"
    case combineSearch = "天气搜索"
//    case navigationMix = "混合导航栏"
}
