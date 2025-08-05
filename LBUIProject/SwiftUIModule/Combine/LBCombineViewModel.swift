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
    
    var modelSubject = PassthroughSubject<LBCombineModel?, Never>()
    
    var modelSubject2 = CurrentValueSubject<LBCombineModel?, Never>.init(nil)
    
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
