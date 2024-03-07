////
////  ByWeekNumber.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class ByWeekNumber {
//    private let byWeekNumbers: [Int]
//    private unowned let context: Context // Assuming 'Context' is a class with necessary properties
//    
//    init(byWeekNumbers: [Int], context: Context) {
//        self.byWeekNumbers = byWeekNumbers
//        self.context = context
//    }
//    
//    func reject(_ i: Int) -> Bool {
//        // Check if the week number for day i is not included in byWeekNumbers
//        // and if its negative counterpart is also not included.
//        // This assumes both weekNumberByDayOfYear and negativeWeekNumberByDayOfYear are accessible and correctly populated.
//        guard i >= 0, i < context.weekNumberByDayOfYear.count, i < context.negativeWeekNumberByDayOfYear.count else { return true }
//        
//        let weekNumber = context.weekNumberByDayOfYear[i]
//        let negativeWeekNumber = context.negativeWeekNumberByDayOfYear[i]
//        return !byWeekNumbers.contains(weekNumber) && !byWeekNumbers.contains(negativeWeekNumber)
//    }
//}
//
////// Assuming Context is defined somewhere within your Swift project with the properties:
////class Context {
////    var weekNumberByDayOfYear: [Int] // Example: [1, 1, 2, ...] corresponding to the week numbers of each day of the year
////    var negativeWeekNumberByDayOfYear: [Int] // Example: [-52, -52, -51, ...] for negative week numbers
////    
////    // Initializer and other properties/methods...
////}
//
