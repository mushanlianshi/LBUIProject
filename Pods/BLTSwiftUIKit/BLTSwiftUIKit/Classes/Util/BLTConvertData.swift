//
//  BLTConvertDataFromResponse.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/4/2.
//

import Foundation
import HandyJSON


public class BLTConvertData<T>{
//    public static func blt_value<T>(_ value: Any?) -> T?{
//        print("LBLog convert data generic origin func")
//        guard let _ = value else { return nil }
//        if T.self == Int.self {
//            return BLTConvertData<Int>.blt_value(value) as? T
//        }else if T.self == String.self{
//            return BLTConvertData<Int>.blt_value(value) as? T
//        }
//        return nil
//    }
    
    public static func blt_getErrorMsgFromResponse(_ response: Any?, _ defaultString: String? = nil) -> String {
        guard let dic = response as? [String : Any], let text = dic["msg"] as? String else { return defaultString ?? ""}
        return text
    }
    
    public static func blt_getRequestDataFromResponseResult(_ response: Any?, by designatedPath: String?) -> T?{
        var result: Any? = response
        var abort = false
        if let paths = designatedPath?.components(separatedBy: "."), paths.count > 0 {
            var next = response as? [String: Any]
            paths.forEach({ (seg) in
                if seg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || abort {
                    return
                }
                if let _next = next?[seg] {
                    result = _next
                    next = _next as? [String: Any]
                } else {
                    abort = true
                }
            })
        }
        guard abort == false else {
            return nil
        }
        return result as? T
    }
    
}



///利用HandyJson转模型的分类
extension BLTConvertData where T: HandyJSON{
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



extension BLTConvertData where T == Int{
    ///value 可以是dic["name"] 字典取出来的值 或则 dic， designatedPath = "people.name"
    public static func blt_value(_ value : Any?, designatedPath: String? = nil) -> Int?{
        BLTLogUtil.verbose("LBLog convert data generic is Int")
        guard let _ = value else { return nil }
        
        var resultValue: Any? = nil
        if let dic = value as? [String : Any], let path = designatedPath, path.isEmpty == false{
            resultValue = getInnerObject(inside: dic, by: designatedPath)
        }else{
            resultValue = value
        }
        
        if let obj = resultValue as? Int { return obj }
        if let obj = resultValue as? String {return Int(obj)}
        if let obj = resultValue as? Bool {return obj ? 1 : 0}
        
        return nil
    }
}


extension BLTConvertData where T == String{
    ///value 可以是dic["name"] 字典取出来的值 或则 dic， designatedPath = "people.name"
    public static func blt_value(_ value: Any?, designatedPath: String? = nil) -> String?{
        BLTLogUtil.verbose("LBLog convert data generic is String")
        guard let _ = value else { return nil }
        
        var resultValue: Any? = nil
        
        if let dic = value as? [String : Any], let path = designatedPath, path.isEmpty == false{
            resultValue = getInnerObject(inside: dic, by: designatedPath)
        }else{
            resultValue = value
        }
        
        if let obj = resultValue as? String {return obj}
        if let obj = resultValue as? Int { return String(obj) }
        if let obj = resultValue as? Bool {return obj ? "true" : "false"}
        
        return nil
    }
}

extension BLTConvertData where T == Dictionary<String, Any>{
    public static func blt_value(_ value: Any?, designatedPath: String? = nil) -> [String : Any]?{
        BLTLogUtil.verbose("LBLog convert data generic is Dictionary")
        guard let _ = value else { return nil }
        
        var resultValue: Any? = nil
        
        if let dic = value as? [String : Any], let path = designatedPath, path.isEmpty == false{
            resultValue = getInnerObject(inside: dic, by: designatedPath)
        }else{
            resultValue = value
        }
        return resultValue as? [String : Any]
    }
}


fileprivate func getInnerObject(inside object: Any?, by designatedPath: String?) -> Any? {
    var result: Any? = object
    var abort = false
    if let paths = designatedPath?.components(separatedBy: "."), paths.count > 0 {
        var next = object as? [String: Any]
        paths.forEach({ (seg) in
            if seg.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" || abort {
                return
            }
            if let _next = next?[seg] {
                result = _next
                next = _next as? [String: Any]
            } else {
                abort = true
            }
        })
    }
    return abort ? nil : result
}
