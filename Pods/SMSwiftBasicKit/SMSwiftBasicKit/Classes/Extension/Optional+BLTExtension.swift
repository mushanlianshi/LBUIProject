//
//  Optional+BLTExtension.swift
//  MobileHotel
//
//  Created by liu bin on 2024/12/13.
//  Copyright © 2024 ethank. All rights reserved.
//

import Foundation
extension Optional: BLTNameSpaceCompatibleValue{
    
}
extension BLTNameSpace where Base == Optional<Any>{
    
}

extension Optional: Any{
    public var blt_isEmpty: Bool{
        if let string = self as? String{
            return string.isEmpty
        }else if let dic = self as? [AnyHashable : Any]{
            return dic.isEmpty
        }else if let array = self as? [Any]{
            return array.isEmpty
        }
        return self == nil
    }
    
    public var blt_isNotEmpty: Bool{
        return !self.blt_isEmpty
    }
}
