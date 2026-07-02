//
//  LBButtonValidState.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/14.
//

import Foundation


enum LBButtonValidState {
    case ok(_ text: String, _ color: UIColor? = nil)
    case empty(_ text: String, _ color: UIColor? = nil)
}


struct LBCombinePropertyModel {
    var name = ""
    var age = 0
    var selected = false
}
