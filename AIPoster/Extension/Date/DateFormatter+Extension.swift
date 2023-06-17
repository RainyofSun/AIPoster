//
//  DateFormatter+Extension.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/9.
//

import Foundation

extension DateFormatter {
    
    public convenience init(format: String) {
        self.init()
//        self.locale = Locale(identifier: "zh_CN")
        self.locale = Locale(identifier: "en_US")
        self.dateStyle = .medium
        self.dateFormat = format
    }
    
    // common
    static public let year = DateFormatter(format: "yyyy")
    static public let fullPretty = DateFormatter(format: "yyyy-MM-dd HH:mm:ss")
    static public let fullPretty1 = DateFormatter(format: "yyyy/MM/dd HH:mm:ss")
    static public let yearMonthDay = DateFormatter(format: "yyyy-MM-dd")
    static public let yearMonthDay1 = DateFormatter(format: "dd/MM/yyyy HH:mm")

    static public let monthDay = DateFormatter(format: "MM-dd")
    static public let dayHour = DateFormatter(format: "dd:HH")
    static public let hourMinute = DateFormatter(format: "HH:mm")
    static public let hourMinuteSecond = DateFormatter(format: "HH:mm:ss")
    // use "EEE" for Fri, use "MM" for 11, MMM for Nov, MMMM for November
    static public let weekDay = DateFormatter(format: "EEEE,MMM dd") // Thursday,Nov 11
    
    // zh
    static public let zhFullPretty = DateFormatter(format: "yyyy年MM月dd HH:mm:ss")
    static public let zhYearMonthDay = DateFormatter(format: "yyyy年MM年dd")
    static public let zhMonthDay = DateFormatter(format: "MM月dd日")
}
