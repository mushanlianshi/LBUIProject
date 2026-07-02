//
//  TestSwift.swift
//  LBUIProject
//
//  Created by liu bin on 2021/6/24.
//

import Foundation
import HandyJSON
import Combine

protocol LBTestProtocol {
    
}

func testHandjsonConvert(){
    
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
    debugPrint("LBLog testmodel \(testModel?.toJSON())")
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




protocol LBTestProtocolT: Sendable{
    associatedtype ModelType
    func decodeModel(_ dic: [String: Any]) -> ModelType?
    
    /// 文件对应的数据模型类型
        associatedtype Model: Sendable
    /// 获取操作的数据转换方法：从文件模型转换为目标类型
        typealias FetchTransform<To: Sendable> = @Sendable (_ model: Model) async throws -> To
        
        /// 保存操作的数据转换方法：从目标类型转换为文件模型
        typealias SaveTransform<To: Sendable> = @Sendable (_ model: To) async throws -> Model
}


extension LBTestProtocolT where ModelType: HandyJSON{
    func decodeModel(_ dic: [String: Any]) -> ModelType?{
        return ModelType.deserialize(from:dic)
    }
    
    /// 基于当前文件定义一个新的映射关系（转换模型类型）
        func map<To: Sendable>(
            fetch: @escaping FetchTransform<To>,
            save: @escaping SaveTransform<To>
        ) {
            
        }
}
