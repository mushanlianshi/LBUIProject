//
//  LBVerifyViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/24.
//

import UIKit
import SwiftUI

class LBVerifyViewController: LBBaseCollectionViewController {

    
    override var dataSources: [LBListItemModel]{
        set{}
        get{
            [
                LBListItemModel.init(title: "验证BaseListVC", vcClass: LBVerifyListController.self),
                LBListItemModel.init(title: "Widget数据更新", vcClass: LBWidgetUpdateController.self),
                LBListItemModel.init(title: "跨层级响应传递", vcClass: LBResponderTransferController.self),
                LBListItemModel.init(title: "Await Async 异步函数", vcClass: LBAwaitAsyncViewController.self),
                LBListItemModel.init(title: "UIKit借助SwiftUI实现实时预览", vcClass: LBLivePreviewViewController.self),
                LBListItemModel.init(title: "属性包装器", vcClass: LLPropertyWrapperViewController.self),
                LBListItemModel.init(title: "蓝牙", vcClass: nil),
                LBListItemModel.init(title: "drawRect", vcClass: LBDrawRectController.self),
                LBListItemModel.init(title: "alpha  And opacity", vcClass: LBAlphaAndOpacityViewController.self),
                LBListItemModel.init(title: "VC disappear方法", vcClass: LBVerifyVCDisappearController.self),
                LBListItemModel.init(title: "全屏", vcClass: LBFullScreenViewController.self),
                LBListItemModel.init(title: "present全屏", vcClass: LBPresentFullScreenController.self)
            ]
        }
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }

}


extension LBVerifyViewController{
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = dataSources[indexPath.row]
        
        if item.title == "蓝牙"{
            self.navigationController?.pushViewController(UIHostingController(rootView: LBBluetoothSwiftUIPage()), animated: true)
            return
        }else if item.title == "present全屏"{
            self.present(LBPresentFullScreenController(), animated: true)
            return
        }
        
        guard let vcClass = item.vcClass as? UIViewController.Type else {
            return
        }
        self.navigationController?.pushViewController(vcClass.init(), animated: true)
    }
    
}
