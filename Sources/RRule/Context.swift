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
    var year: Int?
    
    var lastYear: Int?
    var lastMonth: Int?
    

    
    private var _yearLengthInDays: Int?
    var yearLengthInDays: Int? {
        if let cachedValue = _yearLengthInDays {
            return cachedValue
        }
        _yearLengthInDays = leapYear ? 366 : 365
        return _yearLengthInDays
    }
    
    private var _nextYearLengthInDays: Int?
    var nextYearLengthInDays: Int? {
        if let cachedValue = _nextYearLengthInDays {
            return cachedValue
        }
        
        guard let year = self.year else { return nil }
        // Check if next year is a leap year and cache the result
        let isNextYearLeap = Calendar.current.isLeapYear(year: year + 1)
        let days = isNextYearLeap ? 366 : 365
        _nextYearLengthInDays = days
        return days
    }
    
    private var _firstDayOfYear: Date?
    var firstDayOfYear: Date? {
        if let cachedValue = _firstDayOfYear {
            return cachedValue
        }
        guard let year = self.year else { return nil }
        let components = DateComponents(year: year, month: 1, day: 1)
        let value = Calendar.current.date(from: components)
        _firstDayOfYear = value
        return value
    }

    private var _firstWeekdayOfYear: Int?
    var firstWeekdayOfYear: Int? {
        if let cachedValue = _firstWeekdayOfYear {
            return cachedValue
        }
        guard let firstDay = self.firstDayOfYear else { return nil }
        let value = Calendar.current.component(.weekday, from: firstDay) - 1
        _firstWeekdayOfYear = value
        return value
    }
    
    private var _monthByDayOfYear: [Int]?
    var monthByDayOfYear: [Int]? {
        if let cachedValue = _monthByDayOfYear {
            return cachedValue
        }
        guard let start = self.daysInYear?.start,
              let end = self.daysInYear?.end else { return nil }
        
        var current = start
        let calendar = Calendar.current
        var months = [Int]()
        
        while current <= end {
            months.append(calendar.component(.month, from: current))
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDay
        }
        
        // Cache the computed months before returning
        _monthByDayOfYear = months
        return months
    }
    
    private var _monthDayByDayOfYear: [Int]?
    var monthDayByDayOfYear: [Int]? {
        if let cachedValue = _monthDayByDayOfYear {
            return cachedValue
        }
        
        guard let start = self.daysInYear?.start,
              let end = self.daysInYear?.end else { return nil }
        
        var current = start
        let calendar = Calendar.current
        var monthDays = [Int]()
        
        while current <= end {
            let dayOfMonth = calendar.component(.day, from: current)
            monthDays.append(dayOfMonth)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDay
        }
        
        _monthDayByDayOfYear = monthDays
        return monthDays
    }
    
    private var _negativeMonthDayByDayOfYear: [Int]?
    var negativeMonthDayByDayOfYear: [Int]? {
        if let cachedValue = _negativeMonthDayByDayOfYear {
            return cachedValue
        }

        guard let start = self.daysInYear?.start,
              let end = self.daysInYear?.end else { return nil }
        
        var current = start
        let calendar = Calendar.current
        var results = [Int]()

        while current <= end {
            guard let endOfMonth = current.endOfMonth(using: calendar) else { break }
            let dayOfMonth = calendar.component(.day, from: current)
            let lastDayOfMonth = calendar.component(.day, from: endOfMonth)
            let result = dayOfMonth - lastDayOfMonth - 1
            results.append(result)
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDay
        }

        _negativeMonthDayByDayOfYear = results
        return results
    }
    
    private var _weekdayByDayOfYear: [Int]?
    var weekdayByDayOfYear: [Int]? {
        if let cachedValue = _weekdayByDayOfYear {
            return cachedValue
        }
        guard let adjustment = self.firstWeekdayOfYear else { return nil }
        let value = Array(self.weekdaysInYear.dropFirst(adjustment))
        _weekdayByDayOfYear = value
        return value
    }
    
    private var _weekNumberByDayOfYear: [Int]?
    var weekNumberByDayOfYear: [Int]? {
        if let cachedValue = _weekNumberByDayOfYear {
            return cachedValue
        }

        guard let start = self.daysInYear?.start,
              let end = self.daysInYear?.end else { return nil }
        
        var current = start
        let calendar = Calendar.current
        var weekNumbers = [Int]()

        while current <= end {
            let weekOfYear = calendar.component(.weekOfYear, from: current)
            weekNumbers.append(weekOfYear)
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDay
        }

        _weekNumberByDayOfYear = weekNumbers
        return weekNumbers
    }
    
    private var _negativeWeekNumberByDayOfYear: [Int]?
    var negativeWeekNumberByDayOfYear: [Int]? {
        if let cachedValue = _negativeWeekNumberByDayOfYear {
            return cachedValue
        }

        guard let start = self.daysInYear?.start,
              let end = self.daysInYear?.end else { return nil }

        var current = start
        let calendar = Calendar.current
        var negativeWeekNumbers = [Int]()

        // Get the ISO week number for December 28th of the current year, which is in the last ISO week of the year.
        guard let dec28 = calendar.date(from: DateComponents(year: self.year, month: 12, day: 28)),
              let lastWeekNumberOfYear = calendar.dateComponents([.weekOfYear], from: dec28).weekOfYear else {
            return nil
        }

        while current <= end {
            guard let weekOfYear = calendar.dateComponents([.weekOfYear], from: current).weekOfYear else { break }
            let negativeWeekNumber = weekOfYear - lastWeekNumberOfYear - 1
            negativeWeekNumbers.append(negativeWeekNumber)

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: current) else { break }
            current = nextDay
        }

        _negativeWeekNumberByDayOfYear = negativeWeekNumbers
        return negativeWeekNumbers
    }

    private var _elapsedDaysInYearByMonth: [Int]?
    var elapsedDaysInYearByMonth: [Int]? {
        if let cachedValue = _elapsedDaysInYearByMonth {
            return cachedValue
        }
        _elapsedDaysInYearByMonth = leapYear
        ? [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]
        : [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
        return _elapsedDaysInYearByMonth
    }
    
    //MARK: private

    lazy var weekdaysInYear: [Int] = {
        return Array(repeating: 0...6, count: 54).flatMap { $0 }
    }()
    
    var leapYear: Bool {
        guard let year = self.year else { return false }
        return Calendar.current.isLeapYear(year: year)
    }
    
    private func resetYear() {
        _daysInYear = nil
        _yearLengthInDays = nil
        _nextYearLengthInDays = nil
        _firstDayOfYear = nil
        _firstWeekdayOfYear = nil
        _monthByDayOfYear = nil
        _monthDayByDayOfYear = nil
        _negativeMonthDayByDayOfYear = nil
        _weekdayByDayOfYear = nil
        _weekNumberByDayOfYear = nil
        _negativeWeekNumberByDayOfYear = nil
        _elapsedDaysInYearByMonth = nil
    }
    
    private var _daysInYear: (start: Date, end: Date)?
    var daysInYear: (start: Date, end: Date)? {
        if let cachedValue = _daysInYear {
            return cachedValue
        }
        guard let firstDayOfYear = self.firstDayOfYear,
              let endOfYearPlus7Days = firstDayOfYear.endOfYear(using: Calendar.current) else {
            return nil
        }
        _daysInYear = (firstDayOfYear, endOfYearPlus7Days)
        return _daysInYear
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
    
    //MARK: Init

    init(options: [String: Any], dtstart: Date, tz: TimeZone) {
        self.options = options
        self.dtstart = dtstart
        self.tz = tz
    }
    
    func rebuild(year: Int, month: Int) {
        self.year = year
        
        if year != lastYear {
            resetYear()
        }
        
        guard let options = options["bynweekday"] as? [Weekday], !options.isEmpty,
              month != lastMonth || year != lastYear else {
            return
        }
        
        var possibleDateRanges: [[Int]] = []
        
        if let freq = self.options["freq"] as? String {
            switch freq {
            case "YEARLY":
                if let bymonth = self.options["bymonth"] as? [Int] {
                    possibleDateRanges = bymonth.compactMap { mon in
                        guard let range = elapsedDaysInYearByMonth, mon > 0, mon < range.count else { return nil }
                        return [range[mon - 1], range[mon]]
                    }
                } else {
                    if let yearLength = yearLengthInDays {
                        possibleDateRanges = [[0, yearLength]]
                    }
                }
            case "MONTHLY":
                if let range = elapsedDaysInYearByMonth, month > 0, month <= range.count - 1 {
                    possibleDateRanges = [[range[month - 1], range[month]]]
                }
            default: break
            }
        }
        
        if !possibleDateRanges.isEmpty {
            self.dayOfYearMask = Array(repeating: false, count: yearLengthInDays ?? 365)
            
            for possibleDateRange in possibleDateRanges {
                let yearDayStart = possibleDateRange[0]
                let yearDayEnd = possibleDateRange[1] - 1
                
                for weekdayOption in options {
                    if let dayOfYear = dayOfYearWithinRange(weekday: weekdayOption, yearDayStart: yearDayStart, yearDayEnd: yearDayEnd) {
                        dayOfYearMask?[dayOfYear] = true
                    }
                }
            }
        }
        
        self.lastYear = year
        self.lastMonth = month
    }
}
