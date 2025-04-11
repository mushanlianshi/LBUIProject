//
//  Sequence+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/12/15.
//

import Foundation

extension Sequence where Element: Hashable{
    ///一个计算属性   返回相同元素出现的个数的字典
    ///如果是数组["liu", "zhang", "li", "zhang", "liu", "liu"] -> ["liu" : 3, "zhang" : 2, "li" : 1]
    /// 如果是字符串 "liu bin" -> ["l" : 1, "i" : "2" , "b" : 1, "u" : 1, "n" : 1]
    public var frequencies: [Element : Int]{
        ///转换成(key, 1)元组的Sequence
        let frequencyPairs = self.map { ($0, 1) }
        return Dictionary(frequencyPairs, uniquingKeysWith: +)
    }
    
}
