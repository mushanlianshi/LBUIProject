//
//  LBAlertQueueManager.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/28.
//

import Foundation
import BLTUIKitProject
import UIKit


public func swizzleMethods(cls: AnyClass?, originalSelector: Selector, swizzledSelector: Selector) {
    let originalMethod = class_getInstanceMethod(cls, originalSelector)
    let swizzledMethod = class_getInstanceMethod(cls, swizzledSelector)
    
    method_exchangeImplementations(originalMethod!, swizzledMethod!)
}

fileprivate typealias LBEmptyBlock = (() -> Void)


public class LBAlertQueueManager{
    
    ///弹框的队列
    private lazy var alertQueue = [LBAlertEntity]()
    
    
    ///再那个页面弹框的   用来处理回来之后继续弹框的
    var alertHomeVC: UIViewController!{
        didSet{
            alertHomeVC.lbVCDidAppearBlock = {
                [weak self] in
                self?.checkDisplayAlertIfNeeded()
            }
        }
    }
    
    private var currentAlert: LBAlertEntity?
    
    ///当前是不是弹框点击后push新的界面  如果是 暂停弹下个框 等下次回到alertHomeVC在弹框
    var willPushNewVC = false
    
    public func show(alert: UIView, config: LBAlertConfig = LBAlertConfig())  {
        let alertView = LBAlertEntity.init(content: .init(view: alert, config: config))
        self.alertQueue.append(alertView)
        alert.lbViewDidDismissBlock = {
            [weak self] in
        }
    }
    
    
    public func show(alert: UIViewController, config: LBAlertConfig = LBAlertConfig()) {
        let alertVC = LBAlertEntity.init(content: .init(viewController: alert, config: config))
        self.alertQueue.append(alertVC)
    }
    
    init(){
        BLTOnceManager.execute({
            swizzleInstanceMethod(UIView.self, #selector(UIView.didMoveToWindow), #selector(UIView.lb_didMoveToWindow))
            swizzleInstanceMethod(UIViewController.self, #selector(UIView.didMoveToWindow), #selector(UIView.lb_didMoveToWindow))
            swizzleInstanceMethod(UIViewController.self, #selector(UIView.didMoveToWindow), #selector(UIView.lb_didMoveToWindow))
        }, onceIdentifier: "LBAlertQueueManager exchange")
    }
    
    
    
    ///检查是否需要继续弹框的
    private func checkDisplayAlertIfNeeded(){
        if self.willPushNewVC {
            self.willPushNewVC = false
            return
        }
        self.startShow()
    }
    
    public func startShow() {
        
    }
}



fileprivate var lbViewDidDismissBlockKey: Void?
fileprivate extension UIView{
    var lbViewDidDismissBlock: LBEmptyBlock?{
        get{
            return objc_getAssociatedObject(self, &lbViewDidDismissBlockKey) as? LBEmptyBlock
        }
        set{
            objc_setAssociatedObject(self, &lbViewDidDismissBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    @objc dynamic func lb_didMoveToWindow() {
        // 替换后的方法实现
        self.lb_didMoveToWindow()
        self.lbViewDidDismissBlock?()
    }
    
    
}

fileprivate var lbVCDidAppearBlockKey: Void?
fileprivate var lbVCDidDisAppearBlockKey: Void?

fileprivate extension UIViewController{
    var lbVCDidAppearBlock: LBEmptyBlock?{
        get{
            return objc_getAssociatedObject(self, &lbVCDidAppearBlockKey) as? LBEmptyBlock
        }
        set{
            objc_setAssociatedObject(self, &lbVCDidAppearBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    var lbVCDidDisAppearBlock: LBEmptyBlock?{
        get{
            return objc_getAssociatedObject(self, &lbVCDidDisAppearBlockKey) as? LBEmptyBlock
        }
        set{
            objc_setAssociatedObject(self, &lbVCDidDisAppearBlockKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
    }
    
    @objc dynamic func lb_viewDidAppear(){
        self.lb_viewDidAppear()
        self.lbVCDidAppearBlock?()
    }
    
    @objc dynamic func lb_viewDidDisappear(){
        self.lb_viewDidDisappear()
        self.lbVCDidDisAppearBlock?()
    }
    
}
