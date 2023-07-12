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
    
//    var completeBlock: ((_ error: Error) -> Void)? { get set }
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
        
        chain.receiveData(infoData) { [ weak self] error in
            guard error == nil else{
                completeBlock?(error)
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

