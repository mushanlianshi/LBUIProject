//
//  LBIntToStringDecoder.swift
//  LBUIProject
//
//  Created by liu bin on 2025/2/5.
//

import Foundation

/// int类型转string字符串
@propertyWrapper
struct LBIntToStringOptional: Decodable {
    var wrappedValue: String?
    
//    enum CodingKeys: CodingKey {
//        case wrappedValue
//    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            wrappedValue = String(intValue)
        }else{
            wrappedValue = try? container.decode(String.self)
        }
    }
}


/// int类型转string字符串
@propertyWrapper
struct LBIntToStringDefaultValue: Decodable {
    
    var wrappedValue: String
//    
//    enum CodingKeys: CodingKey {
//        case wrappedValue
//    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            wrappedValue = String(intValue)
        }else{
            wrappedValue = try container.decode(String.self)
        }
    }
}
