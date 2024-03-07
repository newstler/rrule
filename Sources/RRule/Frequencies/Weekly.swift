//
//  Weekly.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Weekly: Frequency {
    override func possibleDays() -> [Int] {
        guard let context = self.context else { return [] }
        
        let calendar = Calendar.current
        let startOfYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: context.dtstart)))!
        var i = calendar.ordinality(of: .day, in: .year, for: context.dtstart)! - 1 // 0-indexed
        var possibleDays: [Int] = []
        
        for _ in 0..<7 {
            possibleDays.append(i)
            i += 1
            
            let nextDate = calendar.date(byAdding: .day, value: i, to: startOfYear)!
            if calendar.component(.weekday, from: nextDate) == context.options["wkst"] as? Int {
                break
            }
        }
        
        return possibleDays
    }

    override func advance(by context: Context?) {
        guard let context = context,
              let wkst = context.options["wkst"] as? Int,
              let interval = context.options["interval"] as? Int else {
            return
        }
        
        let daysToAdvance = self.daysToAdvance(date: context.dtstart, wkst: wkst, interval: interval)
        if let nextDate = Calendar.current.date(byAdding: .day, value: daysToAdvance, to: context.dtstart) {
            context.dtstart = nextDate
        }
    }

    private func daysToAdvance(date: Date, wkst: Int, interval: Int) -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        
        if wkst > weekday {
            return -(weekday + 1 + (6 - wkst)) + interval * 7
        } else {
            return -(weekday - wkst) + interval * 7
        }
    }
}
