//
//  BLTDispatchTask.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/4/18.
//

import Foundation

public typealias BLTDispatchTask = (_ cancel: Bool) -> Void

public func BLTDispatchTaskDelay(_ time: TimeInterval, task: (@escaping ()->Void)) -> BLTDispatchTask? {
    
//    1.延迟执行任务的方法
    func later_exec(block:(@escaping ()->Void)){
        let t = DispatchTime.now() + time
        DispatchQueue.main.asyncAfter(deadline: t, execute: block)
    }
    
    
    var block: (() -> Void)? = task
    var result: BLTDispatchTask?
    
//    2.延迟执行的具体任务
    let delayedBlock: BLTDispatchTask = {
        cancel in
        if let innerBlock = block, cancel == false{
            DispatchQueue.main.async(execute: innerBlock)
        }
        block = nil
        result = nil
    }
    
    result = delayedBlock
    
    later_exec {
        if let delayBlock = result{
            delayBlock(false)
        }
    }
    return result
}

public func BLTDispatchTaskCancel(_ task: BLTDispatchTask?) {
    task?(true)
}




//加锁执行
public func BLTSynchronized(_ lockObj: AnyObject, closure: () -> Void){
    objc_sync_enter(lockObj)
    closure()
    objc_sync_exit(lockObj)
}
