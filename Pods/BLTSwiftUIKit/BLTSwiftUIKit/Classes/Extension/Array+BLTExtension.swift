//
//  Array+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/17.
//

import Foundation

extension Array: BLTNameSpaceCompatibleValue{}

extension BLTNameSpace where Base == Array<Any>{
    
    public func objectAt(index:Int) -> Any? {
        return (0 ..< base.count).contains(index) ? base[index] : nil
    }
    
    //    处理可选参数的
    public func objectAt<T>(inputIndex: Int...) -> ArraySlice<T>{
        var result = ArraySlice<T>()
        for i in inputIndex {
            assert(i < self.base.count, "LBLog index out of range")
            if let element = self.base[i] as? T{
                result.append(element)
            }
        }
        return result
    }
    
    //    处理数组支持多下标取值  利用数组的方式
    public subscript<T>(input: [Int]) -> ArraySlice<T> {
        get {
            var result = ArraySlice<T>()
            for i in input{
                assert(i < self.base.count, "LBLog index out of range")
                if let item = self.base[i] as? T{
                    result.append(item)
                }
            }
            return result
        }
    }
    
//    public subscript<T>(safe index: Int) -> T?{
//        guard (base.startIndex ..< base.endIndex).contains(index) else{
//            return nil
//        }
//        return base[index] as? T
//    }
}



public extension Array{

    
    
}
