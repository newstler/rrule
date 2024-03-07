//
//  Weekday.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

struct Weekday {
    let index: Int
    let ordinal: Int?
    
    init(index: Int, ordinal: Int? = nil) {
        self.index = index
        self.ordinal = ordinal
    }
    
    static func parse(_ weekday: String) -> Weekday? {
        let pattern = "([+-]?\\d+)?([A-Z]{2})"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: weekday, range: NSRange(weekday.startIndex..., in: weekday)) else {
            return nil
        }
        
        // Extracting the ordinal part, if present
        var ordinal: Int? = nil
        if let ordinalRange = Range(match.range(at: 1), in: weekday) {
            ordinal = Int(weekday[ordinalRange])
        }
        
        // Extracting the weekday index
        guard let weekdayRange = Range(match.range(at: 2), in: weekday),
              let index = RRule.weekdays.firstIndex(of: String(weekday[weekdayRange])) else {
            return nil
        }
        
        return Weekday(index: index, ordinal: ordinal)
    }
}
