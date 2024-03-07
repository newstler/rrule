//
//  Frequency.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Frequency {
    var current_date: Date
    var filters: [Filter]
    var generator: Generator
    var timeset: [TimeSet] // Assuming TimeSet is a struct or class you have defined
    
    var context: Context // Context is assumed to be a class you have defined
    
    init(context: Context, filters: [Filter], generator: Generator, timeset: [TimeSet], startDate: Date?) {
        self.context = context
        self.current_date = startDate ?? context.dtstart
        self.filters = filters
        self.generator = generator
        self.timeset = timeset
    }
    
    func advance() {
        let advanceBy = ... // Determine how much to advance by based on your application's logic
        self.current_date = Calendar.current.date(byAdding: advanceBy, to: self.current_date)!.tap { newDate in
            if !sameMonth(firstDate: self.current_date, secondDate: newDate) {
                context.rebuild(year: newDate.year, month: newDate.month)
            }
        }
    }
    
    func nextOccurrences() -> [Date] {
        var possibleDaysOfYear = possibleDays() // Implement this method based on your rules
        
        if !filters.isEmpty {
            for (i, dayIndex) in possibleDaysOfYear.enumerated() {
                if filters.any { $0.reject(dayIndex: dayIndex) } { // Assuming Filter has a method `reject`
                    possibleDaysOfYear[i] = nil
                }
            }
        }
        
        return generator.combineDatesAndTimes(possibleDaysOfYear.compactMap { $0 }, timeset).tap {
            advance()
        }
    }
    
    static func forOptions(_ options: [String: Any]) -> Frequency {
        switch options["freq"] as? String {
        case "DAILY":
            return Daily(context: context, filters: filters, generator: generator, timeset: timeset) // Assuming these are classes that inherit from Frequency
        case "WEEKLY":
            if let simpleWeekly = options["simple_weekly"] as? Bool, simpleWeekly, options["bymonth"] == nil {
                return SimpleWeekly(context: context, filters: filters, generator: generator, timeset: timeset)
            } else {
                return Weekly(context: context, filters: filters, generator: generator, timeset: timeset)
            }
        case "MONTHLY":
            return Monthly(context: context, filters: filters, generator: generator, timeset: timeset)
        case "YEARLY":
            return Yearly(context: context, filters: filters, generator: generator, timeset: timeset)
        default:
            fatalError("Valid FREQ value is required")
        }
    }
    
    private func sameMonth(firstDate: Date, secondDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(firstDate, equalTo: secondDate, toGranularity: .month) && calendar.isDate(firstDate, equalTo: secondDate, toGranularity: .year)
    }
    
    private func possibleDays() -> [Int] {
        // This method needs to calculate possible days based on the frequency and context.
        // You'll need to implement this according to the rules you are applying.
        return []
    }
}
