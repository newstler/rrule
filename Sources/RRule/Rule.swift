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
    var calendar: Calendar = Calendar.current
    
    init(rrule: String, dtstart: Date = Date(), tzid: String = "UTC", exdate: [Date] = [], maxYear: Int? = nil) {
        self.tz = TimeZone(identifier: tzid)!
        self.calendar.timeZone = tz
        self.rrule = rrule
        self.dtstart = dtstart.floorToSeconds(in: tz)
        self.exdate = exdate
        self.maxYear = maxYear ?? 9999
        self.maxDate = DateComponents(calendar: calendar, year: self.maxYear).date!
        self.options = try! parseOptions(rrule)
        self.frequencyType = try? Frequency.forOptions(options)
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
    
    
    func each(floorDate: Date? = nil, _ block: ((Date) -> Void)? = nil) -> AnyIterator<Date> {
        var currentDate = floorDate
        
        // If we have a COUNT or INTERVAL option, or floorDate is nil, or dtstart is after floorDate, we start from dtstart
        if countOrIntervalPresent() || currentDate == nil || dtstart > currentDate! {
            currentDate = dtstart
        }
        
//        guard let block = block else {
//            // If no block is provided, we might want to return an enumerator or handle differently
//            return
//        }
        
        let context = Context(options: options, dtstart: dtstart, tz: tz)
        let components = calendar.dateComponents([.year, .month], from: currentDate!)
        context.rebuild(year: components.year!, month: components.month!)
        
        let timeset = options["timeset"] as? [[String: [Int]]]
        var count = options["count"] as? Int
        
        var filters: [Filter] = []
        
        if let byMonth = options["bymonth"] as? [Int] {
            filters.append(ByMonth(byMonths: byMonth, context: context))
        }
        
        // TODO: Implement after ByWeekNumber is fixed
//        if let byWeekNo = options["byweekno"] as? [Int] {
//            filters.append(ByWeekNumber(byWeekNumbers: byWeekNo, context: context))
//        }

        if let byWeekDay = options["byweekday"] as? [Weekday] {
            filters.append(ByWeekDay(weekdays: byWeekDay, context: context))
        }

        if let byYearDay = options["byyearday"] as? [Int] {
            filters.append(ByYearDay(byYearDays: byYearDay, context: context))
        }

        if let byMonthDay = options["bymonthday"] as? [Int] {
            filters.append(ByMonthDay(byMonthDays: byMonthDay, context: context))
        }
        
        let generator: Generator = options["bysetpos"] != nil ? BySetPosition(bySetPositions: options["bysetpos"] as! [Int], context: context) : AllOccurrences(context: context)
        
        let frequencyType = try! Frequency.forOptions(options)
        let frequency = frequencyType.init(context: context, filters: filters, generator: generator, timeset: timeset ?? [], startDate: currentDate)
        
        return AnyIterator {
            while true {
                guard let year = calendar.dateComponents([.year], from: currentDate!).year, year <= self.maxYear else {
                     return nil
                }
                
                let nextOccurrences = frequency.nextOccurrences()
                for occurrence in nextOccurrences {
                    if occurrence >= self.dtstart,
                       currentDate == nil || occurrence >= currentDate!,
                       let until = self.options["until"] as? Date, occurrence <= until,
                       !self.exdate.contains(occurrence) {
                        
                        currentDate = occurrence
                        return occurrence
                    }
                }
                // Update `currentDate` to the next date according to frequency, not to get stuck in an infinite loop
                // This requires adjusting your `Frequency` class to support advancing to the next date without generating occurrences
                guard let nextDate = frequency.advance(currentDate) else {
                    return nil
                }
                currentDate = nextDate
            }
        }
    }
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
            let parts = param.split(separator: "=")
            guard parts.count == 2, let option = parts.first, let value = parts.last else { continue }
            
            switch option {
            case "FREQ":
                options["freq"] = String(value)
            case "COUNT":
                if let i = Int(value), i >= 0 {
                    options["count"] = i
                } else {
                    throw InvalidRRule(reason: "COUNT must be a non-negative integer")
                }
            case "UNTIL":
                // The value of the UNTIL rule part MUST have the same value type as the "DTSTART" property.
                options["until"] = DateFormatter().date(from: String(value))
            case "INTERVAL":
                if let i = Int(value), i > 0 {
                    options["interval"] = i
                } else {
                    throw InvalidRRule(reason: "INTERVAL must be a positive integer")
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

    func next() -> Date? {
        return self.dateIterator?.next()
    }
    
    func countOrIntervalPresent() -> Bool {
        if let count = options["count"] as? Int, count > 0 {
            return true
        }
        
        if let interval = options["interval"] as? Int, interval > 1 {
            return true
        }
        
        return false
    }
}

// To conform to `Sequence`, you'll need an iterator
extension Rule: Sequence {
    func makeIterator() -> RuleIterator {
        return RuleIterator(rule: self, floorDate: nil)
    }
    
    // A convenience method to create an iterator starting from a specific floor date
    func makeIterator(from floorDate: Date) -> RuleIterator {
        return RuleIterator(rule: self, floorDate: floorDate)
    }
}

// Defines an iterator for Rule
struct RuleIterator: IteratorProtocol {
    let rule: Rule
    var currentFloorDate: Date?
    var generatedDates: [Date]
    var currentIndex = 0
    
    init(rule: Rule, floorDate: Date?) {
        self.rule = rule
        self.currentFloorDate = floorDate
        self.generatedDates = rule.each(floorDate: floorDate)
    }
    
    mutating func next() -> Date? {
        guard currentIndex < generatedDates.count else { return nil }
        let nextDate = generatedDates[currentIndex]
        currentIndex += 1
        return nextDate
    }
}
