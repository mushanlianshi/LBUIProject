//
//  LBCombineViewModel.swift
//  LBUIProject
//
//  Created by liu bin on 2025/1/8.
//

import Foundation
import Combine

class LBCombineViewModel{
    
    lazy var model = LBCombineModel.init()
    ///PassthroughSubject 不缓存值，首次发送打空。
    var modelSubject2 = PassthroughSubject<LBCombineModel?, Never>()
    ///新订阅者自动收到当前值
    var modelSubject = CurrentValueSubject<LBCombineModel?, Never>.init(nil)
    
    init() {
        model.name = "jaja"
        model.age = 100
        modelSubject.send(model)
    }
    
    
    func changeModel(){
        model.age = model.age + 77
        model.name =  model.name + "hahahhahah"
        modelSubject.send(model)
    }
    
}
