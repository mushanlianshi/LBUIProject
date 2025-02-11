//
//  LBStringToIntDecoder.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/5.
//

import Foundation

/// 自定义一个类型转换  字符串转int类型，可以用来字典转模型的时候使用
@propertyWrapper
struct LBStringToIntOptional: Codable {
    var wrappedValue: Int?
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            let intValue = Int(stringValue)
            wrappedValue = intValue
        }else{
            wrappedValue = try container.decode(Int.self)
        }
    }
}


@propertyWrapper
struct LBStringToIntDefaultZero: Codable {
    var wrappedValue: Int
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            let intValue = Int(stringValue)
            wrappedValue = intValue ?? 0
        }else{
            wrappedValue = try container.decode(Int.self)
        }
    }
}
