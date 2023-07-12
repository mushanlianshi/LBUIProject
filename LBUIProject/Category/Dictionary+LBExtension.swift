//
//  Dictionary+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/26.
//

import Foundation
import BLTSwiftUIKit

extension BLTNameSpace where Base == Dictionary<String, Any>{
    mutating func addEntries(from otherDictionary: [String : Any]?) {
        otherDictionary?.forEach { (key: String, value: Any) in
//            self[key] = value
            base[key] = value
        }
    }
}
