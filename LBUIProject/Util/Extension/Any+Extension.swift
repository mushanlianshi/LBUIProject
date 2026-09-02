//
//  Any+Extension.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/2.
//

import Foundation

import Foundation
/// 拓展Any?
extension Optional where Wrapped == Any {
    func toJSONObject() -> [String: Any]? {
        guard let value = self else { return nil }
        if let dict = value as? [String: Any] {
            return dict
        }
        if let str = value as? String,
           let data = str.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data) {
            return obj as? [String: Any]
        }
        if let data = value as? Data,
           let obj = try? JSONSerialization.jsonObject(with: data) {
            return obj as? [String: Any]
        }
        return nil
    }
}
