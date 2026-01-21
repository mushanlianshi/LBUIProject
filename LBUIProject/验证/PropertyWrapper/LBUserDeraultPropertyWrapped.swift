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
    var defaultValue: Value
    var container: UserDefaults = .standard
    var wrappedValue: Value {
        get{
            container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                container.removeObject(forKey: key)
            } else {
                container.set(newValue, forKey: key)
            }
        }
    }
}


/// 处理默认可以是nil的
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
    
    @LBUserDefaultWrapped(key: "houseId", defaultValue: nil)
    static var houseId: String?
}

