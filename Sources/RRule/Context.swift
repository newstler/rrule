//
//  Context.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

public class Context {
    var options: [String: Any]
    var dtstart: Date
    var tz: TimeZone
    var dayOfYearMask: [Bool]?
    var year: Int? = 1997
    
    var lastYear: Int?
    var lastMonth: Int?
    
    var leapYear: Bool {
        guard let year = self.year else { return false }
        return Calendar.current.isLeapYear(year: year)
    }
    
    lazy var yearLengthInDays: Int? = {
        return leapYear ? 366 : 365
    }()
    
    lazy var elapsedDaysInYearByMonth: [Int]? = {
        return leapYear ? [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366] : [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
    }()
    
    lazy var weekdaysInYear: [Int] = {
        return Array(repeating: 0...6, count: 54).flatMap { $0 }
    }()
    
    lazy var firstDayOfYear: Date? = {
        guard let year = self.year else { return nil }
        let components = DateComponents(year: self.year, month: 1, day: 1)
        return Calendar.current.date(from: components)
    }()
    
    lazy var firstWeekdayOfYear: Int? = {
        guard let firstDay = self.firstDayOfYear else { return nil }
        // Weekday component ranges from 1 (Sunday) to 7 (Saturday) in the Gregorian calendar
        return Calendar.current.component(.weekday, from: firstDay) - 1
    }()
    
    lazy var weekdayByDayOfYear: [Int]? = {
        guard let adjustment = self.firstWeekdayOfYear else { return nil }
        return Array(self.weekdaysInYear.dropFirst(adjustment))
    }()
    
    //MARK: Init

    init(options: [String: Any], dtstart: Date, tz: TimeZone) {
        self.options = options
        self.dtstart = dtstart
        self.tz = tz
    }
    
    private func resetYear() {
        self.yearLengthInDays = nil
        self.firstDayOfYear = nil
        self.firstWeekdayOfYear = nil
        self.weekdayByDayOfYear = nil
        self.elapsedDaysInYearByMonth = nil
    }
    
    func dayOfYearWithinRange(weekday: Weekday, yearDayStart: Int, yearDayEnd: Int) -> Int? {
        guard let weekdays = self.weekdayByDayOfYear else { return nil }
        
        let wday = weekday.index
        guard let ordinalWeekday = weekday.ordinal else { return nil }
        
        var dayOfYear: Int
        
        if ordinalWeekday < 0 {
            // For negative ordinals, start from the end
            dayOfYear = yearDayEnd + (ordinalWeekday + 1) * 7
            dayOfYear -= (weekdays[dayOfYear % weekdays.count] - wday) % 7
        } else {
            // For positive ordinals, start from the beginning
            dayOfYear = yearDayStart + (ordinalWeekday - 1) * 7
            dayOfYear += (7 - weekdays[dayOfYear % weekdays.count] + wday) % 7
        }

        if yearDayStart <= dayOfYear, dayOfYear <= yearDayEnd {
            return dayOfYear
        }
        
        return nil
    }
}

extension Calendar {
    func isLeapYear(year: Int) -> Bool {
        let dateComponents = DateComponents(year: year)
        if let date = self.date(from: dateComponents) {
            return self.isDateInLeapYear(date: date)
        }
        return false
    }
    
    func isDateInLeapYear(date: Date) -> Bool {
        return self.range(of: .day, in: .year, for: date)?.count == 366
    }
}
