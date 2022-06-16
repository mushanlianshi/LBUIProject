//
//  BLTConvertDataFromResponse.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/4/2.
//

import Foundation
import HandyJSON

public class BLTConvertDataFromResponse<T: HandyJSON>{
    //从后台接口返回里取一个列表数组  convertKey 字段  belowResult是不是result下面 默认yes  老接口直接在array下
    public static func blt_list_from_response(response: [AnyHashable : Any], convertKey: String, belowResult: Bool = true) -> [T]{
        var list = [T]()
        guard let res = response as? [String : Any] else { return list }
        if belowResult{
            guard let result = res["result"] as? [String : Any], let array = result[convertKey] as? [[String : Any]] else { return list }
            for dic in array {
                if let model = T.deserialize(from: dic){
                    list.append(model)
                }
            }
        }else{
            guard let array = res["result"] as? [[String : Any]] else { return list }
            for dic in array {
                if let model = T.deserialize(from: dic){
                    list.append(model)
                }
            }
        }
        return list
    }
    
//    默认result下
    public static func blt_model_from_response(response: [AnyHashable : Any]?, designatedPath: String? = nil) -> T?{
        guard let res = response as? [String : Any] else { return nil }
        guard let result = res["result"] as? [String : Any] else{ return nil }
        return T.deserialize(from: result, designatedPath: designatedPath)
    }
}
