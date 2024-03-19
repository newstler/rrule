//
//  RRule.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

public enum RRule {
    static let weekdays = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"]
    
    public static func parse(_ rrule: String, dtstart: Date = Date(), tzid: String = "UTC", exdate: [Date] = [], maxYear: Int? = nil) -> Rule {
        return Rule(rrule: rrule, dtstart: dtstart, tzid: tzid, exdate: exdate, maxYear: maxYear)
    }

    // Error handling
    class InvalidRRule: Error {}
}
