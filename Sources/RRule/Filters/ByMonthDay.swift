//
//  ByMonthDay.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class ByMonthDay {
    unowned let context: Context
    let positiveMonthDays: [Int]
    let negativeMonthDays: [Int]

    init(byMonthDays: [Int], context: Context) {
        self.context = context
        self.positiveMonthDays = byMonthDays.filter { $0 > 0 }
        self.negativeMonthDays = byMonthDays.filter { $0 < 0 }
    }

    func reject(index i: Int) -> Bool {
        guard let monthDayByDayOfYear = context.monthDayByDayOfYear, let negativeMonthDayByDayOfYear = context.negativeMonthDayByDayOfYear else { return true }
        
        let isPositiveRejected = !positiveMonthDays.contains(monthDayByDayOfYear[i])
        let isNegativeRejected = !negativeMonthDays.contains(negativeMonthDayByDayOfYear[i])
        
        return isPositiveRejected && isNegativeRejected
    }
}
