//
//  LLPropertyWrapperViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/8/8.
//

import UIKit

@propertyWrapper
public struct LBMaxNumberWrapper{
    private let maxValue: Int
    ///最大
    public var wrappedValue: Int{
        didSet{
            wrappedValue = min(wrappedValue, self.maxValue)
        }
    }
    
    public init(wrappedValue: Int = 0, maxValue: Int){
        self.maxValue = maxValue
        self.wrappedValue = wrappedValue
    }
}

fileprivate struct LBNormalStruct{
    let height: Int
    let width: Int
}


fileprivate struct LBWrapperStruct{
    @LBMaxNumberWrapper(wrappedValue: 0, maxValue: 50)
    var height: Int
    @LBMaxNumberWrapper(wrappedValue: 0, maxValue: 50)
    var width: Int
}





///属性包装器  就是封装相同代码
///对property的值添加约束性代码，比如检测赋值是否在某个区间
///对property的读写访问添加存储操作 比如存userDefault
///对property的读写访问添加其他业务逻辑代码，比如打印日志
class LLPropertyWrapperViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "属性包装器"
        view.backgroundColor = .white
        
        let struct1 = LBNormalStruct(height: 20, width: 20)
        var struct2 = LBWrapperStruct()
        
        struct2.width = 100
        struct2.height = 20
        dump(struct1)
        dump(struct2)
        print("LBLog struct \(struct1.width) \(struct1.height)")
        print("LBLog struct2 \(struct2.width) \(struct2.height)")
    }

}



