//
//  LBFuctionTypeController.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/18.
//

import UIKit

//xcrun --sdk iphonesimulator swiftc \
//-target x86_64-apple-ios13.0 \
//-sdk $(xcrun --sdk iphonesimulator --show-sdk-path) \
//-emit-sil LBFuctionTypeController.swift > output.sil
//* 值类型（如 struct、enum）的方法默认采用静态派发。
//* 被 final private 修饰的类、方法和属性也使用静态派发。
//* 类的非 final、非 @objc、非 dynamic 方法默认使用函数表派发。
//* 使用 @objc 和 dynamic 关键字修饰的方法会采用消息派发。


//enum LBTestEnum{
//    case name
//}


struct LBFuctionStruct{
    func staticStructFunc() {
        
    }
    
    dynamic func messageStructFunc2() {
        
    }
}
class LBFuctionTypeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableFuction() {
        print("LBLog 函数表派发")
    }

    final func staticFuction() {
        print("LBLog 静态派发")
    }
    
    @objc func messageFuction() {
        print("LBLog 消息派发")
    }
    
    dynamic func message2Fuction() {
        print("LBLog 消息派发")
    }
}
