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
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    var date: Date!
    var timeset: [[String: [Int]]]!
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()
    
    override func setUp() {
        super.setUp()
        date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        generator = AllOccurrences(context: context)
    }

    func addWeeksToDate(_ date: Date, weeks: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: 7 * weeks, to: date)!
    }

    func testOccurrences(interval: Int, expectedOccurrences: [Date]) {
        context.options["interval"] = interval
        timeset = [["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]]
        simpleWeeklyFrequency = SimpleWeekly(context: context, filters: [], generator: generator, timeset: [])
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)

        let results = (1...expectedOccurrences.count).map { _ in simpleWeeklyFrequency.nextOccurrences() }.flatMap { $0 }
        XCTAssertEqual(results, expectedOccurrences)
    }

    func testOccurrencesEveryWeek() {
        let startDate = context.dtstart
        let expectedDates = [0, 1, 2].map { addWeeksToDate(startDate, weeks: $0) }
        testOccurrences(interval: 1, expectedOccurrences: expectedDates)
    }

    func testOccurrencesEveryWeekWithNoTimeset() {
        simpleWeeklyFrequency = SimpleWeekly(context: context, filters: [], generator: generator, timeset: [])
        testOccurrencesEveryWeek()
    }

    func testOccurrencesEveryOtherWeek() {
        let startDate = context.dtstart
        let expectedDates = [0, 2, 4].map { addWeeksToDate(startDate, weeks: $0) }
        testOccurrences(interval: 2, expectedOccurrences: expectedDates)
    }
}
