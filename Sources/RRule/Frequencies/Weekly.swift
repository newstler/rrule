//
//  Weekly.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Weekly: Frequency {
    override func possibleDays() -> [Int?] {
        guard let dayOfYear = context.calendar.ordinality(of: .day, in: .year, for: currentDate) else { return [] }
        var i = dayOfYear - 1 // Convert to 0-indexed
        var possibleDays: [Int] = []
        for _ in 0..<7 {
            possibleDays.append(i)
            i += 1
            if context.weekdayByDayOfYear?[i] == context.options["wkst"] as? Int {
                break
            }
        }
        return possibleDays
    }
    
    override func advanceBy() -> (component: Calendar.Component, value: Int) {
        return (.day, daysToAdvance(date: currentDate))
    }
    
    private func daysToAdvance(date: Date) -> Int {
        guard let wkst = context.options["wkst"] as? Int,
              let interval = context.options["interval"] as? Int else {
            return 7 // Assuming a default interval of 1 week if not specified.
        }

        let weekday = context.calendar.component(.weekday, from: date) - 1 // Adjust for zero-based indexing, assuming the context.calendar starts at 0.
        
        if wkst > weekday {
            return -(weekday + 1 + (6 - wkst)) + interval * 7
        } else {
            return -(weekday - wkst) + interval * 7
        }
    }
}

