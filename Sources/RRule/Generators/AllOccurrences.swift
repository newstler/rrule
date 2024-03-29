//
//  AllOccurrences.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class AllOccurrences: Generator {
    override func combineDatesAndTimes(dayset: [Int?], timeset: [[String: [Int]]]) -> [Date] {
        guard let firstDayOfYear = context.firstDayOfYear else { return [] }
        
        return dayset.compactMap { $0 }.flatMap { dayOffset in
            let targetDate = context.calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfYear)!
            return processTimeset(date: targetDate, timeset: timeset)
        }
    }
}
