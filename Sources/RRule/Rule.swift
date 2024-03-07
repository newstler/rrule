////
////  Rule.swift
////
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import Foundation
//
//class Rule {
//    var dtstart: Date
//    var tz: TimeZone
//    var exdate: [Date]
//    var options: [String: Any] // Options parsing will need to be adapted to Swift's type system
//    var frequencyType: FrequencyType // Assume FrequencyType is an enum or class you define based on your needs
//    var maxYear: Int
//    var maxDate: Date
//    
//    init(rrule: String, dtstart: Date = Date(), tzid: String = "UTC", exdate: [Date] = [], maxYear: Int? = nil) {
//        self.tz = TimeZone(identifier: tzid) ?? TimeZone(secondsFromGMT: 0)!
//        self.dtstart = dtstart
//        self.exdate = exdate
//        self.options = Rule.parseOptions(rrule: rrule)
//        self.frequencyType = FrequencyType.forOptions(options) // Assuming you have a method to determine frequency type
//        self.maxYear = maxYear ?? 9999
//        self.maxDate = DateComponents(calendar: .current, year: self.maxYear).date!
//    }
//    
//    var description: String {
//        return rrule
//    }
//    
//    func all(limit: Int? = nil) -> [Date] {
//        return allUntil(limit: limit)
//    }
//    
//    func between(startDate: Date, endDate: Date, limit: Int? = nil) -> [Date] {
//        let flooredStartDate = floorToSecondsInTimeZone(date: startDate)
//        let flooredEndDate = floorToSecondsInTimeZone(date: endDate)
//        return allUntil(startDate: flooredStartDate, endDate: flooredEndDate, limit: limit).filter { $0 >= flooredStartDate }
//    }
//    
//    func from(startDate: Date, limit: Int) -> [Date] {
//        let flooredStartDate = floorToSecondsInTimeZone(date: startDate)
//        return allUntil(startDate: flooredStartDate, limit: limit).filter { $0 >= flooredStartDate }
//    }
//    
//    func each(floorDate: Date? = nil, _ body: (Date) throws -> Void) rethrows {
//        var floorDate = floorDate
//        if countOrIntervalPresent() || floorDate == nil || dtstart > floorDate! {
//            floorDate = dtstart
//        }
//        
//        // Swift's Sequence and IteratorProtocol can be used to create a custom iterator for enumeration
//        
//        // This part of code would require adapting your filtering and iteration logic to Swift
//        // Including converting context setup, filter setup, and the actual enumeration loop
//    }
//    
//    func next() -> Date? {
//        // Implement functionality to get the next date
//        // This may require keeping track of the current state in an iterator-like object
//    }
//    
//    func humanize() -> String {
//        // Assuming Humanizer is another class or struct that you define
//        return Humanizer(self, options).toString()
//    }
//    
//    private func floorToSecondsInTimeZone(date: Date) -> Date {
//        // Swift date manipulation to floor to seconds in specified time zone
//        // Note: You will need to implement this method based on Swift's Date and Calendar APIs
//    }
//    
//    private static func parseOptions(rrule: String) -> [String: Any] {
//        var options: [String: Any] = ["interval": 1, "wkst": 1]
//        
//        // Parsing logic needs to be adapted to Swift's string manipulation methods
//        
//        return options
//    }
//    
//    private func countOrIntervalPresent() -> Bool {
//        // Implement logic to check for count or interval presence
//        // This will depend on how you've structured options parsing
//    }
//}
