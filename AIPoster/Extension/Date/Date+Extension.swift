//
//  Date+Extension.swift
//  HSTranslation
//
//  Created by 李昆明 on 2022/8/9.
//

import Foundation

// MARK: - Constants
extension Date {
    func toLocalTimeZone(_ timeZone: TimeZone?) -> Date {
        let timezone = timeZone ?? TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
}
extension Date {
    public enum Constant {
        static let daysOneWeek: Int = 7
        static let secondsOneMinute: Double = 60
        static let minutesOneHour: Double = 60
        static let hoursOneDay: Double = 24
        static let millisecondsOneSecond: Double = 1000
        static let secondsOnHour: Double = secondsOneMinute * minutesOneHour
        static let secondsOneDay: Double = secondsOneMinute * minutesOneHour * hoursOneDay
        static let millisecondsOneDay: Double = secondsOneDay * millisecondsOneSecond
    }
}

extension Date {
    // MARK: 24H前
    var tweentyHoursAgoDate: Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -1, to: Date())
    }
    // MARK: 一周前
    var weekAgoDate: Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -7, to: Date())
    }
    // MARK: 一个月前
    var monthAgoDate: Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .month, value: -1, to: Date())
    }
    // MARK: 一年前
    var yearAgoDate: Date? {
        let calendar = Calendar.current
        return calendar.date(byAdding: .year, value: -1, to: Date())
    }
    // MARK: 当日开始时间
    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
    }
    // MARK: 当日结束时间
    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
    // MARK: 当周开始时间
    var startOfWeek: Date {
        Calendar.current.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
    // MARK: 当周结束时间
    var endOfWeek: Date {
        var components = DateComponents()
        components.weekOfYear = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfWeek)!
    }
    // MARK: 当月开始时间
    var startOfMonth: Date {
        let components = Calendar.current.dateComponents([.year, .month], from: startOfDay)
        return Calendar.current.date(from: components)!
    }
    // MARK: 当月结束时间
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth)!
    }
    // MARK: 当年开始时间
    var startOfTheYear : Date {
        let components = Calendar.current.dateComponents([.year], from: startOfDay)
        return Calendar.current.date(from: components)!
    }
    // MARK: 当年结束时间
    var endOfTheYear: Date {
        var components = DateComponents()
        components.year = 1
        return Calendar.current.date(byAdding: components, to: startOfTheYear)!
    }
}


extension Date {
    
    // MARK: - Timestamp format string
    public func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}
        
        return localDate
    }
    
    public func localTomorraw() -> Date {
        let now = localDate()
        let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day + 1)
        return Calendar.current.date(from: tomorrow)!
    }

    public var secondTimestampIntValue: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return Int(timeInterval)
    }
    
    public var secondTimestampStringValue: String {
        return "\(secondTimestampIntValue)"
    }
    
    public var millisecondTimestampIntValue: Int {
        let timeInterval: TimeInterval = self.timeIntervalSince1970
        return Int(timeInterval * Constant.millisecondsOneSecond)
    }
    
    public var millisecondTimestampStringValue: String {
        return "\(millisecondTimestampIntValue)"
    }
    
    public func hourMinuteFormatString(from millsecondTimestamp: Int) -> String {
        return formatString(from: millsecondTimestamp, withFormat: "HH:mm")
    }
    
    public func yearMonthDayFormatString(from millsecondTimestamp: Int) -> String {
        return formatString(from: millsecondTimestamp, withFormat: "yyyy-MM-dd")
    }
    
    public func fullFormatString(from millsecondTimestamp: Int) -> String {
        return formatString(from: millsecondTimestamp, withFormat: "yyyy-MM-dd HH:mm:ss")
    }
    
    public func formatString(from millsecondTimestamp: Int, withFormat format: String) -> String {
        return DateFormatter(format: format).string(from: Date(timeIntervalSince1970: TimeInterval(Double(millsecondTimestamp) / Constant.millisecondsOneSecond)))
    }
    
    // MARK: - Format string
    
    public var agoFormatString: String {
        var ret: String = ""
        var distance = Double(Date().timeIntervalSince(self))
        
        if distance <= Constant.secondsOneMinute {
            ret = "刚刚"
        } else if distance < Constant.secondsOnHour {
            distance /= Constant.secondsOneMinute
            ret = "\(Int(distance))分钟前"
        } else if distance < Constant.secondsOneDay {
            distance = distance / (Constant.secondsOnHour)
            ret = "\(Int(distance))小时前"
        } else {
            return self.monthDayFormatString
        }
        return ret
    }
    
    public var yearFormatString: String {
        return DateFormatter.year.string(from: self)
    }
    
    public var fullPrettyFormatString: String {
        return DateFormatter.fullPretty.string(from: self)
    }
    
    public var yearMonthDayFormatString: String {
        return DateFormatter.yearMonthDay.string(from: self)
    }
    public var yearMonthDay1FormatString: String {
        return DateFormatter.yearMonthDay1.string(from: self)
    }
    
    public var monthDayFormatString: String {
        return DateFormatter.monthDay.string(from: self)
    }
    
    public var dayHourFormatString: String {
        return DateFormatter.dayHour.string(from: self)
    }
    
    public var hourMinuteFormatString: String {
        return DateFormatter.hourMinute.string(from: self)
    }
    
    public var hourMinuteSecondFormatString: String {
        return DateFormatter.hourMinuteSecond.string(from: self)
    }

    public var weekDayFormatString: String {
        return DateFormatter.weekDay.string(from: self)
    }
    
    public func formatString(with format: String) -> String {
        return DateFormatter(format: format).string(from: self)
    }
}


