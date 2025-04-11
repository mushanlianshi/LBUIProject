//
//  Dictonary+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/5/18.
//

import Foundation

extension Dictionary: BLTNameSpaceCompatibleValue{}

extension BLTNameSpace where Base == Dictionary<String, Any>{
    
    public func toJsonString() -> String? {
        return (self.base as [AnyHashable : Any]).blt.toJsonString()
    }
    
    public func addEntriesFromDic(dic: Dictionary<String, Any>?) -> [String: Any]{
        var result = [String: Any]()
        guard let fromDic = dic else { return self.base }
        self.base.forEach { (key, value) in
            result[key] = value
        }
        fromDic.forEach { (key, value) in
            result[key] = value
        }
        return result
    }
    
    public func toData() -> Data? {
        return (self.base as [AnyHashable : Any]).blt.toData()
    }
    
    /// get请求拼接参数的样式
    public func queryString() -> String? {
        guard self.base.isEmpty == false else {
            return nil
        }
        var components = URLComponents()
        components.queryItems = self.base.map { key, value in
            URLQueryItem(name: key, value: "\(value)")
        }
        return components.percentEncodedQuery
    }
}

extension BLTNameSpace where Base == Dictionary<AnyHashable, Any>{
    
    public func toJsonString() -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: base,
                                                     options: []) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }
    
    public func addEntriesFromDic(dic: Dictionary<AnyHashable, Any>?) -> [AnyHashable: Any]{
        var result = [AnyHashable: Any]()
        guard let fromDic = dic else { return self.base }
        self.base.forEach { (key, value) in
            result[key] = value
        }
        fromDic.forEach { (key, value) in
            result[key] = value
        }
        return result
    }
    
    public func toData() -> Data? {
        guard let data = try? JSONSerialization.data(withJSONObject: base,
                                                     options: []) else {
            return nil
        }
        return data
    }
}



