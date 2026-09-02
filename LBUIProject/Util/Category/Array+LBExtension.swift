//
//  Array+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/22.
//

import Foundation
import HandyJSON
import SMSwiftBasicKit

// MARK: - Collection 越界保护取值（2026/9/2 新增）
/// 通用 Collection 约束：覆盖 Array 任意元素类型、String、Set 等，
/// 不再限于 Array<Any>；越界返回 nil 而非崩溃
extension BLTNameSpace where Base: Collection {

    /// 越界安全下标：index 在有效范围内返回元素，越界返回 nil
    ///
    /// 用法：
    /// `[1, 2, 3].blt[safe: 1]` → `Optional(2)`
    /// `[1, 2, 3].blt[safe: 9]` → `nil`
    /// `"hello".blt[safe: 0]` → `Optional("h")`（String 也是 Collection）
    public subscript(safe index: Base.Index) -> Base.Element? {
        base.indices.contains(index) ? base[index] : nil
    }

    /// 越界安全取值（方法形态，与 safe 下标等价）
    ///
    /// 用法：`["a", "b"].blt.value(at: 5)` → `nil`
    public func value(at index: Base.Index) -> Base.Element? {
        base.indices.contains(index) ? base[index] : nil
    }
}

/// Set 接入命名空间（与 Array 同属 Collection，safe 取值同样适用）
extension Set: BLTNameSpaceCompatible {}


//array 已经遵守Element泛型了
extension Array{
    var random: Element?{
        if self.count == 0{
            return nil
        }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
    func appendRandomDescription<U: CustomStringConvertible>(_ input: U) -> String{
        if let element = self.random{
            return "\(element) " + input.description
        }
        return "empty array"
    }
}
