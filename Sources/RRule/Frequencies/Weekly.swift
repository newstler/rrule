//
//  Weekly.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Weekly: Frequency {
    override func possibleDays() -> [Int?] {
        guard let dayOfYear = calendar.ordinality(of: .day, in: .year, for: current_date) else { return [] }
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
        return (.day, daysToAdvance(date: current_date))
    }
    
    private func daysToAdvance(date: Date) -> Int {
        guard let wkst = context.options["wkst"] as? Int,
              let weekday = calendar.ordinality(of: .weekday, in: .weekOfYear, for: date),
              let interval = context.options["interval"] as? Int else {
            return 7 // Default to advancing by one week if wkst or interval is not set
        }
        
        if wkst > weekday {
            return -(weekday + 1 + (6 - wkst)) + interval * 7
        } else {
            return -(weekday - wkst) + interval * 7
        }
    }
}

