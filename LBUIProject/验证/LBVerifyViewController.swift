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
                LBListItemModel.init(title: "present全屏", vcClass: LBPresentFullScreenController.self),
                LBListItemModel.init(title: "更换应用图标无弹框", vcClass: LBChangeIconWithoutAlertController.self),
                LBListItemModel.init(title: "codable模型转换", vcClass: LBCodableController.self),
                LBListItemModel.init(title: "formatter格式化", vcClass: LBFormatterController.self),
                LBListItemModel.init(title: "combine响应式", vcClass: LBCombineSampleListController.self),
                LBListItemModel.init(title: "弹框队列", vcClass: LBAlertQueueViewController.self),
                LBListItemModel.init(title: "测试self", vcClass: LBTestSelfController.self),
                LBListItemModel.init(title: "ScrollView嵌套Scrollview", vcClass: LBScrollViewInScrollViewController.self),
                LBListItemModel.init(title: "StickyHeaderNoEffectVC", vcClass: StickyHeaderNoEffectVC.self),
                LBListItemModel.init(title: "tableview悬停效果", vcClass: LBStickyCollapsibleHeaderVC.self),
                LBListItemModel.init(title: "Swift方法派发种类", vcClass: LBFuctionTypeController.self),
                LBListItemModel.init(title: "自动连接wifi", vcClass: LBConnectWifiAutoController.self),
                LBListItemModel.init(title: "手势优先级", vcClass: LBGesturePriorityViewController.self),
                LBListItemModel.init(title: "AI问答器", vcClass: LBAIAnswerViewController.self),
                LBListItemModel.init(title: "流式输出问答器", vcClass: LBSSEReponseController.self),
                LBListItemModel.init(title: "UIKit加载SF Symbols设置颜色、大小", vcClass: LBUIKitLoadSFSymbolsController.self),
//                LBListItemModel.init(title: "chat模拟", vcClass: LBChatViewController.self),
                LBListItemModel.init(title: "at功能完整实现（可用版）", vcClass: LBATCompleteViewController.self),
//                LBListItemModel.init(title: "SPM流式Markdown渲染聊天", vcClass: LBSPMStreamChatController.self),
                LBListItemModel.init(title: "webview渲染流式内容", vcClass: ChatViewController.self),
                LBListItemModel.init(title: "豆包式卡片流式对话(Diffable)", vcClass: DoubaoChatViewController.self),
            ]
        }
    }
    
    override var shouldAutorotate: Bool{
        return false
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 打印的结果一样， Self.self super.self打印的当前类型都是 LBVerifyViewController， 运行时的类型
        print("LBLog class is \(type(of: self))")
        let child = Child()
        child.printType()
        
        var expaned = false
        
        var expaned2 = false
        expaned.toggle()
        expaned2.toggle()
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
        let vc = vcClass.init()
        vc.view.backgroundColor = .white
        vc.navigationItem.title = item.title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
//在考古学研究中判断人类遗骸的性别具有重要意义，对于了解古代社会结构具有重要意义。科学家发现牙釉质中含有釉原蛋白，编码这种蛋白的基因恰好位于性染色体——X染色体和Y染色体上，研究者认为，用牙齿判定遗骸性别的方法可用于考古研究。
//    以下哪项如果为真，最能支持上述论证？
//
//    牙齿是古人类遗骸中最容易找到并且保存最完好的部分
//
//    儿童遗骸的骨骼没有明显的性别差异
//
//    人类遗骸的性别比例与当时人类社会的性别比例大致相同
//
//    测量某些骨骼特征如骨盆的结构通常可以直接判定性别
    
}


class Parent {
    func printType() {
        print("self.Type: \(type(of: self))")  // 动态类型（运行时的真实类型）
    }
}

class Child: Parent {
    override func printType() {
        print("Child self.Type: \(type(of: self))")
        super.printType()
    }
}
