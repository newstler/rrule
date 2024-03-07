////
////  AllOccurrences.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class AllOccurrences: Generator {
//    func combineDatesAndTimes(dayset: [Int?], timeset: [[String: [Int]]]) -> [Date] {
//        guard let context = self.context else { return [] }
//        
//        let calendar = Calendar.current
//        var resultDates: [Date] = []
//        
//        for dayOffset in dayset.compactMap({ $0 }) {
//            guard let firstDayOfYear = calendar.date(from: DateComponents(year: calendar.component(.year, from: context.firstDayOfYear), month: 1, day: 1)),
//                  let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfYear) else {
//                continue
//            }
//            
//            let datesForDay = processTimeset(date: date, timeset: timeset)
//            resultDates.append(contentsOf: datesForDay)
//        }
//        
//        return resultDates
//    }
//}
//
////// Assuming Context is defined within your Swift project and includes:
////class Context {
////    var firstDayOfYear: Date // The first day of the year for the current context
////    
////    // Assuming it also includes a TimeZone property for complete date calculations in Generator
////    var tz: TimeZone
////    
////    // Initializer and other properties/methods...
////}
//
