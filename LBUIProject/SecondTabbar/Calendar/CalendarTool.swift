//
//  CalendarTool.swift
//  SYCalendarDemo
//
//  Created by song on 2025/4/25.
//

import UIKit

//（sunday = 1，monday = 2，...）
enum Weekday: Int {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
}

class CalendarModel {
    init(date: Date, type: Int = 0) {
        self.date = date
        self.type = type
    }
    
    // pre: -1; current: 0; next: 1
    let type: Int
    // date
    let date: Date
    // yyyy-MM-dd
    lazy var dateString: String = CalendarTool.dateFormatter.string(from: date)
    
    lazy var dateComponents = CalendarTool.calendar.dateComponents([.year,.month,.day], from: date)
    // yyyy
    lazy var year = dateComponents.year!
    // MM
    lazy var month = dateComponents.month!
    // dd
    lazy var day = dateComponents.day!
    
    lazy var chineseDateString: String = CalendarTool.chineseDateFormatter.string(from: date)
    
    lazy var chineseDateComponents = CalendarTool.chineseCalendar.dateComponents([.year,.month,.day], from: date)
    
    lazy var chineseMonth = {
        if let isLeapMonth = chineseDateComponents.isLeapMonth, isLeapMonth {
            return "闰\(CalendarTool.chineseMonths[chineseDateComponents.month! - 1])"
        }
        return CalendarTool.chineseMonths[chineseDateComponents.month! - 1]
    }()
    
    lazy var chineseDay = {
        let months = chineseDateComponents.month!
        let days = chineseDateComponents.day!
        let daysStr = CalendarTool.chineseDays[days - 1]
        return daysStr
    }()
}

class CalendarTool {
    /// init
    /// - Parameters:
    ///   - startString: start date string yyyy-MM-dd
    ///   - startWeek: default:  sunday
    init(start: String, startWeek: Weekday = .sunday) {
        self.startString = start
        self.startWeek = startWeek.rawValue
        print("LBLog start \(start) \(startWeek.rawValue)")
    }
    
    func getDaysInMonthArr() -> [CalendarModel] {
        /// startDate是这个月开始的第一天   endDate下个月的第一天 注意日历的时区
        guard let startDate = dateFormatter.date(from: startString),
              let endDate = calendar.date(byAdding:.month, value: 1, to: startDate) else {
            return []
        }
        
        var dateArray: [CalendarModel] = []
        
        print("LBLog startDate  \(startDate)  endDate  \(endDate)")
        
        /// 从上个月底开始
        var currentDate = startDate;
        
        {
            var arr: [CalendarModel] = []
            var week = calendar.dateComponents([.weekday], from: currentDate).weekday
            /// 如果不是开始的星期， 减一天，一直到是开始的星期
            print("LBLog start date weekday is \(week)")
            while week != startWeek {
                currentDate = calendar.date(byAdding:.day, value: -1, to: currentDate)!
                let preModel = CalendarModel(date: currentDate, type: -1)
                print("LBLog preModel is \(preModel.dateString)")
                arr.append(preModel)
                week = calendar.dateComponents([.weekday], from: currentDate).weekday
            }
            /// 如果有 -1 -2 -3天添加进来的 ， 数组反转一下
            dateArray = Array(arr.reversed())
        }()
        
        
        /// 2.添加这个月的日期进来 endDate是下个月的第一天，小于下个月的第一天都是这个月的
        currentDate = startDate
        while currentDate < endDate {
            dateArray.append(CalendarModel(date: currentDate))
            currentDate = calendar.date(byAdding:.day, value: 1, to: currentDate)!
        }
        
        {
            var week = calendar.dateComponents([.weekday], from: currentDate).weekday
            print("LBLog 当月结束的日期是星期 \(week)")
            /// 当前时间的星期不是开始的星期，添加补齐
            while week != startWeek {
                let afterModel = CalendarModel(date: currentDate, type: 1)
                print("LBLog afterModel is \(afterModel.dateString)")
                dateArray.append(afterModel)
                currentDate = calendar.date(byAdding:.day, value: 1, to: currentDate)!
                week = calendar.dateComponents([.weekday], from: currentDate).weekday
            }
        }()
        return dateArray
    }
    
    private var dateFormatter: DateFormatter { CalendarTool.dateFormatter }
    
    private var chineseDateFormatter: DateFormatter { CalendarTool.chineseDateFormatter }
    
    private var calendar: Calendar { CalendarTool.calendar }
    
    private  let startWeek: Int
    
    private let startString: String
    
    static let dateFormatter = {
        // Lock down the East Eighth Time Zone and 24 - hour format; modify it yourself if needed.
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = CalendarTool.calendar
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    static let chineseDateFormatter = {
        // Lock down the East Eighth Time Zone and 24 - hour format; modify it yourself if needed.
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = CalendarTool.chineseCalendar
        dateFormatter.locale = Locale(identifier: "zh_CN")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()
    
    static let calendar = Calendar(identifier:.iso8601)
    
    static let chineseCalendar = Calendar(identifier:.chinese)
    
    static let chineseMonths = ["正月", "二月", "三月", "四月", "五月", "六月", "七月", "八月", "九月", "十月", "冬月", "腊月"]
    
    static let chineseDays = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十", "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十", "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
}

