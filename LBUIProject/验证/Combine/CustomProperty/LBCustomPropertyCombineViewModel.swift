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
    
    var thread: Thread?
    
    func fetchData(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
            [weak self] in
            self?.model = LBCombinePropertyModel.init(name: "liu", age: 18, selected: false)
            self?.changeValidState()
//            self?.changeValidStateUseThread()
//            self?.testThread2()
        })
    }
    
    func changeValidState() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2 , execute: {
            [weak self] in
            guard let self = self else { return }
            self.changeModel()
//            self.model?.age += 1
//            switch self.state {
//            case .ok:
//                self.state = .empty("empty ")
//            case .empty:
//                self.state = .ok("ok")
//            }
//            self.validState.send(self.state)
//            self.modelObserver.send(self.model)
//            self.changeValidState()
        })
    }
    
    // 通过Swift5.5 Concurrency来实现
    func changeValidStateUseThread() {
        thread?.cancel()
        thread = nil
        if (thread == nil){
            thread = Thread {
                [weak self] in
                self?.changeModel()
                Thread.sleep(forTimeInterval: 1)
                print("LBLog thread is \(Thread.current)")
                self?.changeValidStateUseThread()
            }
        }
        thread?.start()
    }
    
    func testThread2 (){
        let thread = Thread {
            print("线程开始")
            // 模拟任务
            for i in 1...5 {
                print("执行任务 \(i)")
                sleep(1)
            }
            print("线程任务完成，线程即将退出")
        }

        thread.start()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12, execute: {
            print("LBLOg thread is isCancelled \(thread.isCancelled)")
            print("LBLOg thread is isFinished \(thread.isFinished)")
        })
    }
    
    func changeModel()  {
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
    }
    
}
