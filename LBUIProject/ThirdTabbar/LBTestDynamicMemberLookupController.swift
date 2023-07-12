//
//  LBTestDynamicMemberLookupController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/24.
//

import UIKit
import RxCocoa
import RxSwift



@dynamicMemberLookup
///用Base 来动态转发对应的属性
struct LBDynamicMemberLookup<Base> {
    private let base: Base
    init(_ base: Base){
        self.base = base
    }
    
    ///ReferenceWritableKeyPath通过keypath的方式来获取值
    ///Property需要声明泛型Property来和ReferenceWritableKeyPath对应
    public subscript<Property>(dynamicMember path:ReferenceWritableKeyPath<Base, Property>) -> Property where Base: AnyObject{
        ///通过base的动态查找来转发
        let result = base[keyPath: path]
        return result
    }
}

class LBTestDynamicMemberStruct{
    var structName = "member look up struct"
}


///swift 动态查找
class LBTestDynamicMemberLookupController: UIViewController {
    
    let rxDisposeBag = DisposeBag()
    
    var titleObserver: PublishSubject<String> = PublishSubject.init()

    var controllerName = "member look up controller"
    
//    lazy var titleLab = UILabel.blt.initWithText(text: <#T##String?#>, font: <#T##UIFont#>, textColor: <#T##UIColor#>)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let controller = LBTestDynamicMemberLookupController()
        let controllerBase = LBDynamicMemberLookup.init(controller)
        
        let memStruct = LBTestDynamicMemberStruct()
        let memStructBase = LBDynamicMemberLookup(memStruct)
        
        print("LBLOg controllerBase.controllerName \(controllerBase.controllerName)")
        controller.controllerName = "change controller name"
        print("LBLOg controllerBase.controllerName \(controllerBase.controllerName)")
        
        print("LBLog memStructBase.structName \(memStructBase.structName)")
        memStruct.structName = "change struct name"
        print("LBLog memStructBase.structName \(memStructBase.structName)")
//        print("LBLog key path is \(self[keyPath: title])")
        
    }

}
