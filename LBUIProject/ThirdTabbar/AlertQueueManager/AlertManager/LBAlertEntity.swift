//
//  LBAlertConfig.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/28.
//

import Foundation

///弹框的实体  包含了弹框的是VC还是alert  以及配置 优先级等
class LBAlertEntity {
    
    struct Content {
        ///在 Swift 中，! 符号用于声明一个隐式解包可选类型（implicitly unwrapped optional）。隐式解包可选类型是一种特殊类型的可选类型，它可以自动解包，不需要每次访问时都使用可选链或强制解包。
//        在你提供的例子中，var viewController: UIViewController! 声明了一个名为 viewController 的属性，类型为 UIViewController!，即隐式解包可选类型的 UIViewController。这意味着该属性可以存储 UIViewController 对象或者 nil，并且在使用时可以自动解包，不需要每次使用时进行可选绑定或强制解包。
//        使用隐式解包可选类型时，需要注意确保属性在使用之前已经被初始化，否则访问该属性时会触发运行时错误。如果尝试访问一个尚未初始化的隐式解包可选类型的属性，会导致程序崩溃。
        var viewController: UIViewController!
        var view: UIView!
        var config: LBAlertConfig
        
        init(viewController: UIViewController, config: LBAlertConfig) {
            self.viewController = viewController
            self.config = config
        }
        
        init(view: UIView, config: LBAlertConfig) {
            self.view = view
            self.config = config
        }
    }
    
    var content: Content
    
    init(content: Content){
        self.content = content
    }
    
}
