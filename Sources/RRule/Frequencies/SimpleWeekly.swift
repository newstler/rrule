//
//  SimpleWeekly.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class SimpleWeekly: Frequency {
    override func nextOccurrences() -> [Date] {
        correctCurrentDateIfNeeded()
        let thisOccurrence = current_date
        if let interval = context.options["interval"] as? Int {
            current_date = calendar.date(byAdding: .day, value: interval * 7, to: current_date)!
        }
        return generator.processTimeset(date: thisOccurrence, timeset: timeset)
    }

    func correctCurrentDateIfNeeded() {
        let targetWday = (context.options["byweekday"] as? [Weekday])?.first?.index ?? calendar.component(.weekday, from: context.dtstart) - 1

        while calendar.component(.weekday, from: current_date) - 1 != targetWday {
            current_date = calendar.date(byAdding: .day, value: 1, to: current_date)!
        }
    }
}

