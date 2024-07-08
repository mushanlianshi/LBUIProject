//
//  Dictionary+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/26.
//

import Foundation
import BLTSwiftUIKit


///项目中都是String
extension BLTNameSpace where Base == Dictionary<String, Any>{
    public func addEntries(from otherDictionary: [String : Any]?) -> [String : Any]{
        var totalDic = base
        otherDictionary?.forEach { (key: String, value: Any) in
            totalDic[key] = value
        }
        return totalDic
    }
}

///项目中都是String
extension BLTNameSpace where Base == Dictionary<AnyHashable, Any>{
    public func addEntries(from otherDictionary: [AnyHashable : Any]?) -> [AnyHashable : Any]{
        var totalDic = base
        otherDictionary?.forEach { (key: AnyHashable, value: Any) in
            totalDic[key] = value
        }
        return totalDic
    }
}
