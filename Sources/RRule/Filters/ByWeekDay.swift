//
//  ByWeekDay.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class ByWeekDay {
    unowned let context: Context
    let byWeekDays: [Int]

    init(weekdays: [Weekday], context: Context) {
        // Assuming `Weekday` is a struct or class with an `index` property
        self.byWeekDays = weekdays.map { $0.index }
        self.context = context
    }

    func reject(index i: Int) -> Bool {
        return isMasked(index: i) && !matchesByWeekDays(index: i)
    }

    private func isMasked(index i: Int) -> Bool {
        // Assuming `dayOfYearMask` is an optional array of Bool where true represents a day to be considered
        guard let dayOfYearMask = context.dayOfYearMask else { return true }
        return i < dayOfYearMask.count && !dayOfYearMask[i]
    }

    private func matchesByWeekDays(index i: Int) -> Bool {
        // Assuming `weekdayByDayOfYear` is an array of Int representing the weekday for each day
        guard let weekdayByDayOfYear = context.weekdayByDayOfYear, !byWeekDays.isEmpty else { return false }
        return i < weekdayByDayOfYear.count && byWeekDays.contains(weekdayByDayOfYear[i])
    }
}
