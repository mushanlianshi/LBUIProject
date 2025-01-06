//
//  LBTestStructAndClassController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/3.
//

import UIKit
import BLTSwiftUIKit
import RxSwift

private var extensionNameKey: Void?
private var classExtensionNameKey: Void?


enum LBMutiEnum{
    case age(ageOfPeople: Int)
    case name(name: String)
    case student
    case teach
}


///泛型枚举
//////Swift 4.2 中引入了一个新的语法@dynamicMemberLookup（动态成员查找）。使用@dynamicMemberLookup标记了目标（类、结构体、枚举、协议），实现subscript(dynamicMember member: String)方法后我们就可以访问到对象不存在的属性。
@dynamicMemberLookup
struct LBTestGenericStruct<T> {
    public let pProperty: T
    init(_ p: T){
        self.pProperty = p
    }
    
    func testFunc<LBProperty>(params: LBProperty) -> LBProperty {
        print("LBLog test func ===== \(params)")
        return params
    }
    /// ReferenceWritableKeyPath要求该参数必须是引用类型且可写的keypath。
    public subscript<Property>(dynamicMember keyPath: ReferenceWritableKeyPath<T, Property>) -> Binder<Property> where T: AnyObject{
        return Binder.init(self.pProperty) { base, value in
            base[keyPath: keyPath] = value
        }
    }
}

///Swift 4.2 中引入了一个新的语法@dynamicMemberLookup（动态成员查找）。使用@dynamicMemberLookup标记了目标（类、结构体、枚举、协议），实现subscript(dynamicMember member: String)方法后我们就可以访问到对象不存在的属性。
@dynamicMemberLookup
class LBTestDynamicMemberClass: NSObject{
    
    public subscript(dynamicMember keyPath: String) -> String{
        return "name"
    }
    
}

struct LBTestStruct {
    var age = 0
    var name = ""
    //    var sex: Int

    lazy var testStructLazy: String = "12313"
}



extension LBTestStruct{
    var extensionName: String?  {
        get{
            objc_getAssociatedObject(self, &extensionNameKey) as? String
        }
        
        set{
            objc_setAssociatedObject(self, &extensionNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}

class LBTestClass {
    var age = 0
    var name = ""
}

extension LBTestClass{
    var extensionName: String?  {
        get{
            objc_getAssociatedObject(self, &classExtensionNameKey) as? String
        }
        
        set{
            objc_setAssociatedObject(self, &classExtensionNameKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

/// struct 是值类型  所以复制的时候是复制   新赋值的变量struct的属性如果改变  不影响老的变量属性
/// 如果在数组中struct 如果struct被拿出来赋值  在改变新赋值变量的属性也是一样的   不影响原数组中的struct变量，但是如果我们不取出来复制  直接用索引的方式给struct属性赋值 是改变数组中的struct变量的属性的
/// 结构体extension不能通过associate添加属性，类可以  可以用计算属性来计算
class LBTestStructAndClassController: UIViewController {

    var structList = [LBTestStruct]()
    var classList = [LBTestClass]()
    
    lazy var tmpStruct = LBTestStruct.init(age: 111, name: "name 111")
    
    lazy var circleView: UIView = {
        let view = UIView()
//        circleView.backgroundColor = .red
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.circleView)
        self.circleView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)

        for index in 1...10 {
            var struct1 = LBTestStruct.init(age: index, name: "name \(index)")
            
            struct1.age = 21212
            
            let class1 = LBTestClass.init()
            class1.age = index
            class1.name = "name \(index)"
            structList.append(struct1)
            classList.append(class1)
        }
        
        print("LBLog structlist fisrt age name \(structList.first!.age) \(structList.first!.name)")
        print("LBLog classList fisrt age name \(classList.first!.age) \(classList.first!.name)")
//        print("LLBog \(&classExtensionNameKey)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            [weak self] in
            self?.structList[0].age = 100
            self?.structList[0].name = "name 100"
            self?.structList[0].extensionName = "extension name 100"
            self?.classList[0].age = 100
            self?.classList[0].name = "name 100"
            self?.classList[0].extensionName = "extension name 100"
            print("LBLog structlist 222 fisrt age name \(self?.structList.first!.age) \(self?.structList.first!.name) \(self?.structList.first!.extensionName)")
            print("LBLog classList  222 fisrt age name \(self?.classList.first!.age) \(self?.classList.first!.name) \(self?.classList.first!.extensionName)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                [weak self] in
                var struct1 = self?.structList[0]
                var class1 = self?.classList[0]
                
                struct1?.age = 300
                struct1?.name = "name 300"
                struct1?.extensionName = "extension name 300"
                class1?.age = 300
                class1?.name = "name 300"
                class1?.extensionName = "extension name 300"
                print("LBLog structlist 333 fisrt age name \(self?.structList.first!.age) \(self?.structList.first!.name) \(self?.structList.first!.extensionName)")
                print("LBLog classList  333 fisrt age name \(self?.classList.first!.age) \(self?.classList.first!.name) \(self?.classList.first!.extensionName)")
            }
        }
        
        
        
        tmpStruct.age = 222
        print("LBLog tmpStruct age is \(tmpStruct.age)")
        
        var tmps = tmpStruct
        print("LBLog tmps address \(getValueObjAddress(obj: &tmps))")
        tmps.age = 555
        print("LBLog tmps address 222 \(getValueObjAddress(obj: &tmps))")
        
        print("LBLog tmpStruct age is \(tmpStruct.age) \(tmps.age)")
        
        let button = UIButton()
        let tt = LBTestGenericStruct.init("123")
        let result = tt.testFunc(params: 123)
        print("LBLog result is \(result)")
        
        let dynamicClass = LBTestDynamicMemberClass()
        print("LBLog dynamic class is \(dynamicClass.name)")
        print("LBLog dynamic class is \(dynamicClass.haha)")
    }

}
