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
        var components = DateComponents(year: year + 1, second: -1)
        guard let endOfYear = calendar.date(from: components) else { return nil }
        
        return calendar.date(byAdding: .day, value: 7, to: endOfYear)
    }
}

