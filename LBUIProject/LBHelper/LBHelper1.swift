//
//  LBHelper.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/21.
//

//import Foundation

//可以用来处理一些方法交换的 不需要在load中就交换的   比如按钮防止多次点击的  tableview 点击元素内容采集的
//class LBHelper1: NSObject{
////    用来保存执行block的标识的  保证只执行一次
//    private static let executeIdentifiers = NSMutableSet()
//
//    private static let lock = NSLock()
////    保证只执行一次的
////    identifier 唯一的标识  保证唯一
////    closure 要执行的block
//    static func executeBlock(closure: (() -> Void), identifier: String) -> Bool{
////        加锁 防止多线程执行的
//        if identifier.isEmpty {
//            return false
//        }
//
//        if executeIdentifiers.contains(identifier){
//            return false
//        }
//        objc_sync_enter(self)
//        executeIdentifiers.add(identifier)
//        closure()
//        objc_sync_exit(self)
//        return true
//    }
//
//}
//
//
//func sychornized(closure: (()->Void), identifier: AnyObject){
//    objc_sync_enter(identifier)
//    closure()
//    objc_sync_exit(identifier)
//}
