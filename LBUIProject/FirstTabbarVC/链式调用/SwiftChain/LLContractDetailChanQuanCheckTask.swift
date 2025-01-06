//
//  LLContractDetailChanQuanCheckTask.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2023/6/2.
//  Copyright © 2023 com.wanjian. All rights reserved.
//

import Foundation
import BLTSwiftUIKit


///产权任务检查
class LLContractDetailChanQuanCheckTask: LLContractDetailBeforeSignCheckTask {
    
    override func receiveData(_ data: LLContractDetailSignBeforeModel, completeBlock: ((Error?) -> Void)?) {
        
        guard data.is_need_chanquan_task else {
            completeBlock?(nil)
            return
        }
        
        self.currentVC?.blt.presentSureTipAlert(title: "温馨提示", content: "目前部分产权证明文件尚有欠缺，请于签约后三个工作日内进行补齐，否则乙方有权单方解除本合同", sureActionTitle: "我知道了", style: .alert) { action in
            completeBlock?(nil)
        }
    }
}
