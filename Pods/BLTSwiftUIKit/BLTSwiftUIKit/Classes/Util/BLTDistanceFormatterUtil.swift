//
//  BLTDistanceFormatterUtil.swift
//  chugefang
//
//  Created by liu bin on 2023/8/18.
//  Copyright © 2023 baletu123. All rights reserved.
//

import Foundation

///格式化距离的
public struct BLTDistanceFormatterUtil {
    
    public enum BLTDistanceUnit{
        case Chinese
        case English
        case custom(meterUnit: String, kmUnit: String)
        
        var unitText: (meterUnit: String, kmUnit: String){
            switch self {
            case .Chinese:
                return ("米", "公里")
            case .English:
                return ("m", "km")
            case .custom(let meterUnit, let kmUnit):
                return (meterUnit, kmUnit)
            }
        }
    }
    
    
    ///格式化成xxx.xxkm
    public static func formatterToKM(_ meters: Int, unit: BLTDistanceUnit = .Chinese) -> String{
        let unit = unit.unitText
        guard meters >= 1000 else {
            return "\(meters)" + unit.meterUnit
        }
        let km = meters / 1000
        let m = meters % 1000
        if m == 0{
            return "\(km)" + unit.kmUnit
        }else{
            let totalKM = CGFloat(km) + CGFloat(m) / 1000
            ///百度地图就显示1.0km
            return String(format: "%.1f", totalKM) + unit.kmUnit
        }
    }
    
}
