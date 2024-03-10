//
//  Yearly.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Yearly: Frequency {
    override func possibleDays() -> [Int?] {
        guard let yearLengthInDays = context.yearLengthInDays else { return [] }
        return Array(0..<yearLengthInDays)
    }

    override func advanceBy() -> (component: Calendar.Component, value: Int) {
        let interval = context.options["interval"] as? Int ?? 1
        return (.year, interval)
    }
}

