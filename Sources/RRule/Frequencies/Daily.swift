//
//  Daily.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

// Assuming the Frequency class is already defined as shown earlier
class Daily: Frequency {
    override func possibleDays() -> [Int?] {
        guard let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: current_date) else { return [] }
        return [dayOfYear - 1] // Adjust for zero-based index
    }
    
    override func advanceBy() -> (component: Calendar.Component, value: Int) {
        let interval = context.options["interval"] as? Int ?? 1
        return (.day, interval)
    }
}

