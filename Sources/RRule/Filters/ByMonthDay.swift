////
////  ByMonthDay.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class ByMonthDay {
//    private unowned let context: Context
//    private let positiveMonthDays: [Int]
//    private let negativeMonthDays: [Int]
//    
//    init(byMonthDays: [Int], context: Context) {
//        self.context = context
//        // Partitioning byMonthDays into positive and negative values
//        let partitionedDays = byMonthDays.partitioned { $0 > 0 }
//        self.positiveMonthDays = partitionedDays.true
//        self.negativeMonthDays = partitionedDays.false.map { $0 * -1 } // Convert to positive for matching
//    }
//    
//    func reject(_ i: Int) -> Bool {
//        // Ensure index i is within bounds
//        guard i >= 0, i < context.monthDayByDayOfYear.count, i < context.negativeMonthDayByDayOfYear.count else { return true }
//        
//        // Checking against both positive and converted negative month days
//        let day = context.monthDayByDayOfYear[i]
//        let negativeDay = context.negativeMonthDayByDayOfYear[i]
//        return !positiveMonthDays.contains(day) && !negativeMonthDays.contains(negativeDay)
//    }
//}
//
////// Context class placeholder
////class Context {
////    var monthDayByDayOfYear: [Int]
////    var negativeMonthDayByDayOfYear: [Int]
////    
////    init(monthDayByDayOfYear: [Int], negativeMonthDayByDayOfYear: [Int]) {
////        self.monthDayByDayOfYear = monthDayByDayOfYear
////        self.negativeMonthDayByDayOfYear = negativeMonthDayByDayOfYear
////    }
////    
////    // Other properties and methods...
////}
//
//// Extension to partition an array into two based on a predicate
//extension Array {
//    func partitioned(by predicate: (Element) -> Bool) -> (true: [Element], false: [Element]) {
//        var truePart: [Element] = []
//        var falsePart: [Element] = []
//        for element in self {
//            if predicate(element) {
//                truePart.append(element)
//            } else {
//                falsePart.append(element)
//            }
//        }
//        return (truePart, falsePart)
//    }
//}
//
