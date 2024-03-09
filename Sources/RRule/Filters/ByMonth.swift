//
//  ByMonth.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class ByMonth {
    let byMonths: [Int]
    unowned let context: Context

    init(byMonths: [Int], context: Context) {
        self.byMonths = byMonths
        self.context = context
    }

    func reject(index i: Int) -> Bool {
        guard let monthByDayOfYear = context.monthByDayOfYear else { return true }
        return !byMonths.contains(monthByDayOfYear[i])
    }
}
