//
//  LBMoyaProviderResult.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/23.
//

import Foundation
import Moya

func blt_intvalue(_ obj : Any?) -> Int?{
    guard let obj = obj else { return nil }
    if let obj = obj as? Int {  return obj }
    if let obj = obj as? String { return Int(obj) }
    if let obj = obj as? Bool { return obj == true ? 1 : 0 }
    return nil
}


private var businessResultKey: Void?

extension Moya.Response{
    var businessResult: [String : Any]?{
        get{
            objc_getAssociatedObject(self, &businessResultKey) as? [String : Any]
        }
        set{
            return objc_setAssociatedObject(self, &businessResultKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}


///处理网络错误  和业务错误都当成错误返回给业务   在这里拦截业务错误 看需不需要上传
enum LBMoyaProviderResult {
    
    ///处理网络错误  和业务错误都当成错误返回给业务   在这里拦截业务错误 看需不需要上传
    static func convertToBusinessResult( result: Result<Moya.Response, MoyaError>) -> Result<Moya.Response, MoyaError>{
        if case .failure(_) = result {
            return result
        }
        
        guard case let .success(res) = result, let response = try? JSONSerialization.jsonObject(with: res.data) as? [String : Any], let bltResult = response["result"] as? [String : Any] else {
            ///upload formatter error
            return Result.failure(.underlying(NSError.init(domain: "数据格式不正确", code: 1010), nil))
        }
        
        guard let code = blt_intvalue(response["code"]), code == 0 else {
            return Result.failure(.underlying(NSError.init(domain: (response["msg"] as? String) ?? "", code: 1010), nil))
        }
        res.businessResult = bltResult
        return result
        
    }
}
