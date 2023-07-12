//
//  BLTLogUtil.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/1/3.
//

import Foundation

public func BLTSwiftLog(_ content: Any, isDebugPrint: Bool = false, file: String = #file, line: Int = #line, method: String = #function){
    BLTLogUtil.debug(content)
}

public struct BLTLogUtil {
    
    public enum LogLevel: Int{
        case verbose = 0
        case debug = 1
        case error = 2
        case none = 3
    }
    
    public static var debugMode: LogLevel = .debug
    
    public static func verbose(_ items: Any..., separator: String = "\n", terminator: String = "\n", needLineSeparator: Bool = false){
        if debugMode.rawValue <= LogLevel.verbose.rawValue {
            log(items, separator: separator, terminator: terminator, needLineSeparator: needLineSeparator)
        }
    }
    
    public static func debug(_ items: Any..., separator: String = "\n", terminator: String = "\n", needLineSeparator: Bool = false){
        if debugMode.rawValue <= LogLevel.debug.rawValue {
            log(items, separator: separator, terminator: terminator, needLineSeparator: needLineSeparator)
        }
    }
    
    public static func error(_ items: Any..., separator: String = "\n", terminator: String = "\n", needLineSeparator: Bool = false){
        if debugMode.rawValue <= LogLevel.error.rawValue {
            log(items, separator: separator, terminator: terminator, needLineSeparator: needLineSeparator)
        }
    }
    
    private static func log(_ items: Any..., separator: String = "\n", terminator: String = "\n", file: String = #file, line: Int = #line, method: String = #function, needLineSeparator: Bool = false){
#if DEBUG
        var value = (items.count <= 1) ? (items.first ?? "") : items
        if let list = value as? [Any] {
            value = (list.count <= 1) ? (list.first ?? "") : list
        }
    //LB DEBUG TEST
        if needLineSeparator{
            print("=========================== BLTSwiftUIKit log start ==========================")
        }
        print(value, separator: separator, terminator: terminator)
        if needLineSeparator {
            print("=========================== BLTSwiftUIKit log end   ==========================")
        }
#endif
    }
}
