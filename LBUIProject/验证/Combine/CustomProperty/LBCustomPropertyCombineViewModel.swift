//
//  LBCustomPropertyCombineViewModel.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/14.
//

import Foundation
import Combine

class LBCustomPropertyCombineViewModel{
    
    var modelObserver = PassthroughSubject<LBCombinePropertyModel?, Never>.init()
    
    var validState = PassthroughSubject<LBButtonValidState, Never>.init()
    
    var selected = CurrentValueSubject<Bool, Never>.init(true)

    @Published var name = "123"
    
    private var model: LBCombinePropertyModel?
    
    private var state = LBButtonValidState.ok("normal")
    
    func fetchData(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            self?.model = LBCombinePropertyModel.init(name: "liu", age: 18, selected: false)
            self?.changeValidState()
        })
    }
    
    func changeValidState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 , execute: {
            [weak self] in
            guard let self = self else { return }
            self.model?.age += 1
            switch self.state {
            case .ok:
                self.state = .empty("empty ")
            case .empty:
                self.state = .ok("ok")
            }
            self.validState.send(self.state)
            self.modelObserver.send(self.model)
            self.changeValidState()
        })
    }
    
}
