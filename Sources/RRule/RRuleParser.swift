//
//  RRuleParser.swift
//  Money
//
//  Created by Yuri Sidorov on 05.03.2024.
//

import Foundation

class RRuleParser {
    
    /// Parses an RRule string and returns a `RecurrenceRule` instance.
    /// - Parameter rruleString: The RRule string to be parsed.
    /// - Returns: An instance of `RecurrenceRule` if the parsing is successful, throws an error otherwise.
    static func parse(rruleString: String) throws -> RecurrenceRule {
        var rule = RecurrenceRule()
        
        // Split the string by semicolon to get each rule component
        let components = rruleString.uppercased().split(separator: ";").map(String.init)
        
        for component in components {
            let pair = component.split(separator: "=").map(String.init)
            guard pair.count == 2 else { throw RRuleError.invalidFormat }
            
            let key = pair[0]
            let value = pair[1]
            
            switch key {
            case "FREQ":
                print(key)
                guard let frequency = RecurrenceFrequency(rawValue: value) else { throw RRuleError.invalidFrequency }
                rule.frequency = frequency
                print(rule.frequency)
            // Parse other components similarly (e.g., INTERVAL, UNTIL, BYDAY, etc.)
            case "INTERVAL":
                print(key)
                print(value)
                guard let interval = Int(value) else { throw RRuleError.invalidInterval }
                rule.interval = interval
                print(rule.interval)
            default: break
            }
        }
        
        return rule
    }
}

struct RecurrenceRule {
    var frequency: RecurrenceFrequency = RecurrenceFrequency.monthly
    var interval: Int = 1
    var until: Date?
    var count: Int?
    var byDay: [WeekdayOccurrence] = []
    // Add other properties as needed, e.g., byMonthDay, byYearDay, etc.
}

/// Represents a specific occurrence of a weekday, used for BYDAY rule part.
struct WeekdayOccurrence {
    let day: DayOfWeek // Define `DayOfWeek` enum to represent days of the week
    let occurrence: Int? // nil means any, positive means nth occurrence, negative means nth from the end
}

enum RecurrenceFrequency: String {
    case daily = "DAILY"
    case weekly = "WEEKLY"
    case monthly = "MONTHLY"
    case yearly = "YEARLY"
    // Extend with other frequencies as needed
}

enum DayOfWeek: String {
    case sunday = "SU"
    case monday = "MO"
    case tuesday = "TU"
    case wednesday = "WE"
    case thursday = "TH"
    case friday = "FR"
    case saturday = "SA"
}

enum RRuleError: Error {
    case invalidFormat
    case invalidFrequency
    case invalidInterval
    case unsupportedFeature(String)
    // Add other error cases as needed
}


// Define necessary enums and structs (e.g., `RecurrenceRule`, `RecurrenceFrequency`, `RRuleError`) below.
