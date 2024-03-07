////
////  Generator.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class Generator {
//    let context: Context // Assuming 'Context' includes a TimeZone property named `tz`
//    
//    init(context: Context) {
//        self.context = context
//    }
//    
//    func processTimeset(date: Date, timeset: [[String: [Int]]]) -> [Date] {
//        guard !timeset.isEmpty else { return [date] }
//        
//        var resultDates: [Date] = []
//        
//        let calendar = Calendar.current
//        for time in timeset {
//            guard let hours = time["hour"], let minutes = time["minute"], let seconds = time["second"] else { continue }
//            
//            for hour in hours.sorted() {
//                for minute in minutes.sorted() {
//                    for second in seconds.sorted() {
//                        var dateComponents = calendar.dateComponents([.year, .month, .day, .timeZone], from: date)
//                        dateComponents.hour = hour
//                        dateComponents.minute = minute
//                        dateComponents.second = second
//                        dateComponents.timeZone = context.tz // Assuming context.tz is of type TimeZone
//                        
//                        if let specificDate = calendar.date(from: dateComponents) {
//                            resultDates.append(specificDate)
//                        }
//                    }
//                }
//            }
//        }
//        
//        return resultDates
//    }
//}
//
////// Assuming Context is defined somewhere within your Swift project with the property:
////class Context {
////    var tz: TimeZone // The time zone used for date calculations
////    
////    // Initializer and other properties/methods...
////}
//
