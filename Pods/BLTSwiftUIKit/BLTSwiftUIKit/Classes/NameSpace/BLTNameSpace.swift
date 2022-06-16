//
//  BLTNameSpace.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2021/12/8.
//

import Foundation

public struct BLTNameSpace<Base>{
    public let base: Base
//    public var BASE: Self.Type
    
    public init(_ base: Base){
        self.base = base
//        self.BASE = Self.self
    }

}

//处理引用类型的
public protocol BLTNameSpaceCompatible: AnyObject{
    associatedtype CompatibleType
    var blt: CompatibleType { set get }
    
    static var blt: CompatibleType.Type {set get}
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
}


//处理值类型的
public protocol BLTNameSpaceCompatibleValue{}

extension BLTNameSpaceCompatibleValue{
    public var blt: BLTNameSpace<Self>{
        get{
            return BLTNameSpace(self)
        }
        
        set {}
    }
}

