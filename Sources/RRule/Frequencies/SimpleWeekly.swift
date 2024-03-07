////
////  SimpleWeekly.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class SimpleWeekly: Frequency {
//    override func nextOccurrences() -> [Date] {
//        correctCurrentDateIfNeeded()
//        let thisOccurrence = current_date
//        guard let context = context,
//              let interval = context.options["interval"] as? Int else {
//            return []
//        }
//        
//        // Advance the current date by the specified number of weeks
//        if let nextDate = Calendar.current.date(byAdding: .weekOfYear, value: interval, to: current_date) {
//            current_date = nextDate
//        }
//        
//        // Assuming generator.processTimeset(thisOccurrence, timeset) is meant to calculate occurrences
//        // You need to adapt this part based on your actual implementation of `generator` and `timeset`
//        return generator.processTimeset(thisOccurrence, timeset: timeset)
//    }
//
//    func correctCurrentDateIfNeeded() {
//        guard let context = context else { return }
//        
//        let targetWday: Int
//        if let byweekday = context.options["byweekday"] as? [Weekday], !byweekday.isEmpty {
//            targetWday = byweekday.first!.index
//        } else {
//            targetWday = Calendar.current.component(.weekday, from: context.dtstart) - 1 // Adjusting to be 0-indexed if necessary
//        }
//        
//        // Advance the current date to the target weekday
//        while Calendar.current.component(.weekday, from: current_date) != (targetWday + 1) { // Calendar's weekday is 1-indexed
//            current_date = Calendar.current.date(byAdding: .day, value: 1, to: current_date)!
//        }
//    }
//}
