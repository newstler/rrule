//
//  Rule.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Rule: Sequence {
    let dtstart: Date
    let tz: TimeZone
    let rrule: String
    let exdate: [Date]
    var options: [String: Any] = [:] // Assuming options is a dictionary of parsed RRULE components
    var frequencyType: Frequency.Type? // Using a static type reference to the Frequency class or its subclasses
    let maxYear: Int
    let maxDate: Date
    var calendar: Calendar = Calendar.current
    
    private var _internalIterator: RuleIterator?
    func next() -> Date? {
        // Ensure the iterator is only created once and reused
        if _internalIterator == nil {
            _internalIterator = makeIterator()
        }
        return _internalIterator?.next()
    }
    
    func makeIterator() -> RuleIterator {
        RuleIterator(rule: self)
    }
    
    func makeIterator(startDate: Date) -> RuleIterator {
        RuleIterator(rule: self, startDate: startDate)
    }

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
    
    
    func all(limit: Int? = nil) -> [Date] {
        return allUntil(limit: limit)
    }
    
    func between(startDate: Date, endDate: Date, limit: Int? = nil) -> [Date] {
        return allUntil(startDate: startDate.floorToSeconds(in: tz), endDate: endDate.floorToSeconds(in: tz), limit: limit).filter { $0 >= startDate.floorToSeconds(in: tz) }
    }

    func from(startDate: Date, limit: Int) -> [Date] {
        return allUntil(startDate: startDate.floorToSeconds(in: tz), endDate: maxDate, limit: limit).filter { $0 >= startDate.floorToSeconds(in: tz) }
    }
    
    func allUntil(startDate: Date? = nil, endDate: Date? = nil, limit: Int? = 31) -> [Date] {
        var results: [Date] = []
        let maxResults = limit ?? Int.max
        var iterator = startDate != nil ? makeIterator(startDate: startDate!) : makeIterator()
        
        while let nextDate = iterator.next(), nextDate <= (endDate ?? maxDate) {
            results.append(nextDate)
            if results.count >= maxResults {
                break
            }
        }
        
        return results
    }

    
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
        
        return options
    }
}

class RuleIterator: IteratorProtocol {
    private let rule: Rule
    private var currentDate: Date
    private let context: Context
    private let timeset: [[String: [Int]]]?
    private var count: Int?
    private var filters: [Filter] = []
    private let generator: Generator
    private let frequency: Frequency // Assuming Frequency is a class you have that can generate dates
    
    init(rule: Rule, startDate: Date? = nil) {
        self.rule = rule
        
        // Determine whether to use the provided startDate or fall back to rule.dtstart,
        // and apply flooring to seconds as necessary.
        let useRuleStart = startDate == nil || rule.dtstart > startDate! || countOrIntervalPresent()

        // If any condition is met, use rule.dtstart, floored to seconds in the rule's timezone;
        // otherwise, use the provided startDate, also considering flooring to seconds.
        self.currentDate = useRuleStart ? rule.dtstart.floorToSeconds(in: rule.tz) : startDate!.floorToSeconds(in: rule.tz)
        
        // Initialize Context, Filters, Frequency, count, and any other necessary properties here
        self.context = Context(options: rule.options, dtstart: rule.dtstart, tz: rule.tz)
        let components = rule.calendar.dateComponents([.year, .month], from: currentDate)
        context.rebuild(year: components.year!, month: components.month!)
        
        self.timeset = rule.options["timeset"] as? [[String: [Int]]]
        self.count = rule.options["count"] as? Int
        
        if let byMonth = rule.options["bymonth"] as? [Int] {
            self.filters.append(ByMonth(byMonths: byMonth, context: context))
        }
        
        // TODO: Implement after ByWeekNumber is fixed
//        if let byWeekNo = rule.options["byweekno"] as? [Int] {
//            self.filters.append(ByWeekNumber(byWeekNumbers: byWeekNo, context: context))
//        }

        if let byWeekDay = rule.options["byweekday"] as? [Weekday] {
            self.filters.append(ByWeekDay(weekdays: byWeekDay, context: context))
        }

        if let byYearDay = rule.options["byyearday"] as? [Int] {
            self.filters.append(ByYearDay(byYearDays: byYearDay, context: context))
        }

        if let byMonthDay = rule.options["bymonthday"] as? [Int] {
            self.filters.append(ByMonthDay(byMonthDays: byMonthDay, context: context))
        }
        
        self.generator = rule.options["bysetpos"] != nil ? BySetPosition(bySetPositions: rule.options["bysetpos"] as! [Int], context: context) : AllOccurrences(context: context)
        
        let frequencyType = (try? Frequency.forOptions(rule.options)) ?? Monthly.self
        self.frequency = frequencyType.init(context: context, filters: filters, generator: generator, timeset: timeset ?? [], startDate: currentDate)
    }
    
