//
//  BLTTimeFormatterUtil.swift
//  chugefang
//
//  Created by liu bin on 2023/8/18.
//  Copyright © 2023 baletu123. All rights reserved.
//

import Foundation


///格式化日期的工具
public struct BLTTimeFormatterUtil{
    
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
    public static func formatterTimeToTimeAgo(timeStamp: Double) -> String {
        
        let currentTime = Date().timeIntervalSince1970
        
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)
        
        let reduceTime : TimeInterval = currentTime - timeSta
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        //不满足上述条件---或者是未来日期-----直接返回日期
        let date = NSDate(timeIntervalSince1970: timeSta)
        let formatter = DateFormatter()
        formatter.dateFormat = .timeFormatterChineseYToS
        return formatter.string(from: date as Date)
    }
    
    
    ///格式化成几天几小时几分钟
    public static func formatterTimeToTotalTime(second: Int) -> String {
        if second < 60{
            return "1分钟"
        }
        
        let minutes = second / 60
        if minutes < 60{
            return "\(minutes)分钟"
        }
        
        let hours = minutes / 60
        if(hours < 24){
            return "\(hours)小时\(minutes%60)分钟"
        }
        
        let days = hours / 24
        return "\(days)天\(hours%24)小时"
    }
    
    //MARK: -时间戳转时间函数
    public static func timeStampToFormatterString(timeStamp: Double, formatterString: String = .timeFormatterYToS)->String {
        //时间戳为毫秒级要 ／ 1000， 秒就不用除1000，参数带没带000
        let timeSta:TimeInterval = TimeInterval(timeStamp / 1000)
        let date = NSDate(timeIntervalSince1970: timeSta)
        let formatter = DateFormatter()
        formatter.dateFormat = formatterString
        return formatter.string(from: date as Date)
    }
    
    //MARK: -时间转时间戳函数
    public static func formatterTimeToTimeStamp(time: String, formatterString: String) -> Double {
        let formatter = DateFormatter()
        formatter.dateFormat = formatterString
        let last = formatter.date(from: time)
        let timeStamp = last?.timeIntervalSince1970
        return timeStamp!
    }
}



extension String{
    ///年到秒的格式
    public static let timeFormatterYToS = "yyyy-MM-dd HH:mm:ss"
    ///中文的年到秒的格式
    public static let timeFormatterChineseYToS = "yyyy年MM月dd日 HH:mm:ss"
    ///年到天的格式
    public static let timeFormatterYToD = "yyyy-MM-dd"
    ///小时到秒的格式
    public static let timeFormatterHToS = "HH:mm:ss"
}
