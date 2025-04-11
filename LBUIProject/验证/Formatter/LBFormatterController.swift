//
//  LBFormatterController.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/4/7.
//

import Foundation

// 格式化的
class LBFormatterController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testFormatter()
        testFormatterDigitalNumber()
        testNumberFormatter()
    }
    
    func testFormatter() {
        let list1 = ListFormatter.localizedString(byJoining: ["冬天","春天","夏天","秋天"]) // 冬天, 春天, 夏天, and 秋天
        print("LBLog list1  \(list1)")
        let bookGenres = ["小说", "历史", "科学"]
        if #available(iOS 15.0, *) {
            print("LBLog \(bookGenres.formatted())") // 小说, 历史, and 科学
            print("LBLog \(bookGenres.formatted(.list(type: .or)))") // 小说, 历史, or 科学
        } else {
            // Fallback on earlier versions
        }                 // 小说, 历史和科学
        
    }
    
    
    func testFormatterDigitalNumber() {
        if #available(iOS 15.0, *) {
            print(888.formatted(.currency(code: "RMB"))) // RMB 888.00
            print(9999.formatted()) // 9,999
            print(0.3.formatted(.percent)) // 30%
            print(3.14.formatted(.number.precision(.fractionLength(1)))) // 3.1
            
            let storageSize = 500000000 // 500 MB
            print(storageSize.formatted(.byteCount(style: .memory)))  // 477.0 MB
            print(storageSize.formatted(.byteCount(style: .decimal))) // 500 MB
            print(storageSize.formatted(.byteCount(style: .memory,
                                                   allowedUnits: .all, spellsOutZero: true,
                                                   includesActualByteCount: true))) // 476.8 MB (500,000,000 bytes)
        } else {
            // Fallback on earlier versions
        }
    }
    
    func testNumberFormatter()  {
        // 数字
        let f3 = NumberFormatter()
        f3.locale = Locale(identifier: "zh_Hans_CN")
        f3.numberStyle = .currency
        print(f3.string(from: 123456) ?? "") // ¥123,456.00
        f3.numberStyle = .percent
        print(f3.string(from: 123456) ?? "") // 12,345,600%
    }
    
    
}


