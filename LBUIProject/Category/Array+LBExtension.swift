//
//  Array+LBExtension.swift
//  LBUIProject
//
//  Created by liu bin on 2022/6/22.
//

import Foundation
import HandyJSON

//array 已经遵守Element泛型了
extension Array{
    var random: Element?{
        if self.count == 0{
            return nil
        }
        return self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
    func appendRandomDescription<U: CustomStringConvertible>(_ input: U) -> String{
        if let element = self.random{
            return "\(element) " + input.description
        }
        return "empty array"
    }
}
