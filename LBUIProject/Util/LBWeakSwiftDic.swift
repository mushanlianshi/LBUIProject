//
//  LBWeakSwiftDic.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/17.
//

import Foundation


/// 封装一个弱引用包装器
final class Weak<Value: AnyObject> {
    weak var value: Value?
    init(_ value: Value) {
        self.value = value
    }
}

/// 封装一个弱引用字典工具  实现类似NSCache类型弱引用字典类
struct WeakDictionary<Key: Hashable, Value: AnyObject> {
    private var storage: [Key: Weak<Value>] = [:]

    /// 添加对象
    mutating func set(_ value: Value?, forKey key: Key) {
        let valueee = value.map({ Weak($0) })
        storage[key] = value.map { Weak($0) }
    }

    /// 访问对象
    func get(forKey key: Key) -> Value? {
        return storage[key]?.value
    }

    /// 移除某个 key
    mutating func removeValue(forKey key: Key) {
        storage.removeValue(forKey: key)
    }

    /// 清理已被释放的对象
    mutating func cleanReleasedObjects() {
        storage = storage.filter { $0.value.value != nil }
    }

    /// 当前所有有效的对象
    var allValues: [Value] {
        storage.compactMap { $0.value.value }
    }

    /// 当前所有 key-value 的元组
    var allItems: [(Key, Value)] {
        storage.compactMap { key, weak in
            if let value = weak.value {
                return (key, value)
            } else {
                return nil
            }
        }
    }

    /// 字典大小（仅计算有效对象）
    var count: Int {
        storage.reduce(0) { $0 + ($1.value.value == nil ? 0 : 1) }
    }
}
