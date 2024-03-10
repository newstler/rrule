//
//  Extentions.swift
//  
//
//  Created by Yuri Sidorov on 08.03.2024.
//

import Foundation

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

extension Date {
    func endOfYear(using calendar: Calendar) -> Date? {
        guard let year = calendar.dateComponents([.year], from: self).year else { return nil }
        let components = DateComponents(year: year + 1, second: -1)
        guard let endOfYear = calendar.date(from: components) else { return nil }
        
        return calendar.date(byAdding: .day, value: 7, to: endOfYear)
    }
    
    func endOfMonth(using calendar: Calendar = .current) -> Date? {
        var components = calendar.dateComponents([.year, .month], from: self)
        components.month! += 1
        components.day = 0
        return calendar.date(from: components)
    }
    
    /// Floors the date to the start of its second in the specified timezone.
    func floorToSeconds(in timezone: TimeZone) -> Date {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        return calendar.date(from: components) ?? self
    }
}

