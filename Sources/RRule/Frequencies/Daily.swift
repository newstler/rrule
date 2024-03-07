//
//  Daily.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Daily: Frequency {
    func possibleDays() -> [Int] {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: current_date)
        return [dayOfYear! - 1] // Convert to 0-indexed
    }
    
    override func advance() {
        guard let interval = context.options["interval"] as? Int else { return }
        self.current_date = Calendar.current.date(byAdding: .day, value: interval, to: self.current_date)!
        let newDate = self.current_date
        if !sameMonth(firstDate: self.current_date, secondDate: newDate) {
            context.rebuild(year: newDate.getYear(), month: newDate.getMonth())
        }
    }
}
