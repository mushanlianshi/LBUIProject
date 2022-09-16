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
        guard let data = try? JSONSerialization.data(withJSONObject: base,
                                                     options: []) else {
            return nil
        }
        guard let str = String(data: data, encoding: .utf8) else {
            return nil
        }
        return str
    }
    
    public func addEntriesFromDic(dic: Dictionary<String, Any>?) -> [String: Any]{
        var result = [String: Any]()
        guard let fromDic = dic else { return result }
        self.base.forEach { (key, value) in
            result[key] = value
        }
        fromDic.forEach { (key, value) in
            result[key] = value
        }
        return result
    }
    
}
