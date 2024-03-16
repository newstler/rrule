//
//  BySetPosition.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class BySetPosition: Generator {
    let bySetPositions: [Int]

    init(bySetPositions: [Int], context: Context) {
        self.bySetPositions = bySetPositions
        super.init(context: context)
    }

    override func combineDatesAndTimes(dayset: [Int?], timeset: [[String: [Int]]]) -> [Date] {
        let validDates = self.validDates(dayset: dayset)
        return validDates.flatMap { date in
            processTimeset(date: date, timeset: timeset)
        }
    }

    func validDates(dayset: [Int?]) -> [Date] {
        guard let firstDayOfYear = context.firstDayOfYear else { return [] }

        // Compact the dayset to remove nil values and ensure it's mutable for manipulation
        let compactedDayset = dayset.compactMap { $0 }

        let validPositions = bySetPositions.map { position -> Int? in
            let adjustedPosition = position > 0 ? position - 1 : position < 0 ? compactedDayset.count + position : position
            guard adjustedPosition >= 0, adjustedPosition < compactedDayset.count else { return nil }
            return compactedDayset[adjustedPosition]
        }.compactMap { $0 }

        return validPositions.map { dayOffset in
            context.calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfYear)!
        }
    }
}
