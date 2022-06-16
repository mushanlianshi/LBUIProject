//
//  NSObject+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/5/18.
//

import Foundation

//没有用命名空间  消除警告 不然所有的NSObject都会有blt属性
extension NSObject{
    //获取类型
    public var blt_runtimeType: NSObject.Type{
        return type(of: self)
    }
    
    //获取类的字符串名称
    public static var blt_className: String{
        return String(describing: self)
    }
    
    //获取对象的字符串名称
    public var blt_className: String{
        return blt_runtimeType.blt_className
    }
    
}

