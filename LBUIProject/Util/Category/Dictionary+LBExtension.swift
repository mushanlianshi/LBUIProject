//
//  Dictionary+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/26.
//

import Foundation
import SMSwiftBasicKit


// MARK: - 原地合并（mutating，2026/9/2 新增）
/// mutating 方法无法挂在 .blt 命名空间上：BLTNameSpace.base 是 let 属性，
/// 且 Dictionary 是 struct，`dict.blt` 持有的是拷贝——改 base 影响不到原字典。
/// 故直接 extension Dictionary（与上方非 mutating 的 addEntriesFromDic 区分：
/// 那个返回新字典，本组方法原地修改）。
/// 标准库 merge(_:uniquingKeysWith:) 每次都要传闭包，这里提供免闭包便捷版
public extension Dictionary {

    /// 原地合并另一个字典，key 冲突时新值覆盖旧值（对齐 OC addEntriesFromDictionary 语义）
    ///
    /// 用法：
    /// var dict = ["a": 1, "b": 2]
    /// dict.bltMerge(["b": 99, "c": 3])
    /// // dict == ["a": 1, "b": 99, "c": 3]
    mutating func bltMerge(_ other: [Key: Value]) {
        other.forEach { self[$0.key] = $0.value }
    }

    /// 原地合并键值对序列（元组数组等），同样新覆盖旧
    ///
    /// 用法：`dict.bltMerge([("k1", 1), ("k2", 2)])`
    mutating func bltMerge<S: Sequence>(_ pairs: S) where S.Element == (Key, Value) {
        pairs.forEach { self[$0.0] = $0.1 }
    }

    /// 原地合并，key 冲突时保留旧值（与 bltMerge 覆盖策略相反，按需选用）
    ///
    /// 用法：
    /// var dict = ["a": 1]
    /// dict.bltMergeKeepingCurrent(["a": 99, "b": 2])
    /// // dict == ["a": 1, "b": 2]
    mutating func bltMergeKeepingCurrent(_ other: [Key: Value]) {
        for (key, value) in other where self[key] == nil {
            self[key] = value
        }
    }
}


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
