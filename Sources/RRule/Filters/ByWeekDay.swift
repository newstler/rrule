//
//  ByWeekDay.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class ByWeekDay {
    private let byWeekDays: [Int]
    private unowned let context: Context // Assuming 'Context' is a class with necessary properties
    
    init(weekdays: [Weekday], context: Context) {
        // Assuming Weekday is a struct or class that has a property 'index'
        self.byWeekDays = weekdays.map { $0.index }
        self.context = context
    }
    
    func reject(_ i: Int) -> Bool {
        return masked(i) && !matchesByWeekDays(i)
    }
    
    private func masked(_ i: Int) -> Bool {
        // Assuming 'dayOfYearMask' is an optional array of Bool in Context.
        // If 'dayOfYearMask' is nil or its value at index i is false, it returns true; otherwise, false.
        return context.dayOfYearMask?.indices.contains(i) == true ? !(context.dayOfYearMask?[i] ?? true) : true
    }
    
    private func matchesByWeekDays(_ i: Int) -> Bool {
        // Checks if 'byWeekDays' is not empty and if it contains the weekday at index i.
        guard !byWeekDays.isEmpty, i >= 0, i < context.weekdayByDayOfYear.count else { return false }
        return byWeekDays.contains(context.weekdayByDayOfYear[i])
    }
}

//// Assuming Context is defined somewhere within your Swift project with the properties:
//class Context {
//    var dayOfYearMask: [Bool]? // Example: [true, false, true, ...] for each day of the year
//    var weekdayByDayOfYear: [Int] // Example: [1, 2, 3, ...] corresponding to the weekdays of each day of the year
//    
//    // Initializer and other properties/methods...
//}

