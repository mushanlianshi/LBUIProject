//
//  LBTestStructAndClassController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/3.
//

import UIKit

private var extensionNameKey: Void?
private var classExtensionNameKey: Void?


enum LBMutiEnum{
    case age(ageOfPeople: Int)
    case name(name: String)
    case student
    case teach
}

struct LBTestStruct {
    var age = 0
    var name = ""
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for index in 1...10 {
            let struct1 = LBTestStruct.init(age: index, name: "name \(index)")
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
        
        
        var tmpStruct = LBTestStruct.init(age: 111, name: "name 111")
        tmpStruct.age = 222
        print("LBLog tmpStruct age is \(tmpStruct.age)")
        
        var tmps = tmpStruct
        tmpStruct.age = 555
        print("LBLog tmpStruct age is \(tmpStruct.age)")
    }

}
