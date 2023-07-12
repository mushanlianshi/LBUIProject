//
//  BLTNameSpace.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2021/12/8.
//

import Foundation

public struct BLTNameSpace<Base>{
    public var base: Base
//    public var BASE: Self.Type
    
    public init(_ base: Base){
        self.base = base
//        self.BASE = Self.self
    }

}

///处理引用类型的
public protocol BLTNameSpaceCompatible: AnyObject{
    associatedtype BLTCompatibleType
    var blt: BLTCompatibleType { set get }
    
    static var blt: BLTCompatibleType.Type {set get}
    
    ///打印log的方法
    func toPrintBLTLog(_ prefix: String?)
}

public extension BLTNameSpaceCompatible{
    var blt: BLTNameSpace<Self>{
        get{
            return BLTNameSpace(self)
        }
        
        set {}
    }
    
    static var blt: BLTNameSpace<Self>.Type{
        get{
            return BLTNameSpace<Self>.self
        }
        set{}
    }
    
    func toPrintBLTLog(_ prefix: String? = "BLTLog") {
        BLTSwiftLog("\(prefix ?? "")  \(self)")
    }
}


///处理值类型的
public protocol BLTNameSpaceCompatibleValue{
    associatedtype BLTCompatibleType
    var blt: BLTCompatibleType { set get }
    
    static var blt: BLTCompatibleType.Type {set get}
    
    func toPrintBLTLog(_ prefix: String?)
}

public extension BLTNameSpaceCompatibleValue{
    var blt: BLTNameSpace<Self>{
        get{
            return BLTNameSpace(self)
        }
        
        set {}
    }
    
    static var blt: BLTNameSpace<Self>.Type{
        get{
            return BLTNameSpace<Self>.self
        }
        set{}
    }
    
    func toPrintBLTLog(_ prefix: String? = "BLTLog") {
        BLTSwiftLog("\(prefix ?? "")  \(self)")
    }
}

