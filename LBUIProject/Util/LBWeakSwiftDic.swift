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
        
        // 等价于map转换
//        let valueee = value.map({ Weak($0) })
//        
//        let flatResult = value.flatMap { val in
//            Weak(val)
//        }
//        
//        
//        var weakValue: Weak<Value>?
//        if let value = value{
//            weakValue = Weak.init(value)
//        }else{
//            weakValue = nil
//        }
//        
//        
//        storage[key] = weakValue
        
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
        let result1 = storage.compactMap { key, weakObj in
            if let value = weakObj.value {
                return (key, value)
            } else {
                return nil
            }
        }
        
//        let result2 = storage.compactMap({ ($0.key, $0.value.value )})
        return result1
    }

    /// 字典大小（仅计算有效对象）
    var count: Int {
        storage.reduce(0) { $0 + ($1.value.value == nil ? 0 : 1) }
    }
}
