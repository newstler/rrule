//
//  SimpleWeeklyTests.swift
//  
//
//  Created by Yuri Sidorov on 09.03.2024.
//

import XCTest
@testable import RRule

class SimpleWeeklyTests: XCTestCase {
    var context: Context!
    var simpleWeeklyFrequency: SimpleWeekly!
    var generator: AllOccurrences!
    var timeset: [[String: [Int]]] = []
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()
    
    func testOccurrencesEveryWeek() {
        let date = DateComponents(calendar: calendar, year: 1997, month: 1, day: 1).date!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        timeset = [["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]]
        simpleWeeklyFrequency = SimpleWeekly(context: context, filters: [], generator: AllOccurrences(context: context), timeset: timeset)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 7, to: date)!])
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 14, to: date)!])
    }
    
    func testOccurrencesEveryWeekWithNoTimeset() {
        let date = DateComponents(calendar: calendar, year: 1997, month: 1, day: 1).date!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        simpleWeeklyFrequency = SimpleWeekly(context: context, filters: [], generator: AllOccurrences(context: context), timeset: [])
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 7, to: date)!])
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 14, to: date)!])
    }
    
    func testOccurrencesEveryOtherWeek() {
        let date = DateComponents(calendar: calendar, year: 1997, month: 1, day: 1).date!
        context = Context(options: ["interval": 2], dtstart: date, tz: timeZone)
        let timeset: [[String: [Int]]] = [
            ["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]
        ]
        simpleWeeklyFrequency = SimpleWeekly(context: context, filters: [], generator: AllOccurrences(context: context), timeset: timeset)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 14, to: date)!])
        XCTAssertEqual(simpleWeeklyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 28, to: date)!])
    }
}

