//
//  Dictionary+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/26.
//

import Foundation
import SMSwiftBasicKit


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


// MARK: - Dictionary 默认值取值（2026/9/2 新增）
/// Dictionary 泛型桥接协议：BLTNameSpace 无法直接对 Dictionary 的
/// Key/Value 泛型参数做 where 约束（只能写 Dictionary<String, Any> 这类具体化），
/// 经本协议把 Key/Value 暴露为关联类型，扩展即可覆盖任意字典类型。
/// Dictionary 原生的 subscript(key:) -> Value? 恰好满足协议要求，空遵守即可（无递归）
public protocol BLTDictionaryBridge {
    associatedtype Key
    associatedtype Value
    subscript(key: Key) -> Value? { get }
}

extension Dictionary: BLTDictionaryBridge {}

extension BLTNameSpace where Base: BLTDictionaryBridge {

    /// 取值，key 不存在（或值为 nil）时返回传入的默认值
    ///
    /// 用法：
    /// `["a": 1].blt.value(for: "a", default: 0)` → `1`
    /// `["a": 1].blt.value(for: "b", default: 0)` → `0`
    /// `[Int: String]().blt.value(for: 9, default: "匿名")` → `"匿名"`
    public func value(for key: Base.Key, default defaultValue: Base.Value) -> Base.Value {
        base[key] ?? defaultValue
    }
}
