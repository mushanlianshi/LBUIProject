//
//  LBMoyaTargetTypeProtocol.swift
//  LBUIProject
//
//  Created by liu bin on 2023/5/25.
//

import Foundation
import Moya

enum LBPlatForm: Int {
    case iOS = 2
    case android = 3
}


///继承Moya 协议的TargetType    默认来实现一些公共的实现的  如BaseURL headers 公共参数等
///结构体是不支持runtime来关联属性的  因为是值类型  不是属性类型
public protocol LBMoyaTargetTypeProtocol: TargetType{
    
    ///此次请求需要的额外参数  需要具体实现
    var requestTotalExtraParams: [String : Any]? { get set }
    
}


extension LBMoyaTargetTypeProtocol{
    
    public var baseURL: URL{
        return URL(string: "http://192.168.60.174:3000")!
    }
    
    public var method: Moya.Method{
        return .post
    }
    
    public var headers: [String : String]?{
        return ["headerKey" : "headerValue"]
    }
    
    public var task: Task {
        return bltTask()
    }
    
    
    ///处理公共参数 比如token  平台iOS 安卓
    private func baseParams() -> [String : Any] {
        return ["paltfrom" : LBPlatForm.iOS.rawValue]
    }
    
    
    ///返回service的task 把公共参数和此次需要的参数 处理好
    public func bltTask(params: [String : Any]? = nil) -> Moya.Task {
        let totalParams = NSMutableDictionary.init(dictionary: baseParams())
        if let p = params{
            totalParams.addEntries(from: p)
        }
        if let p = requestTotalExtraParams{
            totalParams.addEntries(from: p)
        }
        return Moya.Task.requestParameters(parameters: totalParams as! [String : Any], encoding: URLEncoding.default)
    }
    
}



///listView 类型service的协议 增加 count  page 参数
//public protocol LBMoyaListViewTargetTypeProtocol: LBMoyaTargetTypeProtocol{
//
//    ///listView请求需要的page  count
//    var listPageTuple: (page: Int, count: Int)? { get set }
//    
//    var listExtraParams: [String: Any]? { get set }
//
//}
//
//public extension LBMoyaListViewTargetTypeProtocol{
//    
//    var requestTotalExtraParams: [String : Any]?{
//        get{
//            var totalParams = [String : Any]()
//            totalParams.blt.addEntries(from: listExtraParams)
//            if let pageTuple = listPageTuple{
//                totalParams["P"] = pageTuple.page
//                totalParams["S"] = pageTuple.count
//            }
//            
//            return totalParams
//        }
//        set{
//            
//        }
//    }
//}




/////使用类来实现LBMoyaListViewTargetTypeProtocol 的参数   避免每个子类都实现一遍listPageTuple和listExtraParams属性的  用类是为了继承  所以没有用struct enum（不能用存储属性，当然如果存储属性是RawValue也是可以的）
//public class LBMoyaListBaseService:NSObject, LBMoyaListViewTargetTypeProtocol {
//
//    ///需要的page  count参数
//    public var listPageTuple: (page: Int, count: Int)?
//    ///需要的额外参数  比如筛选等
//    public var listExtraParams: [String : Any]?
//
//}
//
//extension LBMoyaListBaseService{
//    public var path: String{
//        get { return "" }
//    }
//}
