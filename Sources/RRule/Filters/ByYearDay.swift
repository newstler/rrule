//
//  ByYearDay.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class ByYearDay {
    unowned let context: Context
    let byYearDays: [Int]

    init(byYearDays: [Int], context: Context) {
        self.byYearDays = byYearDays
        self.context = context
    }

    func reject(index i: Int) -> Bool {
        guard !byYearDays.isEmpty else { return false }
        
        let currentYearDays = context.yearLengthInDays ?? 365
        let nextYearDays = context.nextYearLengthInDays ?? 365

        if i < currentYearDays {
            return !byYearDays.contains(i + 1) && !byYearDays.contains(i - currentYearDays)
        } else {
            return !byYearDays.contains(i + 1 - currentYearDays) && !byYearDays.contains(i - currentYearDays - nextYearDays)
        }
    }
}
