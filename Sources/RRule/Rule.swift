//
//  Rule.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Rule {
    let dtstart: Date
    let tz: TimeZone
    let rrule: String
    let exdate: [Date]
    var options: [String: Any] = [:] // Assuming options is a dictionary of parsed RRULE components
    var frequencyType: Frequency.Type? // Using a static type reference to the Frequency class or its subclasses
    let maxYear: Int
    let maxDate: Date
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = tz
        return cal
    }()
    
    init(rrule: String, dtstart: Date = Date(), tzid: String = "UTC", exdate: [Date] = [], maxYear: Int? = nil) {
        self.tz = TimeZone(identifier: tzid)!
        self.rrule = rrule
        self.dtstart = dtstart.floorToSeconds(in: tz)
        self.exdate = exdate
        self.options = parseOptions(rrule: rrule)
        self.frequencyType = try? Frequency.forOptions(options)
        self.maxYear = maxYear ?? 9999
        self.maxDate = DateComponents(calendar: calendar, year: self.maxYear).date!
    }
    
    var description: String {
        return rrule
    }
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
////    func humanize() -> String {
////        // Assuming Humanizer is another class or struct that you define
////        return Humanizer(self, options).toString()
////    }
    
    func parseOptions(_ rule: String) throws -> [String: Any] {
        var options: [String: Any] = ["interval": 1, "wkst": 1]
        
        // Remove RRULE: prefix to prevent parsing options incorrectly.
        let params = rule.replacingOccurrences(of: "RRULE:", with: "").split(separator: ";")
        for param in params {
            let parts = param.split(separator: '=')
            guard parts.count == 2, let option = parts.first, let value = parts.last else { continue }
            
            switch option {
            case "FREQ":
                options["freq"] = String(value)
            case "COUNT":
                if let i = Int(value), i >= 0 {
                    options["count"] = i
                } else {
                    throw InvalidRRule.error("COUNT must be a non-negative integer")
                }
            case "UNTIL":
                // The value of the UNTIL rule part MUST have the same value type as the "DTSTART" property.
                options["until"] = DateFormatter().date(from: String(value))
            case "INTERVAL":
                if let i = Int(value), i > 0 {
                    options["interval"] = i
                } else {
                    throw InvalidRRule.error("INTERVAL must be a positive integer")
                }
            case "BYHOUR", "BYMINUTE", "BYSECOND":
                options[String(option)] = value.split(separator: ",").compactMap { Int($0) }
            case "BYDAY":
                options["byweekday"] = value.split(separator: ",").compactMap { Weekday.parse(String($0)) }
            case "BYSETPOS", "BYMONTH", "BYMONTHDAY", "BYWEEKNO", "BYYEARDAY":
                options[String(option)] = value.split(separator: ",").compactMap { Int($0) }
            case "WKST":
                options["wkst"] = RRule.weekdays.firstIndex(of: String(value))
            default:
                break
            }
        }
        
        // Additional processing based on options
        // Implement similar logic for assigning default values and handling dtstart as in Ruby code
        
        return options
    }

    
//    private func countOrIntervalPresent() -> Bool {
//        // Implement logic to check for count or interval presence
//        // This will depend on how you've structured options parsing
//    }
}
