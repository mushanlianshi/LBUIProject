//
//  LLContractDetailMutiContractCheckTask.swift
//  Baletoo_landlord
//
//  Created by liu bin on 2023/6/2.
//  Copyright © 2023 com.wanjian. All rights reserved.
//

import Foundation
import BLTSwiftUIKit

class LLContractDetailMutiContractCheckTask: LLContractDetailBeforeSignCheckTask {
    
    var lookOtherContractBlock: (() -> Void)?
    
    override func receiveData(_ data: LLContractDetailSignBeforeModel, completeBlock: ((Error?) -> Void)?) {
        
        guard data.is_multiple_contract else {
            completeBlock?(nil)
            return
        }
        
        self.currentVC?.blt.presentAlert(title: .blt.alertTipTitle, content: "该房源已有租约，请仔细核对租约信息哦~ ", style: .alert, cancelTitle: "查看其他租约", cancelBlock: { [weak self] action in
            self?.lookOtherContractBlock?()
        }, sureTitle: "确认签署", sureBlock: { action in
            completeBlock?(nil)
        }, tapBackDismiss: false)
    }
    
    
//    override var needComplete: Bool{
//        return true
//    }
}
