////
////  ByYearDay.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class ByYearDay {
//    private let byYearDays: [Int]
//    private unowned let context: Context // Assuming 'Context' is a class that includes necessary properties
//    
//    init(byYearDays: [Int], context: Context) {
//        self.byYearDays = byYearDays
//        self.context = context
//    }
//    
//    func reject(_ i: Int) -> Bool {
//        // Ensure byYearDays is not empty and perform checks based on the position of i relative to the year's length
//        guard !byYearDays.isEmpty else { return false }
//        
//        let yearLengthInDays = context.yearLengthInDays
//        let nextYearLengthInDays = context.nextYearLengthInDays
//        
//        if i < yearLengthInDays {
//            // For days within the current year
//            return !byYearDays.contains(i + 1) && !byYearDays.contains(i - yearLengthInDays)
//        } else {
//            // For days that might belong to the next year, considering the context's calculation
//            return !byYearDays.contains(i + 1 - yearLengthInDays) && !byYearDays.contains(i - yearLengthInDays - nextYearLengthInDays)
//        }
//    }
//}
//
////// Assuming Context is defined somewhere within your Swift project with the properties:
////class Context {
////    var yearLengthInDays: Int // Total days in the current year
////    var nextYearLengthInDays: Int // Total days in the next year
////    
////    // Initializer and other properties/methods...
////}
//
