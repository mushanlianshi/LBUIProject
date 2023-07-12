//
//  LBBaseMoyaProvider.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/23.
//

import Foundation
import Moya

class LBBaseMoyaProvider<Target>: MoyaProvider<Target> where Target: LBMoyaTargetTypeProtocol {
    
    
    
    
    @discardableResult
    open func request2222(_ target: Target,
                      callbacOkQueue: DispatchQueue? = .none,
                      progress: ProgressBlock? = .none,
                      completion: @escaping Completion) -> Cancellable {

//        let callbackQueue = callbacOkQueue ?? self.callbackQueue
        return requestNormal(target, callbackQueue: callbacOkQueue, progress: progress, completion: completion)
    }
    
}
