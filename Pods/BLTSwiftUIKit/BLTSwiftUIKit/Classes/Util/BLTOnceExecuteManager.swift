//
//  BLTOnceExecuteManager.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/9/19.
//

import Foundation


//swift版synchronize
public func synchronizedSwift(_ lock: Any, closure: () -> Void){
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

public class BLTOnceExecuteManager{
    
    static var identifierSet: NSMutableSet?
    
//    全局只执行一次
    @discardableResult
    public static func executeTask(task: (() -> Void), onceIdentifier: String) -> Bool{
        var result = false
        synchronizedSwift(self) {
            if identifierSet == nil{
                identifierSet = NSMutableSet()
            }
            
            if identifierSet!.contains(onceIdentifier) == false{
                identifierSet?.add(onceIdentifier)
                task()
                result = true
            }
            result = false
        }
        return result
    }
}
