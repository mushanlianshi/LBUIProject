//
//  LBSmartCodableReplaceHandyjsonController.swift
//  LBUIProject
//
//  Created by liu bin on 2026/7/1.
//

import Foundation
import HandyJSON
import SmartCodable

class LBHandyJsonBaseModel: HandyJSON{
    var name: String = ""
    required init() {}
}


class LBHandyJsonReplaceModel: HandyJSON {
    required init() {}
     var nickName: String = ""
     var userAge: Int = 0
     var ignoreField: String = ""
    
    var extra: [String: Any] = [:]
    var tags: [Any] = []
    var value: Any?
    var sex: Sex = .man
    /// mapping didFinishMapping等方法，如果是继承父类，父类遵守的HandyJSON协议，那就不会走子类的这些方法
    func mapping(mapper: HelpingMapper) {
         debugPrint("LBLog mapping called for \(self)")
         mapper <<< self.nickName <-- ["nick_name", "realName"]
         mapper <<< self.userAge <-- "user_age"
         mapper >>> self.ignoreField   // 忽略该字段
     }

    func didFinishMapping() {
         debugPrint("LBLog didFinishMapping called nickName=\(nickName) userAge=\(userAge) ignoreField=\(ignoreField)")
     }
    
    // HandyJSON
    enum Sex: String, HandyJSONEnum {
        case man
        case woman
    }
 }


// SmartCodable —— 子类加 @SmartSubclass
class LBSmartReplaceBaseModel: SmartCodableX {
    var name: String = ""
    required init() {}
    class func mappingForKey() -> [SmartKeyTransformer]? {
    return nil
    }
}


//@SmartSubclass
class LBSmartReplaceModel: SmartCodableX {
//    private enum CodingKeys: CodingKey {
//        case nickName
//        case userAge
//    }
    required init() {}
     var nickName: String = ""
     var userAge: Int = 0
     @SmartIgnored
     var ignoreField: String = ""
    var testDefaultValue = "defaultValue"
    
    /// 用 Any？ 可以同时接收 String 和 [String: Any]
    @SmartAny var extra: Any = [String: Any]()
    @SmartAny var tags: [Any] = []
    @SmartAny var value: Any?
    var sex: Sex = .man

    static func mappingForKey() -> [SmartKeyTransformer]? {
         [
             CodingKeys.nickName <--- ["nick_name", "realName"],
             CodingKeys.userAge <--- "user_age"
         ]
     }

    /// mappingForValue 可用于非 @SmartAny 属性的自定义值转换
    /// 示例：对某个 [String:Any] 属性做特殊处理 也可以放到didFinishMapping后面再处理，如示例
    static func mappingForValue() -> [SmartValueTransformer]?{
        [
            CodingKeys.extra <--- FastTransformer<[String : Any], Any>(fromJSON: { value in
                return value.toJSONObject() ?? [:]
            })
        ]
    }

    func didFinishMapping() {
        /// @SmartAny 属性的自定义转换无法通过 mappingForValue 实现  贿赂 受贿
        /// 因为 @SmartAny 走的是 SmartAnyImpl 路径，其  transformer 要求返回 SmartAnyImpl（internal 类型）
        /// 所以改用 didFinishMapping 做后处理, 也可以mappingForValue再这里提前处理解析方式
        if let string = extra as? String,
           let data = string.data(using: .utf8),
           let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            extra = dict
        }
    }
    
//    required init(from decoder: Decoder) throws {
//            try super.init(from: decoder)
//        }
//        
//         func encode(to encoder: Encoder) throws {
//            try super.encode(to: encoder)
//        }
    
    // SmartCodable
     enum Sex: String, SmartCaseDefaultable {
         case man
         case woman
     }
 }


/**
 * https://juejin.cn/post/7630721066899210275
 * Smart替代handyjson
 * 全局替换 import HandyJSON → import SmartCodable
 全局替换协议名 HandyJSON → SmartCodable（注意只替换作为协议使用的）
 改写所有 mapping(mapper:) → mappingForKey() + @SmartIgnored
 所有 Any / [Any] / [String: Any] 属性加 @SmartAny
 所有子类加 @SmartSubclass
 全局替换 HandyJSONEnum → SmartCaseDefaultable
 全局替换 .toJSON() → .toDictionary()（排除 toJSONString）
 数组序列化 .toJSON() → .toArray()
 移除 HandyJSON 依赖（Podfile / Package.swift）
 编译通过
 开启 SmartSentinel.debugMode = .verbose，跑主流程
 全量回归测试
 关闭 Sentinel（SmartSentinel.debugMode = .none）
 */
class LBSmartCodableReplaceHandyjsonController: UIViewController {
    lazy var textLab = UILabel.blt.initWithFont(font: .blt.normalFont(15), textColor: .blt.threeThreeBlackColor(), numberOfLines: 0)
    override func viewDidLoad() {
        super.viewDidLoad()
#if DEBUG
        SmartSentinel.debugMode = .verbose
#endif
        view.addSubview(textLab)
        textLab.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.centerY.equalTo(view)
        }
        textLab.text = "具体替换请查看上面模型替换，以及注释"
        
        let dic:[String : Any] = [
            "name" : "name刘彬",
            "nick_name" : "nickName刘xxxx",
            "user_age" : 90,
            "ignoreField" : "ignoreField---------",
            "value" : "testValue",
            "sex" : "woman",
            "extra":"{\"key1\":\"value1\"}"
        ]
        let handModel = LBHandyJsonReplaceModel.deserialize(from: dic)
        let smartModel = LBSmartReplaceModel.deserialize(from: dic)
        let test: String? = nil
        debugPrint("LBLog handmodel \(String(describing: handModel?.nickName))")
        debugPrint("LBLog smartModel \(String(describing: smartModel?.nickName))")
        debugPrint("LBLog smartModel \(String(describing: test))")
    }
}
