//
//  RRule.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

enum RRule {
    static let weekdays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
    
//    static func parse(_ rrule: String, options: [String: Any]) -> Rule {
//        return Rule(rrule, options: options)
//    }

    // Error handling
    class InvalidRRule: Error {}
}
