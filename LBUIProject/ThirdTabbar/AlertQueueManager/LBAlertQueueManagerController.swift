//
//  LBAlertQueueManagerController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/26.
//

import UIKit
import SMSwiftBasicKit
import BLTUIKitProject
import SwiftEntryKit

class LBAlertQueueManagerController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "弹框队列SwiftEntryKit"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "开始弹框队列", style: .done, target: self, action: #selector(startAlertQueue))
    }
    
    
    @objc private func startAlertQueue(){
        
//        if let heuristic = EKAttributes.Precedence.QueueingHeuristic.value.heuristic is EntryCachingHeuristic{
//            heuristic.removeAll()
//        }
        
//        SwiftEntryKit.dismiss()
        
        
        var attributes = EKAttributes.customAlertAttribute()
        attributes.name = "11"
        attributes.precedence = .enqueue(priority: .normal)
        let alertVC = BLTAlertController.init(title: "自定义controller alert", mesage: "", style: .alert, cancelTitle: "取消", cancel: {
            action in
            SwiftEntryKit.dismiss()
        }, sureTitle: .blt.sureTitle) { action in
            SwiftEntryKit.dismiss()
        }!
        alertVC.autoActionClose = false
        SwiftEntryKit.display(entry: alertVC, using: attributes)
        
        ///先弹一个展示后面的才会按优先级弹出
        let redView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 300))
        redView.backgroundColor = .red
        redView.blt_addTap {
            SwiftEntryKit.dismiss()
        }
        
        var redAtt = EKAttributes.customAlertAttribute()
        redAtt.precedence = .enqueue(priority: .normal)
        SwiftEntryKit.display(entry: redView, using: redAtt)
        
        startMiddlePriorityAlert()
        startHighPriorityAlert()
        
        
        ///先弹一个展示后面的才会按优先级弹出
        let view = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 300))
        view.backgroundColor = .yellow
        view.blt_addTap {
            SwiftEntryKit.dismiss()
        }
        
        var att = EKAttributes.customAlertAttribute()
        att.precedence = .enqueue(priority: .low)
        SwiftEntryKit.display(entry: view, using: att)
    }
    
    private func startMiddlePriorityAlert(){
        var attributes = EKAttributes.customAlertAttribute()
        attributes.name = "11"
        attributes.precedence = .enqueue(priority: .normal)
        let alertVC = BLTAlertController.init(title: "自定义controller normal priority alert2222", mesage: " normal 22222222222222222222222 ", style: .alert, cancelTitle: "取消", cancel: {
            action in
            SwiftEntryKit.dismiss()
        }, sureTitle: .blt.sureTitle) { [weak self] action in
//            self?.pushPageViewController()
            SwiftEntryKit.dismiss()
        }!
        alertVC.autoActionClose = false
        SwiftEntryKit.display(entry: alertVC, using: attributes)
        
    }
    
    private func startHighPriorityAlert(){
        var attributes = EKAttributes.customAlertAttribute()
        attributes.name = "11"
        attributes.precedence = .enqueue(priority: .high)
        let alertVC = BLTAlertController.init(title: "自定义controller high priority alert2222", mesage: " 22222222222222222222222 ", style: .alert, cancelTitle: "取消", cancel: {
            action in
            SwiftEntryKit.dismiss()
        }, sureTitle: .blt.sureTitle) { [weak self] action in
//            self?.pushPageViewController()
            SwiftEntryKit.dismiss()
        }!
        alertVC.autoActionClose = false
        SwiftEntryKit.display(entry: alertVC, using: attributes)
        
    }
    
    private func pushPageViewController(){
        let vc = LBCustomPageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
