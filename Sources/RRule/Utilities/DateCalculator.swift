//
//  DateCalculator.swift
//
//
//  Created by Yuri Sidorov on 05.03.2024.
//

import Foundation

extension RecurrenceRule {
    /// Generates dates based on the recurrence rule starting from a given date.
    /// - Parameters:
    ///   - startDate: The start date of the recurrence.
    ///   - endDate: The end date to limit the recurrence calculations. If nil, `count` will be used.
    /// - Returns: An array of `Date` objects representing the recurrence dates.
    func generateDates(startingFrom startDate: Date, endingBy endDate: Date? = nil) -> [Date] {
        var dates: [Date] = [startDate]
        var currentDate = startDate
        let calendar = Calendar.current
        
        while let nextDate = calculateNextDate(from: currentDate, calendar: calendar) {
            if let endDate = endDate, nextDate > endDate { break }
            if let count = count, dates.count >= count { break }
            
            dates.append(nextDate)
            currentDate = nextDate
        }
        
        print("DATES")
        print(dates)
        return dates
    }
    
    private func calculateNextDate(from date: Date, calendar: Calendar) -> Date? {
        switch frequency {
        case .daily:
            return date.addingDays(interval)
        case .weekly:
            return date.addingWeeks(interval)
        case .monthly:
            // A simple implementation, consider days of the month and leap years for a full implementation.
            return date.addingMonths(interval)
        case .yearly:
            return date.addingYears(interval)
        default:
            // Implement other frequencies
            return nil
        }
    }
}

