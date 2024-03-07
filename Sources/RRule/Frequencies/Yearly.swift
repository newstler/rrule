////
////  Yearly.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class Yearly: Frequency {
//    override func possibleDays() -> [Int] {
//        guard let context = self.context else { return [] }
//        
//        let calendar = Calendar.current
//        let yearComponent = calendar.component(.year, from: context.dtstart)
//        guard let startOfYear = calendar.date(from: DateComponents(year: yearComponent)),
//              let endOfYear = calendar.date(from: DateComponents(year: yearComponent + 1)) else {
//            return []
//        }
//        
//        let daysInYear = calendar.dateComponents([.day], from: startOfYear, to: endOfYear).day!
//        return Array(0..<daysInYear)
//    }
//
//    override func advance(by context: Context?) {
//        guard let context = context,
//              let interval = context.options["interval"] as? Int else {
//            return
//        }
//        
//        // Advance the current date by the specified number of years
//        if let nextDate = Calendar.current.date(byAdding: .year, value: interval, to: context.dtstart) {
//            context.dtstart = nextDate
//        }
//    }
//}
