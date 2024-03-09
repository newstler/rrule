//
//  Daily.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Daily: Frequency {
    override func possibleDays() -> [Int?] {
        guard let dayOfYear = calendar.ordinality(of: .day, in: .year, for: current_date) else { return [] }
        return [dayOfYear - 1] // Adjust for zero-based index
    }
    
    override func advanceBy() -> (component: Calendar.Component, value: Int) {
        let interval = context.options["interval"] as? Int ?? 1
        return (.day, interval)
    }
}
