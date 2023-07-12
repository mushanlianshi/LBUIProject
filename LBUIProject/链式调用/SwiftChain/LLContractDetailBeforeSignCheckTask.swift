//
//  LLContractDetailBeforeSignCheckTask.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2023/6/2.
//  Copyright © 2023 com.wanjian. All rights reserved.
//

import Foundation
import HandyJSON


//签署租约前 调接口确认信息的
struct LLContractDetailSignBeforeModel: HandyJSON{
    var is_need_alert_service_tip = false
    var service_alert_title: String?
    var service_alert_content: String?
    
//    七天无理由的
    var is_need_alert_change_day_ahead = false
    var alert_title: String?
    var alert_content: String?
    
//    结算方式的
    var is_need_choose_out_money_style = false
    
    ///是否是一人多租约
    var is_multiple_contract = false
    
    ///是不是需要产权任务
    var is_need_chanquan_task = false
    
}



/// 任务的基类  处理泛型用的
class LLContractDetailBeforeSignCheckTask: NSObject, BLTTaskChainProtocol {
    var needComplete: Bool{
        return false
    }
    
    func receiveData(_ data: LLContractDetailSignBeforeModel, completeBlock: ((Error?) -> Void)?) {

    }
    
    var nextChain: (any BLTTaskChainProtocol)?
    
    typealias DataType = LLContractDetailSignBeforeModel

    weak var currentVC: UIViewController?
    
    convenience init(_ currentVC: UIViewController? = nil) {
        self.init()
        self.currentVC = currentVC
    }
}


