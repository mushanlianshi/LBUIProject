//
//  BLTAppStorage.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/2/6.
//

import Foundation


///属性解释器  处理统一动作
///属性解释器 要默认实现wrappedValue属性
///遵守Codable协议 可以支持自定义类型的存储
///struct User: Codable {
//var name: String
//var age: Int
//var date: Date?
//}
//struct BLTAppUserDefault {
//    @BLTAppStorage<Bool>(key: "login", defaultValue: false)
//    static var isLogin: Bool
//
//    @BLTAppStorage<String>(key: "name", defaultValue: "")
//    static var name: String
//}

@propertyWrapper
public struct BLTAppStorage<T: Codable> {
    
    private let key: String
    private let defaultValue: T?
    
    public init(key: String, defaultValue: T? = nil){
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T? {
        get {
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                return defaultValue
            }
            let value = try? JSONDecoder().decode(T.self, from: data)
            return value ?? defaultValue
        }
        set {
            //把newValue 转成Data序列化
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}


//@propertyWrapper
//public struct BLTCategoryStore<T>{
//    private let key: UnsafeRawPointer
//    private let policy: objc_AssociationPolicy
//    
//    init(key: UnsafeRawPointer, policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC) {
//        self.key = key
//        self.policy = policy
//    }
//    
//    public var wrappedValue: T? {
//        get{
//            return objc_getAssociatedObject(self, key) as? T
//        }
//        
//        set{
//            objc_setAssociatedObject(self, key, newValue, policy)
//        }
//    }
//}


