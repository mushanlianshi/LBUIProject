//
//  LBUserDeraultPropertyWrapped.swift
//  LBUIProject
//
//  Created by liu bin on 2025/12/22.
//

import Foundation

@propertyWrapper
struct LBUserDefaultWrapped <Value>{
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard
    var wrappedValue: Value {
        get{
            container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            /// 这里的optional 是Optional<Value>类型，只有是Optional类型才会走到这里。 Optional遵守AnyOptional协议，可以调用isNil属性
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
        }
    }
}


/// 处理默认可以是nil的, 封装一个类型，用来转换as?用的.  因为直接判断defaultValue == nil 会失败，defaultValue是Value类型，不是可选类型
public protocol AnyOptional{
    var isNil: Bool { get }
}

extension Optional: AnyOptional{
    public var isNil: Bool {
        let result = self == nil
        debugPrint("LBLog result is \(result)")
        return result
    }
}

extension LBUserDefaultWrapped where Value : ExpressibleByNilLiteral{
    init(key: String, _ container: UserDefaults = .standard){
        self.init(key: key, defaultValue: nil, container: container)
    }
}


extension UserDefaults{
    @LBUserDefaultWrapped(key: "hasShowGuidePage", defaultValue: false)
    static var hasShowGuidePage: Bool
    
    @LBUserDefaultWrapped(key: "currentVersion", defaultValue: "")
    static var currentVersion
    
    @LBUserDefaultWrapped(key: "houseId")
    static var houseId: String?
}

