//
//  TestSwift.swift
//  LBUIProject
//
//  Created by liu bin on 2021/6/24.
//

import Foundation
import HandyJSON

protocol LBTestProtocol {
    
}

class LBHandyJsonModel: NSObject, HandyJSON{
    convenience init(obj: LBTestProtocol) {
        self.init()
        print("LBLog obj is \(obj)")
    }
    var title: String = ""
    var number = 0
    var list: [LBHandyJsonItemModel]?
    
    required override init() {
        
    }
    
    @objc func testConvert(){
        
        func dic() -> [String: Any]{
            return[
                "tit" : "2班",
                "num" : "10",
                "list" : [
                    [
                        "name" : "student 1",
                        "age" : "21"
                    ],
                    [
                        "name" : "student 2",
                        "age" : "12"
                    ],
                    [
                        "name" : "student 3",
                        "age" : "25"
                    ],
                    [
                        "name" : "student 4",
                        "age" : "21"
                    ],
                ]
            ]
        }
        let di = dic()
        let testModel = LBHandyJsonModel.deserialize(from: di)
        print("LBLog testModel \(testModel)")
    }
    
    
    func willStartMapping() {
        print("LBlog willStartMapping")
    }
    
    func mapping(mapper: HelpingMapper) {
        print("LBlog HelpingMapper")
        mapper <<<
            self.number <-- "num"
        mapper <<<
            self.title <-- ["tit"]
    }
    
    
    
    func didFinishMapping() {
        print("LBlog didFinishMapping")
    }
    
}

struct LBHandyJsonItemModel: HandyJSON{
    var name = ""
    var age = 0
}
