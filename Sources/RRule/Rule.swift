//
//  Rule.swift
//
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

public class Rule: Sequence {
    let dtstart: Date
    let tz: TimeZone
    let rrule: String
    let exdate: [Date]
    var options: [String: Any] = [:] // Assuming options is a dictionary of parsed RRULE components
    let maxYear: Int
    let maxDate: Date
    var calendar: Calendar = .current
    
    private var _internalIterator: RuleIterator?
    func next() -> Date? {
        // Ensure the iterator is only created once and reused
        if _internalIterator == nil {
            _internalIterator = makeIterator()
        }
        return _internalIterator?.next()
    }
    
    public func makeIterator() -> RuleIterator {
        RuleIterator(rule: self)
    }
    
    public func makeIterator(startDate: Date) -> RuleIterator {
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
    }
    
    
    public func all(limit: Int? = nil) -> [Date] {
        return allUntil(limit: limit)
    }
    
    public func between(startDate: Date, endDate: Date, limit: Int? = nil) -> [Date] {
        return allUntil(startDate: startDate.floorToSeconds(in: tz), endDate: endDate.floorToSeconds(in: tz), limit: limit).filter { $0 >= startDate.floorToSeconds(in: tz) }
    }

    public func from(startDate: Date, limit: Int) -> [Date] {
        return allUntil(startDate: startDate.floorToSeconds(in: tz), endDate: maxDate, limit: limit).filter { $0 >= startDate.floorToSeconds(in: tz) }
    }
    
    func allUntil(startDate: Date? = nil, endDate: Date? = nil, limit: Int? = 31) -> [Date] {
        var results: [Date] = []
        let maxResults = limit ?? Int.max
        let iterator = startDate != nil ? makeIterator(startDate: startDate!) : makeIterator()
        
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
                options["until"] = parseDateString(String(value)) //DateFormatter().date(from: String(value))
                
//                if let until = dict["UNTIL"] {
//                    if let untilDate = parseDateString(until) {
//                        text += "\n" + String(localized: "until \(formatDate(untilDate))")
//                    }
//                }
            case "INTERVAL":
                if let i = Int(value), i > 0 {
                    options["interval"] = i
                } else {
                    throw InvalidRRule(reason: "INTERVAL must be a positive integer")
                }
            case "BYHOUR", "BYMINUTE", "BYSECOND", "BYSETPOS", "BYMONTH", "BYMONTHDAY", "BYWEEKNO", "BYYEARDAY":
                options[String(option).lowercased()] = value.split(separator: ",").compactMap { Int($0) }
            case "BYDAY":
                options["byweekday"] = value.split(separator: ",").compactMap { Weekday.parse(String($0)) }
            case "WKST":
                options["wkst"] = RRule.weekdays.firstIndex(of: String(value))
            default:
                break
            }
        }
        
        if !(options.keys.contains("byweekno") ||
             options.keys.contains("byyearday") ||
             options.keys.contains("bymonthday") ||
             options.keys.contains("byweekday")) {
            
            switch options["freq"] as? String {
            case "YEARLY":
                if options["bymonth"] == nil {
                    options["bymonth"] = [calendar.component(.month, from: dtstart)]
                }
                options["bymonthday"] = [calendar.component(.day, from: dtstart)]
            case "MONTHLY":
                options["bymonthday"] = [calendar.component(.day, from: dtstart)]
            case "WEEKLY":
                options["simple_weekly"] = true
                let weekday = calendar.component(.weekday, from: dtstart)
                options["byweekday"] = [Weekday(index: weekday - 1)]
            default:
                break
            }
        }
        
        // Construct timeset only if time-related options are explicitly provided
        var timeset: [String: [Int]] = [:]
        
        if let byHour = options["byhour"] as? [Int], !byHour.isEmpty {
            timeset["hour"] = byHour
        } else {
             timeset["hour"] = [calendar.component(.hour, from: dtstart)]
        }

        if let byMinute = options["byminute"] as? [Int], !byMinute.isEmpty {
            timeset["minute"] = byMinute
        } else {
            timeset["minute"] = [calendar.component(.minute, from: dtstart)]
        }

        if let bySecond = options["bysecond"] as? [Int], !bySecond.isEmpty {
            timeset["second"] = bySecond
        } else {
             timeset["second"] = [calendar.component(.second, from: dtstart)]
        }
        
        // If any of byhour, byminute, or bysecond were provided, add timeset to options
        if !timeset.isEmpty {
            options["timeset"] = [timeset]
        }
        
        return options
    }
    
    private func parseDateString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.date(from: dateString)
    }
}

