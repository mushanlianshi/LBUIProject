//
//  LBLoginCombineViewModel.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/1/9.
//

import Foundation
import Combine

class LBLoginCombineViewModel {
    
    @Published var phone: String?
    
    @Published var code: String?
    
    @Published var isAgree = false
    
    var cancellables = Set<AnyCancellable>()
    
    /// 手机号是否合法的校验
    var phoneValidPublisher: AnyPublisher<Bool, Never>{
        /// 把Published发布的内容转成一个发布者
        return $phone.map{ $0?.count == 11 ? true : false}.eraseToAnyPublisher()
    }
    
    ///验证码是否合法的校验
    var codeValidPublisher: AnyPublisher<Bool, Never>{
        return $code.map { code in
            guard let code = code, code.count == 4, let _ = Int(code) else{
                return false
            }
            return true
        }.eraseToAnyPublisher()
    }
    
    
}
