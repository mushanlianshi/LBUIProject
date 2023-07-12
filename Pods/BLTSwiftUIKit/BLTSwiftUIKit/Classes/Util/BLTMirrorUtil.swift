//
//  BLTMirrorUtil.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/2/27.
//

import Foundation

///讲value 包装成可选的类型  反射获取的value是Any类型， 但有的是nil，不能直接判断 需要包装成可选的才可以判断使用
public func bltGetWrapValue(value: Any) -> Any? {
    ///把Any类型的value 转成Optional  判断是不是nil  直接判断不出来
    if let nilValue = value as? Optional<Any>, nilValue == nil{
        return nil
    }
    return value
}

///反射的类  只能反射swift属性
///通过key反射获取swift的value
public func bltGetValueByKey(obj: Any, key: String) -> Any?{
    let mirror = Mirror.init(reflecting: obj)
    for case let (label?, value) in mirror.children {
        if key == label {
            return bltGetWrapValue(value:value)
        }
    }
    return nil
}


public protocol BLTConvertToDicProtocol {
    
    ///只需要转换的字段
    var bltConvertNameList: [String]? { get }
    
    ///把对象转成json字符串
    func bltToJsonString() -> String?
    
    ///把对象转成字典类型  一般用户接口参数的
    func bltToDic() -> [String : Any]
    
}


public extension BLTConvertToDicProtocol{
    var bltConvertNameList: [String]? {
        get{
            return nil
        }
    }
    
    func bltToJsonString() -> String? {
        let dic = bltToDic()
        guard let data = try? JSONSerialization.data(withJSONObject: dic, options: []) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
    
    func bltToDic() -> [String : Any]{
        
        ///获取value  如果是自定义类型  递归
        func getValueNeeded(key: String, value: Any, resultDic: inout [String : Any]){
            if let tmpValue = value as? BLTConvertToDicProtocol{
                resultDic[key] = tmpValue.bltToDic()
            }
            if let value = bltGetWrapValue(value:value){
                resultDic[key] = value
            }
        }
        
        let mirror = Mirror.init(reflecting: self)
        var dic = [String : Any]()
        for case let (key?, value) in mirror.children{
            ///处理只需要转换的字段
            if let list = bltConvertNameList, list.isEmpty == false {
                if list.contains(key) {
                    getValueNeeded(key: key, value: value, resultDic: &dic)
//                    getValueNeeded(value: key, resultDic: &dic)
                }
            }else{
//                getValueNeeded(value: key, resultDic: &dic)
//                dic[key] = getValueNeeded(value:value)
                getValueNeeded(key: key, value: value, resultDic: &dic)
            }
        }
        return dic
    }
}
