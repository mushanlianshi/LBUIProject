//
//  BLTTaskChainManager.swift
//  LBUIProject
//
//  Created by liu bin on 2023/6/2.
//

import Foundation


public protocol BLTTaskChainProtocol: NSObject {
    associatedtype DataType
    
    func receiveData(_ data: DataType, completeBlock:((_ error: Error?) -> Void)?)
    
    var nextChain: (any BLTTaskChainProtocol)? { get set }
    
    
    ///此任务执行完  是否就不在执行下面的任务链   针对纯任务链类似的任务的  每次只执行任务链中的一个任务用的（或则执行到某个任务就和后面的任务互斥的）
    ///如果是每个任务链中的任务都要执行  这个设置false
    var needComplete: Bool { get }
    
}

///责任链管理的类manager
public class BLTTaskChainManager<DataType, TaskType>: NSObject where TaskType: BLTTaskChainProtocol, TaskType.DataType == DataType{
    
    private var data: DataType?
    
    private lazy var chainList: [TaskType] = [TaskType]()
    
    func startTask(_ completeBlock: ((_ error: Error?) -> Void)?){
        print("LBLog task list \(self.chainList)")
        guard let chain = self.chainList.first, let infoData = data else {
            completeBlock?(nil)
            return
        }
        
        chain.receiveData(infoData) { [ weak self, weak chain] error in
            ///出现异常终止   把所有任务栈清空
            guard error == nil else{
                self?.chainList.removeAll()
                completeBlock?(error)
                return
            }
            
            ///针对纯任务链类似的模式  其中的某个任务执行了就不在往下执行的
            if let currentChain = chain, currentChain.needComplete{
                self?.chainList.removeAll()
                completeBlock?(nil)
                return
            }
            
            self?.chainList.removeFirst()
            self?.startTask(completeBlock)
        }
    }
    
    ///添加数据源
    @discardableResult
    func addData(_ data: DataType) -> Self{
        self.data = data
        return self
    }
    
    ///添加责任链任务
    @discardableResult
    func addTaskChain(_ task: TaskType) -> Self {
        self.chainList.append(task)
        self.chainList.last?.nextChain = task
        return self
    }
    
    ///移除所有的任务  针对任务中间被中断  重新执行一遍的
    func removeAllTask(){
        self.chainList.removeAll()
    }
}

