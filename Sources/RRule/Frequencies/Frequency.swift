//
//  Frequency.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Frequency {
    var currentDate: Date
    let filters: [Filter]
    let generator: Generator
    let timeset: [[String: [Int]]]
    unowned let context: Context
    
    lazy var calendar: Calendar = {
        return context.calendar
    }()

    required init(context: Context, filters: [Filter], generator: Generator, timeset: [[String: [Int]]], startDate: Date? = nil) {
        self.context = context
        self.currentDate = startDate ?? context.dtstart
        self.filters = filters
        self.generator = generator
        self.timeset = timeset
    }

    func advance() {
        let interval = advanceBy()
        guard let newDate = calendar.date(byAdding: interval.component, value: interval.value, to: currentDate) else { return }
        if !sameMonth(currentDate, newDate) {
            context.rebuild(year: calendar.component(.year, from: newDate), month: calendar.component(.month, from: newDate))
        }
        currentDate = newDate
    }

    func advanceBy() -> (component: Calendar.Component, value: Int) {
        // This should be overridden by subclasses
        return (.day, 1) // Default to advancing by one day
    }
    
    func possibleDays() -> [Int?] {
        fatalError("Subclasses must implement `possibleDays`.")
    }
    
    func nextOccurrences() -> [Date] {
        // Assuming `possibleDays` returns an array of optional integers,
        // representing days of the year that could potentially include occurrences.
        var possibleDaysOfYear = possibleDays()

        // Apply filters to exclude certain days.
        // Filters should be an array of objects conforming to a Filtering protocol, which includes a `reject` method.
        for (index, day) in possibleDaysOfYear.enumerated() {
            if let dayIndex = day, filters.contains(where: { $0.reject(index: dayIndex) }) {
                possibleDaysOfYear[index] = nil
            }
        }

        // Assuming `generator` conforms to a Generator protocol that includes a `combineDatesAndTimes` method,
        // and `timeset` is compatible with what the generator expects.
        let occurrences = generator.combineDatesAndTimes(dayset: possibleDaysOfYear.compactMap { $0 }, timeset: timeset)

        // Advance the current date to prepare for the next calculation.
        advance()

        return occurrences
    }
    
    static func forOptions(_ options: [String: Any]) throws -> Frequency.Type {
        guard let freq = options["FREQ"] as? String else {
            throw InvalidRRule(reason: "Valid FREQ value is required")
        }
        
        switch freq.uppercased() {
        case "DAILY":
            return Daily.self
        case "WEEKLY":
            if let simpleWeekly = options["simple_weekly"] as? Bool, simpleWeekly, options["bymonth"] == nil {
                return SimpleWeekly.self
            } else {
                return Weekly.self
            }
        case "MONTHLY":
            return Monthly.self
        case "YEARLY":
            return Yearly.self
        default:
            throw InvalidRRule(reason: "Unsupported FREQ value: \(freq)")
        }
    }

    private func sameMonth(_ firstDate: Date, _ secondDate: Date) -> Bool {
        return calendar.isDate(firstDate, equalTo: secondDate, toGranularity: .month) &&
               calendar.isDate(firstDate, equalTo: secondDate, toGranularity: .year)
    }
}

// Define the `InvalidRRule` error to be used in the `forOptions` method
struct InvalidRRule: Error {
    let reason: String
}
