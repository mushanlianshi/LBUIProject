//
//  LBCustomQueueManager.swift
//  LBUIProject
//
//  Created by liu bin on 2022/8/25.
//

import Foundation


///自定义队列来处理异步任务   防止无限使用global线程导致 线程优先级变化，main thread优先级下降 的
///priority 主线程的默认47 等级最高  但系统也会调度动态降低优先级  最低也是 29  尤其在低性能手机上   内核少   更明显
///main thread priority 47 
///userInteractive 46
///userInitiated 37 (默认 是userInitiated priority)
///utility 20
///background 4
/// 默认执行优先级放低一点   以免影响主线程  根据具体业务来处理
/// 也可以使用global队列来指定qos
public class LBCustomQueueManager{
    let shared = LBCustomQueueManager()
    
    lazy var serialQueue = DispatchQueue.init(label: "custom serial queue", qos: DispatchQoS.utility)
    
    lazy var concurrentQueue = DispatchQueue.init(label: "custom concurrent queue", qos: DispatchQoS.utility, attributes: DispatchQueue.Attributes.concurrent)
    
    lazy var highConcurrentQueue = DispatchQueue.init(label: "custom concurrent queue", qos: DispatchQoS.userInitiated, attributes: DispatchQueue.Attributes.concurrent)
    
    func asyncExecuteTask(qos: DispatchQoS = .utility, block:(() -> Void)?) {
        if qos == .utility{
            concurrentQueue.async {
                block?()
            }
        }else{
            highConcurrentQueue.async {
                block?()
            }
        }
    }
    
    
}
