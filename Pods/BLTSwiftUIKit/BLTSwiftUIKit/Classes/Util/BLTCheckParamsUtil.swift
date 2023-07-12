//
//  BLTCheckParamsUtil.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2023/2/24.
//

import Foundation
import BLTUIKitProject

///检测一些必传接口参数的， 检测到异常就弹框提示
///处理一些后台配置的组件化路由少了参数，测试人员测试发现跳转正常，就没有在看也没其他操作如提交、获取等需要调接口的是否正常
///如果是字符串类型 不能为nil 和""空字符串
///如果是Int类型  不能是nil   默认不能为0
///如果是bool类型  不能为nil
///ignoreZeroInt 0也认为是emptyValue
///checkSuperParams 是否检测父类的属性  默认false
///通过反射Mirror反射获取当前对象的属性
public class BLTCheckParamsUtil {
    
    public static func checkRequiredParams(_ nameList: [String], _ currentObj: Any, ignoreZeroInt: Bool = false, checkSuperParams: Bool = false, currentVC: UIViewController? = nil){
        
        
        func checkValueIsEmpty(_ value: Any) -> Bool{
            
            ///把Any类型的value 转成Optional  判断是不是nil  直接判断不出来
            if let nilValue = value as? Optional<Any>, nilValue == nil{
                return true
            }
            
            if let stringValue = value as? String, stringValue.isEmpty{
                return true
            }else if let intValue = value as? Int, (ignoreZeroInt == false && intValue == 0){
                return true
            }
            return false
        }
        
        ///检测到emptyValue  就添加到keyList中
        func addEmptyValueIFNeeded(mirror: Mirror, emptyList: inout [String]){
            ///判断当前类的属性是否有空
            for child in mirror.children {
                let value = child.value
                BLTLogUtil.debug("LBLog key is \(String(describing: child.label)) value is \(child.value) \(String(describing: mirror.displayStyle))")
                if let key = child.label, nameList.contains(key), checkValueIsEmpty(value) {
                    emptyList.append(key)
                }
            }
        }
        
        let mirror = Mirror.init(reflecting: currentObj)
        
        var emptyParamList = [String]()
        addEmptyValueIFNeeded(mirror: mirror, emptyList: &emptyParamList)
        
        ///判断要校验的属性是不是父类的属性
        if checkSuperParams{
            var superMirror = mirror.superclassMirror
            while superMirror != nil {
                BLTLogUtil.debug("LBLog super mirror is \(String(describing: superMirror))")
                addEmptyValueIFNeeded(mirror: superMirror!, emptyList: &emptyParamList)
                superMirror = superMirror?.superclassMirror
            }
        }
        
        guard emptyParamList.isEmpty == false else { return }
        
        alertEmptyParamList(nameList: emptyParamList, currentVC: currentVC)
    }
    
    
    private static func alertEmptyParamList(nameList: [String], currentVC: UIViewController? = nil){
        var tmpVC = currentVC
        if tmpVC == nil {
            tmpVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        guard let tmpVC = tmpVC else {
            return
        }
        let content = "必传参数：" + nameList.joined(separator: "、") + "不能为空" + "\n" + "请找开发确认原因"
        guard let alertVC = BLTAlertController.init(title: "错误提示", mesage: content, style: .alert, sureTitle: "这就去", sureBlock: nil) else {
            return
        }
        tmpVC.present(alertVC, animated: true, completion: nil)
    }

    
}



