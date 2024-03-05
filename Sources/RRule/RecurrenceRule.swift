////
////  RecurrenceRule.swift
////
////
////  Created by Yuri Sidorov on 05.03.2024.
////
//
//import Foundation
//
//struct RecurrenceRule {
//    var frequency: RecurrenceFrequency? = RecurrenceFrequency.monthly
//    var interval: Int? = 1
//    var until: Date?
//    var count: Int?
//    var byDay: [WeekdayOccurrence] = []
//    // Add other properties as needed, e.g., byMonthDay, byYearDay, etc.
//}
//
///// Represents a specific occurrence of a weekday, used for BYDAY rule part.
//struct WeekdayOccurrence {
//    let day: DayOfWeek // Define `DayOfWeek` enum to represent days of the week
//    let occurrence: Int? // nil means any, positive means nth occurrence, negative means nth from the end
//}
//
//enum RecurrenceFrequency: String {
//    case daily = "DAILY"
//    case weekly = "WEEKLY"
//    case monthly = "MONTHLY"
//    case yearly = "YEARLY"
//    // Extend with other frequencies as needed
//}
//
//enum DayOfWeek: String {
//    case sunday = "SU"
//    case monday = "MO"
//    case tuesday = "TU"
//    case wednesday = "WE"
//    case thursday = "TH"
//    case friday = "FR"
//    case saturday = "SA"
//}
//
//enum RRuleError: Error {
//    case invalidFormat
//    case invalidFrequency
//    case unsupportedFeature(String)
//    // Add other error cases as needed
//}
//
