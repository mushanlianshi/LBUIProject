//
//  LBTestSelfController.swift
//  LBSwift2024Demo
//
//  Created by liu bin on 2025/1/13.
//

import UIKit

protocol SomeProtocol {
    func doSomething()
}
extension SomeProtocol {
    func doSomething() {
        print(Self.self)
    }
}
class Base: SomeProtocol {
    func doAnotherThing() {
        print(Self.self)
    }
}
class SomeClass: Base {}

class LBTestSelfController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "测试self"
        //输出SomeClass doAnotherThing是类方法，类方法中的self指向实际运行的self
        (SomeClass() as Base).doAnotherThing()
        // Base   doSomething是协议方法 方法doSomething是协议扩展，它的类型是由调用端的静态类型决定的，也就是Base
        (SomeClass() as Base).doSomething()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
