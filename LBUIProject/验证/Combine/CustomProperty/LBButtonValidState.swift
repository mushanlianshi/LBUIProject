//
//  LBButtonValidState.swift
//  LBUIProject
//
//  Created by liu bin on 2025/4/14.
//

import Foundation


enum LBButtonValidState {
    case ok(_ text: String)
    case empty(_ text: String)
}


struct LBCombinePropertyModel {
    var name = ""
    var age = 0
    var selected = false
}
