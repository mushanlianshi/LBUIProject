//
//  UIViewControllerBLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2021/12/8.
//

import UIKit
import BLTUIKitProject

extension UIViewController: BLTNameSpaceCompatible{}

extension BLTNameSpace where Base: UIViewController{
    
//    单纯确定样式的弹出框
    public func presentSureTipAlert(title: String = "温馨提示", content: String?, sureActionTitle: String = "确定", style: BLTAlertControllerStyle = .alert, sureBlock:((_ action: BLTAlertAction?) -> Void)?) {
        self.presentAlert(title: title, content: content, style: style, sureTitle: sureActionTitle, sureBlock: sureBlock)
    }
//    自定义样式的弹出框
    public func presentAlert(title: String?, content: String?, style: BLTAlertControllerStyle = .alert, cancelTitle: String? = nil, cancelBlock: ((_ action: BLTAlertAction?) -> Void)? = nil, sureTitle: String?, sureBlock: ((_ action: BLTAlertAction?) -> Void)? , tapBackDismiss: Bool = false) {
        let alertVC = BLTAlertController.init(title: title, mesage: content, style: style, cancelTitle: cancelTitle, cancel: cancelBlock, sureTitle: sureTitle, sureBlock: sureBlock)!
        alertVC.backgroundClickDismiss = tapBackDismiss
        base.present(alertVC, animated: true, completion: nil)
    }

    ///设置内容是富文本的
    public func presentAttributeTextAlert(title: String?, titleAttribute: NSAttributedString? = nil, attributeContent: NSAttributedString?, style: BLTAlertControllerStyle = .alert, cancelTitle: String? = nil, cancelBlock: ((_ action: BLTAlertAction?) -> Void)? = nil, sureTitle: String?, sureBlock: ((_ action: BLTAlertAction?) -> Void)? , tapBackDismiss: Bool = false) {
        let alertVC = BLTAlertController.init(title: title, mesage: attributeContent?.string ?? "", style: style, cancelTitle: cancelTitle, cancel: cancelBlock, sureTitle: sureTitle, sureBlock: sureBlock)!
        alertVC.backgroundClickDismiss = tapBackDismiss
        if let text = attributeContent{
            alertVC.alertContentAttributeString = text
        }
        if let text = titleAttribute{
            alertVC.alertTitleAttributeString = text
        }
        base.present(alertVC, animated: true, completion: nil)
    }
    

    
}


