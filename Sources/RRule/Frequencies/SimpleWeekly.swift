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
        let thisOccurrence = currentDate
        if let interval = context.options["interval"] as? Int {
            currentDate = context.calendar.date(byAdding: .day, value: interval * 7, to: currentDate)!
        }
        return generator.processTimeset(date: thisOccurrence, timeset: timeset)
    }

    func correctCurrentDateIfNeeded() {
        let targetWday = (context.options["byweekday"] as? [Weekday])?.first?.index ?? context.calendar.component(.weekday, from: context.dtstart) - 1

        while context.calendar.component(.weekday, from: currentDate) - 1 != targetWday {
            currentDate = context.calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
    }
}

