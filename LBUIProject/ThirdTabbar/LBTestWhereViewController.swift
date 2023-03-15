//
//  LBTestWhereViewController.swift
//  LBUIProject
//
//  Created by liu bin on 2023/3/14.
//

import UIKit

class LBTestWhereViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        testCircleWhere()
        testCircleCondition()
        testNodeList()
    }
    
    
    ///where 用在for循环 case中
    private func testCircleWhere(){
        let nameList = ["王1", "张三", "李四","王2"]
        nameList.forEach {
            switch $0 {
            case let x where x.hasPrefix("王"):
                print("LBlog match  \(x) ")
            default:
                print("LBLog not match \($0)")
            }
        }
    }
    
    ///where 用在for循环条件中
    private func testCircleCondition(){
        let number = [10, 20, 80, 99, 55]
        for score in number where score > 60 {
            print("LBlog 及格了 \(score)")
        }
        
        number.forEach{
            if $0 > 60 {
                print("LBLog \(number) big then 60 ")
            }else{
                print("LBLog \(number) less then 60 ")
            }
        }
    }
    
    private func testSubview(){
        for case let button as UIButton in view.subviews {
            button.setTitle(nil, for: .normal)
        }
        for button in view.subviews where button is UIButton {
            
        }
    }
    
    
    ///单向列表
    private func testNodeList(){
        let node1 = Node.init(value: 1, next: nil)
        let node2 = Node.init(value: 2, next: node1)
        let node3 = Node.init(value: 3, next: node2)
        let node4 = Node.init(value: 4, next: node3)
        let list = node4
        while list.next != nil {
            print("LBLog  list value is \(String(describing: list.next?.value))")
            list.next = list.next?.next
        }
    }

}



///单向链表
class Node<T> {
    let value: T?
    var next: Node<T>?
    init(value: T?, next: Node<T>?){
        self.value = value
        self.next = next
    }
}
