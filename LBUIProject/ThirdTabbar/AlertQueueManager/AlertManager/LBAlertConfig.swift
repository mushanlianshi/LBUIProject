//
//  LBAlertConfig.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/28.
//

import Foundation

///弹框的config  包含了优先级等
public struct LBAlertConfig {
    ///优先级  优先级高的优先弹
    public var priority: Int = 0
    ///名称
    public var name: String?
    
    ///在哪个group  处理如果以后需要点击后移除相同groupId类型的弹框的   比如订单结束  订单相关的弹框都不展示了
    public var groupId: Int = 0
    ///是否移除相同groupID的弹框
    public var removeSameGroupIdAlert = false
    
    ///标识
    public var identifier: Int = 0
    
    
    public init(priority: Int = 0) {
        self.priority = priority
    }
}
