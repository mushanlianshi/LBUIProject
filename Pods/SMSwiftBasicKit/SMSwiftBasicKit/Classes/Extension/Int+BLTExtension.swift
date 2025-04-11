//
//  File.swift
//  MobileHotel
//
//  Created by liu bin on 2024/12/18.
//  Copyright © 2024 ethank. All rights reserved.
//

import Foundation


extension Int: BLTNameSpaceCompatibleValue{
    
}
public extension BLTNameSpace where Base == Int{
    func toString() -> String {
        return "\(self.base)"
    }
}