    func next() -> Date? {
        guard !finished, let frequency = frequency else { return nil }
        
        
        // Ensure that the logic handles returning nil if there are no more dates to generate
        while let nextDate = frequency.nextOccurrences() {
            // Check if nextDate is before the start date
            if nextDate < rule.dtstart {
                continue
            }
            // Check if floorDate is set and nextDate is before floorDate
            if let floorDate = rule.floorDate, nextDate < floorDate {
                continue
            }
            // Check if nextDate is after the until option
            if nextDate > rule.maxDate {
                return nil
            }
            // Decrement count and check if we've reached the limit
            if let count = self.count, count <= 0 {
                return nil
            } else {
                self.count? -= 1
            }
            // Check if nextDate is in the exclusion list
            if rule.exdate.contains(nextDate) {
                continue
            }
            // Successfully found the next valid date
            self.currentDate = nextDate
            return nextDate
        }
        return nil
    }
    
//    func next() -> Date? {
//        guard !finished, let frequency = frequency else { return nil }
//
//        while let nextDate = frequency.nextOccurrence(after: current), nextDate <= rule.maxDate {
//            self.current = nextDate
//            if rule.isValid(date: nextDate) {
//                decrementCountIfNeeded()
//                if self.count <= 0 {
//                    finished = true
//                }
//                return nextDate
//            }
//        }
//        finished = true
//        return nil
//    }
//    
    private func decrementCountIfNeeded() {
        if rule.options["count"] != nil {
            count -= 1
        }
    }
    
    
//    
//    func each(floorDate: Date? = nil, _ block: ((Date) -> Void)? = nil) -> AnyIterator<Date?> {
//        var currentDate = floorDate
//        
//        // If we have a COUNT or INTERVAL option, or floorDate is nil, or dtstart is after floorDate, we start from dtstart
//        if countOrIntervalPresent() || currentDate == nil || dtstart > currentDate! {
//            currentDate = dtstart
//        }
//        
////        guard let block = block else {
////            // If no block is provided, we might want to return an enumerator or handle differently
////            return
////        }
//        
//        let context = Context(options: options, dtstart: dtstart, tz: tz)
//        let components = calendar.dateComponents([.year, .month], from: currentDate!)
//        context.rebuild(year: components.year!, month: components.month!)
//        
//        let timeset = options["timeset"] as? [[String: [Int]]]
//        var count = options["count"] as? Int
//        
//        var filters: [Filter] = []
//        
//        if let byMonth = options["bymonth"] as? [Int] {
//            filters.append(ByMonth(byMonths: byMonth, context: context))
//        }
//        
//        // TODO: Implement after ByWeekNumber is fixed
////        if let byWeekNo = options["byweekno"] as? [Int] {
////            filters.append(ByWeekNumber(byWeekNumbers: byWeekNo, context: context))
////        }
//
//        if let byWeekDay = options["byweekday"] as? [Weekday] {
//            filters.append(ByWeekDay(weekdays: byWeekDay, context: context))
//        }
//
////        if let byYearDay = options["byyearday"] as? [Int] {
////            filters.append(ByYearDay(byYearDays: byYearDay, context: context))
////        }
//
//        if let byMonthDay = options["bymonthday"] as? [Int] {
//            filters.append(ByMonthDay(byMonthDays: byMonthDay, context: context))
//        }
//        
//        let generator: Generator = options["bysetpos"] != nil ? BySetPosition(bySetPositions: options["bysetpos"] as! [Int], context: context) : AllOccurrences(context: context)
//        
//        let frequencyType = (try? Frequency.forOptions(options)) ?? Monthly.self
//        let frequency = frequencyType.init(context: context, filters: filters, generator: generator, timeset: timeset ?? [], startDate: currentDate)
//        
//        return AnyIterator<Date?> {
//            while true {
//                guard let year = calendar.dateComponents([.year], from: currentDate!).year, year <= self.maxYear else {
//                     return
//                }
//                
//                let nextOccurrences = frequency.nextOccurrences()
//                for occurrence in nextOccurrences {
//                    if occurrence >= self.dtstart,
//                       currentDate == nil || occurrence >= currentDate!,
//                       let until = self.options["until"] as? Date, occurrence <= until,
//                       !self.exdate.contains(occurrence) {
//                        
//                        currentDate = occurrence
//                        return occurrence
//                    }
//                }
//                // Update `currentDate` to the next date according to frequency, not to get stuck in an infinite loop
//                // This requires adjusting your `Frequency` class to support advancing to the next date without generating occurrences
//                guard let nextDate = frequency.advance(currentDate) else {
//                    return nil
//                }
//                currentDate = nextDate
//            }
//        }
//    }
    
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

