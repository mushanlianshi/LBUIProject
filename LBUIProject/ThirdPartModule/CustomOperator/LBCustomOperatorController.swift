//
//  LBCustomOperatorController.swift
//  LBUIProject
//
//  Created by liu bin on 2022/12/7.
//

import UIKit

class LBCustomOperatorController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let v1 = LBCustomVector.init(x: 1, y: 1)
        let v2 = LBCustomVector.init(x: 2, y: 2)
        let v3 = v1 + v2
        print("LBLog v3 is \(v3)")
    }

}


///自定义操作符
struct LBCustomVector {
    var x = 0
    var y = 0
    
    static func +(_ left: LBCustomVector, _ right: LBCustomVector) -> LBCustomVector {
        return LBCustomVector.init(x: left.x + right.x, y: left.y + right.y)
    }
    
}

