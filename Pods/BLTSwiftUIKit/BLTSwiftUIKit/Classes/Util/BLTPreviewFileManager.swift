//
//  BLTPreviewFileManager.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2022/7/21.
//  Copyright © 2022 com.wanjian. All rights reserved.
//

import Foundation
import UIKit

//public typealias BLTEmptyBlock = (() -> Void)

//使用系统UIDocumentInteractionController控件来预览pdf等文件
public class BLTPreviewFileManager: NSObject{
    
    private weak var currentVC: UINavigationController?
    
    private var documentInteractionController: UIDocumentInteractionController?
    
    private var willPreviewHandler: (() -> Void)?
    
    private var endPreviewHandler: (() -> Void)?
    
//    预览文件 currentVC导航  willStartPreviewHandler如果为空  默认处理导航的方式
    @objc public func previewFile(url: URL, currentVC: UINavigationController?, willStartPreviewHandler: (() -> Void)? = nil, didEndPreviewHandler: (() -> Void)? = nil) {
        if bltCheckIsSimulator(){
            assert(false, "LBLog not support simulator")
        }
        guard let vc = currentVC else { return }
        self.currentVC = vc
        self.willPreviewHandler = willStartPreviewHandler
        self.endPreviewHandler = didEndPreviewHandler
        documentInteractionController = UIDocumentInteractionController.init(url: url)
        documentInteractionController?.delegate = self
        documentInteractionController?.presentPreview(animated: true)
    }

}



extension BLTPreviewFileManager: UIDocumentInteractionControllerDelegate{
    public func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return (self.currentVC ?? UIApplication.shared.windows.first?.rootViewController) ?? UIViewController()
    }
    
    public func documentInteractionControllerWillBeginPreview(_ controller: UIDocumentInteractionController) {
        if willPreviewHandler == nil{
            renderNavigationBarWhite()
        }else{
            willPreviewHandler?()
        }
    }
    
    public func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        endPreviewHandler?()
    }
    
    private func renderNavigationBarWhite(){
//        拿navigationController的navigationBar 设置 改变当前bar的属性 优先于全局appearance的
        guard let vc = self.currentVC else{ return }
        vc.navigationBar.barTintColor = .white
        vc.navigationBar.tintColor = .black
    }
    
}
