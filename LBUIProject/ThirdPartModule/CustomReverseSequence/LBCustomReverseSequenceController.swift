//
//  LBCustomReverseSequenceController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/12/7.
//

import UIKit
import BLTSwiftUIKit

class LBCustomReverseSequenceController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        testCustomReverseList()
        testSystemReverseList()
    }
    

    func testCustomReverseList() {
        let list = ["11", "22", "33", "44"]
        let reverseList = BLTReverseSequence.init(array: list)
        for (index, obj) in reverseList.enumerated() {
            print("LBLog index is \(index), obj is \(obj)")
        }
        
        for obj in reverseList {
            print("LBLog obj is \(obj)")
        }
    }
    
    
    func testSystemReverseList() {
        print("-----------------------------------------------------------------------")
        let list = ["11", "22", "33", "44"]
        let reverseList = list.reversed()
        for (index, obj) in reverseList.enumerated() {
            print("LBLog  222 index is \(index), obj is \(obj)")
        }
        
        for obj in reverseList {
            print("LBLog 222 obj is \(obj)")
        }
    }

}