// MARK: - Components

extension Date {
    
    public static var gregorianCalendar: Calendar {
        var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "GMT")!
        return calendar
    }
    
    /// standard formatter
    public static var formatter: DateFormatter {
        let calendar = Date.gregorianCalendar
        let formatter = DateFormatter()
        formatter.calendar = calendar
        return formatter
    }
    
    public var era: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.era, from: self)
    }
    
    public var year: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.year, from: self)
    }
    
    public var month: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.month, from: self)
    }
    public var day: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.day, from: self)
    }
    
    public var weekday: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.weekday, from: self)
    }
    
    public var hour: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.hour, from: self)
    }
    
    public var minute: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.minute, from: self)
    }
    
    public var second: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.second, from: self)
    }
    
    public var weekdayOrdinal: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.weekdayOrdinal, from: self)
    }
    
    public var quarter: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.quarter, from: self)
    }
    
    public var weekOfMonth: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.weekOfMonth, from: self)
    }
    
    public var weekOfYear: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.weekOfYear, from: self)
    }
    
    public var yearForWeekOfYear: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.yearForWeekOfYear, from: self)
    }
    
    public var nanosecond: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.nanosecond, from: self)
    }
    
    public var calendar: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.calendar, from: self)
    }
    
    public var timeZone: Int {
        let calendar = Date.gregorianCalendar
        return calendar.component(.timeZone, from: self)
    }
}


// MARK: - Values

extension Date {

    /// First Date of the assigned month.
    ///
    /// - Returns: First date of month
    public func firstDateOfMonth() -> Date {
        let calendar = Date.gregorianCalendar
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.day = 1
        return calendar.date(from: components)!
    }

    /// First Date of the assigned month.
    ///
    /// - Returns: Last date of month
    public func lastDateOfMonth() -> Date {
        let calendar = Date.gregorianCalendar
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.month = components.month! + 1
        components.day = 0
        return calendar.date(from: components)!
    }

    public func previousMonthFirstDay() -> Date {
        let calendar = Date.gregorianCalendar
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.month = components.month! - 1
        components.day = 1
        return calendar.date(from: components)!
    }

    public func nextMonthFirstDay() -> Date {
        let calendar = Date.gregorianCalendar
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.month = components.month! + 1
        components.day = 1
        return calendar.date(from: components)!
    }
}

// MARK: - Compare

extension Date {
    
    public func isToday() -> Bool {
        return self.compare(to: Date(), granularity: .day) == .orderedSame
    }
    
    public func isWeekend() -> Bool {
        let calendar = Date.gregorianCalendar
        let weekdayRange = calendar.maximumRange(of: .weekday)
        let weekday = calendar.component(.weekday, from: self)
        
        if let range = weekdayRange {
            if weekday == range.lowerBound || weekday == range.count {
                return true
            }
        }
        return false
    }
    
    public var isPast: Bool {
        return isPast(referenceDate: Date())
    }
    
    public var isFuture: Bool {
        return !isPast
    }
    
    public func isPast(referenceDate: Date) -> Bool {
        return timeIntervalSince(referenceDate) <= 0
    }
    
    public func isFuture(referenceDate: Date) -> Bool {
        return !isPast(referenceDate: referenceDate)
    }
    
    public func isSameDay(_ date: Date) -> Bool {
        return self.compare(to: date, granularity: .day) == .orderedSame
    }
    
    public func isSameMonth(_ date: Date) -> Bool {
        return self.compare(to: date, granularity: .month) == .orderedSame
    }
    
    public func isSameYear(_ date: Date) -> Bool {
        return self.compare(to: date, granularity: .year) == .orderedSame
    }
    
    /// Greater than 比date晚
    public func gt(_ date: Date,  granularity: Calendar.Component) -> Bool {
        return self.compare(to: date, granularity: granularity) == .orderedDescending
    }
    
    /// Greater than or equal 比date晚或者等于
    public func ge(_ date: Date,  granularity: Calendar.Component) -> Bool {
        return self.compare(to: date, granularity: granularity) != .orderedAscending
    }
    
    /// Less than
    public func lt(_ date: Date,  granularity: Calendar.Component) -> Bool {
        return self.compare(to: date, granularity: granularity) == .orderedAscending
    }
    
    /// Less than or equal
    public func le(_ date: Date,  granularity: Calendar.Component) -> Bool {
        return self.compare(to: date, granularity: granularity) != .orderedDescending
    }
    
    /// Equal
    public func eq(_ date: Date,  granularity: Calendar.Component) -> Bool {
        return self.compare(to: date, granularity: granularity) == .orderedSame
    }
    
    /// Not equal
    public func ne(_ date: Date,  granularity: Calendar.Component) -> Bool {
        return self.compare(to: date, granularity: granularity) != .orderedSame
    }
    
    public func compare(to date: Date, granularity: Calendar.Component) -> ComparisonResult {
        let calendar = Date.gregorianCalendar
        return calendar.compare(self, to: date, toGranularity: granularity)
    }
}

