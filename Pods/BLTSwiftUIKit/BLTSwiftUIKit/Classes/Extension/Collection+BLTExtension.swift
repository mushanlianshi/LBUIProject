//
//  Array+BLTExtension.swift
//  BLTSwiftUIKit
//
//  Created by liu bin on 2022/1/17.
//

import Foundation

extension Collection{
    
    public var blt: Self{
        get{
            return self
        }
    }
    
    public func isNotEmpty() -> Bool{
        return !self.isEmpty
    }
}