public class RuleIterator: IteratorProtocol {
    private let rule: Rule
    private var currentDate: Date
    private let context: Context
    private let timeset: [[String: [Int]]]?
    private var count: Int?
    private var filters: [Filter] = []
    private let generator: Generator
    private let frequency: Frequency // Assuming Frequency is a class you have that can generate dates
    private var occurrencesIterator: IndexingIterator<[Date]>?
    
    init(rule: Rule, startDate: Date? = nil) {
        self.rule = rule
        
        self.timeset = rule.options["timeset"] as? [[String: [Int]]]
        self.count = rule.options["count"] as? Int
        
        let interval: Int? = rule.options["interval"] as? Int
        
        // Determine whether to use the provided startDate or fall back to rule.dtstart,
        // and apply flooring to seconds as necessary.
        let useRuleStart = startDate == nil || rule.dtstart > startDate! || (count != nil && count! > 1) || (interval != nil && interval! > 1)
        
        // If any condition is met, use rule.dtstart, floored to seconds in the rule's timezone;
        // otherwise, use the provided startDate, also considering flooring to seconds.
        self.currentDate = useRuleStart ? rule.dtstart : startDate!.floorToSeconds(in: rule.tz)
        
        // Initialize Context, Filters, Frequency, count, and any other necessary properties here
        self.context = Context(options: rule.options, dtstart: rule.dtstart, tz: rule.tz)
        let components = rule.calendar.dateComponents([.year, .month], from: currentDate)
        context.rebuild(year: components.year!, month: components.month!)
        
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
        
        // Pre-load the first batch of occurrences
        self.occurrencesIterator = self.frequency.nextOccurrences().makeIterator()
    }
    
    public func next() -> Date? {
        // Check if the count limit has been reached before attempting to fetch new dates.
        if let countValue = count, countValue <= 0 {
            return nil // Stop if the limit of occurrences has been reached.
        }
        
        var lastValidDate: Date? = nil // To store the last valid date

        while let nextDate = occurrencesIterator?.next() {
            // Break the loop if the date is beyond the "until" date
            if let untilDate = rule.options["until"] as? Date, nextDate > untilDate {
                return nil
            }
            
            if nextDate >= rule.dtstart && nextDate <= (rule.options["until"] as? Date ?? rule.maxDate) {
                lastValidDate = nextDate // Update last valid date
                
                // Decrement the count because a valid date has been found.
                if var countValue = count {
                    // Ensure we have occurrences left to generate.
                    if countValue > 0 {
                        countValue -= 1 // Decrement count after confirming the date is valid.
                        count = countValue // Update the main count.
                    }
                    
                    // FIXME: Duplicating code
                    if rule.exdate.contains(nextDate) {
                        continue
                    }

                    if countValue == 0 {
                        // If count has reached zero after decrementing, return the current date and stop.
                        return nextDate
                    }
                }
                
                // FIXME: Duplicating code
                if rule.exdate.contains(nextDate) {
                    continue
                }
                return nextDate // Return the current date as it's valid and within bounds.
            }
        }
        
        // Check if more dates need to be generated
        if (lastValidDate == nil) || (lastValidDate != nil && (rule.options["until"] as? Date ?? rule.maxDate) > lastValidDate!) {
            let newOccurrences = frequency.nextOccurrences()
            if !newOccurrences.isEmpty {
                occurrencesIterator = newOccurrences.makeIterator()
                return next() // Recursive call to continue searching
            }
        }
        
        // If no more dates can be generated, return nil.
        return nil
    }



}
