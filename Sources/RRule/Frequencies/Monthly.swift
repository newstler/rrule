//
//  Monthly.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Monthly: Frequency {
    override func possibleDays() -> [Int?] {
        // Calculate the range of days in the current month
        guard let range = calendar.range(of: .day, in: .month, for: current_date) else { return [] }
        
        // Adjusting for zero-based index by subtracting 1 from each day's ordinality
        let startDayOfYear = calendar.ordinality(of: .day, in: .year, for: calendar.date(from: DateComponents(year: calendar.component(.year, from: current_date), month: calendar.component(.month, from: current_date), day: range.lowerBound))!)!
        let endDayOfYear = calendar.ordinality(of: .day, in: .year, for: calendar.date(from: DateComponents(year: calendar.component(.year, from: current_date), month: calendar.component(.month, from: current_date), day: range.upperBound - 1))!)!
        
        return (startDayOfYear...endDayOfYear).map { $0 - 1 }
    }
    
    override func advanceBy() -> (component: Calendar.Component, value: Int) {
        let interval = context.options["interval"] as? Int ?? 1
        return (.month, interval)
    }
}
