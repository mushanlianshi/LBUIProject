//
//  LBStreamJsonParse.swift
//  LBUIProject
//
//  Created by liu bin on 2025/7/2.
//

import Foundation

class StreamFieldParser {
    private var buffer = ""
    private var isCapturing = false
    private var capturedValue = ""
    
    var thought: String?

    func feed(_ chunk: String) {
        buffer += chunk

        if !isCapturing {
            // 尝试找字段开始
            if let range = buffer.range(of: #""thought"\s*:\s*""#, options: .regularExpression) {
                isCapturing = true
                capturedValue = ""
                buffer = String(buffer[range.upperBound...]) // 移除前面的内容
            }
        }

        if isCapturing {
            // 继续拼接字符，直到遇到第一个未转义的 "
            var index = buffer.startIndex
            while index < buffer.endIndex {
                let char = buffer[index]
                if char == "\"" {
                    let prev = buffer.index(before: index)
                    if buffer[prev] != "\\" {
                        // 字段结束
                        thought = capturedValue
                        isCapturing = false
                        buffer = String(buffer[index...]) // 清理剩下的
                        return
                    }
                }
                capturedValue.append(char)
                index = buffer.index(after: index)
            }
            // 到这里说明没结束，保留 buffer 继续拼接
            buffer = ""
        }
    }
}

class StreamedJSONParser {
    private var buffer = ""

    var planTitle: String?
    var thought: String?
    var descriptions: [String] = []

    func feed(_ chunk: String) {
        buffer += chunk

        // 逐步提取 thought
        if thought == nil,
           let match = matchValue(forKey: "thought", in: buffer) {
            thought = match
        }

        // 提取 descriptions（可能多个）
        let newDescriptions = matchMultipleValues(forKey: "description", in: buffer)
        if newDescriptions.count > descriptions.count {
            descriptions = newDescriptions
        }

        // 同理可以提取 plan_title
        if planTitle == nil,
           let match = matchValue(forKey: "plan_title", in: buffer) {
            planTitle = match
        }
    }

    // 匹配单个字段值
    private func matchValue(forKey key: String, in text: String) -> String? {
        let pattern = #""\#(key)"\s*:\s*"((?:[^"\\]|\\.)*)""#
        return matchFirstCapture(pattern: pattern, in: text)
    }

    // 匹配多个字段值（数组）
    private func matchMultipleValues(forKey key: String, in text: String) -> [String] {
        let pattern = #""\#(key)"\s*:\s*"((?:[^"\\]|\\.)*)""#
        return matchAllCaptures(pattern: pattern, in: text)
    }

    private func matchFirstCapture(pattern: String, in text: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        if let match = regex.firstMatch(in: text, options: [], range: range),
           let range1 = Range(match.range(at: 1), in: text) {
            return text[range1].replacingOccurrences(of: #"\""#, with: "\"")
        }
        return nil
    }

    private func matchAllCaptures(pattern: String, in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }
        let range = NSRange(text.startIndex..., in: text)
        let matches = regex.matches(in: text, options: [], range: range)

        return matches.compactMap {
            guard let r = Range($0.range(at: 1), in: text) else { return nil }
            return text[r].replacingOccurrences(of: #"\""#, with: "\"")
        }
    }
}
