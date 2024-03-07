////
////  BySetPosition.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class BySetPosition: Generator {
//    private let bySetPositions: [Int]
//    
//    init(bySetPositions: [Int], context: Context) {
//        self.bySetPositions = bySetPositions
//        super.init(context: context)
//    }
//    
//    func combineDatesAndTimes(dayset: [Int?], timeset: [[String: [Int]]]) -> [Date] {
//        let validDates = self.validDates(dayset: dayset.compactMap { $0 })
//        return validDates.flatMap { date in
//            self.processTimeset(date: date, timeset: timeset)
//        }
//    }
//    
//    private func validDates(dayset: [Int]) -> [Date] {
//        guard let context = self.context else { return [] }
//        
//        let calendar = Calendar.current
//        return bySetPositions.compactMap { position in
//            let adjustedPosition = position > 0 ? position - 1 : position
//            guard dayset.indices.contains(adjustedPosition) else { return nil }
//            let dayOffset = dayset[adjustedPosition]
//            return calendar.date(byAdding: .day, value: dayOffset, to: context.firstDayOfYear)
//        }
//    }
//}
//
////// Assuming Context is defined within your Swift project and includes:
////class Context {
////    var firstDayOfYear: Date // The first day of the year for the current context
////    var tz: TimeZone // The time zone used for date calculations
////    
////    // Initializer and other properties/methods...
////}
//
