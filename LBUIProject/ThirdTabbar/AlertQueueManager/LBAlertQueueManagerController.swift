//
//  LBAlertQueueManagerController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/26.
//

import UIKit
import BLTSwiftUIKit
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
        
        ///先弹一个展示后面的才会按优先级弹出
        let view = UIView()
        var att = EKAttributes.customAlertAttribute()
        att.precedence = .override(priority: .normal, dropEnqueuedEntries: true)
        SwiftEntryKit.display(entry: view, using: att)
        SwiftEntryKit.dismiss()
        
        
        var attributes = EKAttributes.customAlertAttribute()
        attributes.name = "11"
        attributes.precedence = .enqueue(priority: .normal)
        let alertVC = BLTAlertController.init(title: "自定义controller alert", mesage: "", style: .alert, cancelTitle: "取消", cancel: {
            action in
            SwiftEntryKit.dismiss()
        }, sureTitle: .blt.sureTitle) { action in
            SwiftEntryKit.dismiss()
        }!
        SwiftEntryKit.display(entry: alertVC, using: attributes)
        
        startHighPriorityAlert()
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
        SwiftEntryKit.display(entry: alertVC, using: attributes)
        
    }
    
    private func pushPageViewController(){
        let vc = LBCustomPageViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}
