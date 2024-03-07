////
////  Monthly.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class Monthly: Frequency {
//    func possibleDays() -> [Int] {
//        guard let context = context else { return [] }
//        
//        // Use Calendar to calculate the range of days in the current month.
//        let calendar = Calendar.current
//        let interval = DateComponents(month: 1)
//        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: context.dtstart)),
//              let endOfMonth = calendar.date(byAdding: interval, to: startOfMonth, wrappingComponents: false) else {
//            return []
//        }
//        
//        let startDayIndex = calendar.ordinality(of: .day, in: .year, for: startOfMonth)! - 1 // Convert to 0-indexed
//        let endDayIndex = calendar.ordinality(of: .day, in: .year, for: endOfMonth)! - 2 // Adjust for end of month and convert to 0-indexed
//        
//        return Array(startDayIndex...endDayIndex)
//    }
//
//    func advance(by context: Context?) {
//        guard let context = context,
//              let interval = context.options["interval"] as? Int,
//              let currentMonth = Calendar.current.dateComponents([.month], from: context.dtstart).month else {
//            return
//        }
//        
//        // Calculate and set the next current date based on the interval.
//        let nextMonthComponent = DateComponents(month: interval)
//        if let nextDate = Calendar.current.date(byAdding: nextMonthComponent, to: context.dtstart) {
//            context.dtstart = nextDate
//        }
//    }
//}
