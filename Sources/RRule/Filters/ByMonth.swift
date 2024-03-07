////
////  ByMonth.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class ByMonth {
//    let byMonths: [Int]
//    unowned let context: Context // Assuming 'Context' is a class that includes month_by_day_of_year array
//    
//    init(byMonths: [Int], context: Context) {
//        self.byMonths = byMonths
//        self.context = context
//    }
//    
//    func reject(_ i: Int) -> Bool {
//        // Ensure index i is within bounds of the context's month_by_day_of_year array
//        guard i >= 0, i < context.monthByDayOfYear.count else { return true }
//        
//        // Check if the month for day i is not included in byMonths
//        return !byMonths.contains(context.monthByDayOfYear[i])
//    }
//}
//
////// Context class for demonstration purposes
////class Context {
////    // This array maps each day of the year to its corresponding month.
////    // For a non-leap year, its size should be 365, and for a leap year, 366.
////    // Each element represents the month (1-12) for the corresponding day of the year.
////    var monthByDayOfYear: [Int]
////    
////    init(monthByDayOfYear: [Int]) {
////        self.monthByDayOfYear = monthByDayOfYear
////    }
////    
////    // Other properties and methods...
////}
//
