//
//  YearlyTests.swift
//  
//
//  Created by Yuri Sidorov on 10.03.2024.
//

import XCTest
@testable import RRule

class YearlyTests: XCTestCase {
    var context: Context!
    var yearlyFrequency: Yearly!
    var generator: AllOccurrences!
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    var date: Date!
    var timeset: [[String: [Int]]]!
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()

    func addYearsToDate(_ date: Date, years: Int) -> Date {
        return calendar.date(byAdding: .year, value: years, to: date)!
    }

    func testOccurrences(interval: Int, date: Date, iterationsCount: Int) -> [Date] {
        context = Context(options: ["interval": interval, "wkst": 1], dtstart: date, tz: timeZone)
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        generator = AllOccurrences(context: context)
        timeset = [["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]]
        let filters = [ByMonth(byMonths: [components.month!], context: context), ByMonthDay(byMonthDays: [components.day!], context: context)] as [any Filter]
        yearlyFrequency = Yearly(context: context, filters: filters, generator: generator, timeset: timeset)
        context.rebuild(year: components.year!, month: components.month!)

        let results = (1...iterationsCount).map { _ in yearlyFrequency.nextOccurrences() }.flatMap { $0 }
        return results
    }

    func testNextOccurrencesOnFirstDayOfYear() {
        date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        let expectedDates = [0, 1, 2].map { addYearsToDate(date, years: $0) }
        XCTAssertEqual(testOccurrences(interval: 1, date: date, iterationsCount: expectedDates.count), expectedDates)
    }

    func testNextOccurrencesOnLastDayOfFebruaryInLeapYear() {
        date = calendar.date(from: DateComponents(year: 2000, month: 2, day: 29))!
        let expectedDates = [date, addYearsToDate(date, years: 4)]
        XCTAssertEqual(testOccurrences(interval: 1, date: date, iterationsCount: 5), expectedDates)
    }

    func testNextOccurrencesWithIntervalOfTwo() {
        date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        let expectedDates = [0, 2, 4].map { addYearsToDate(date, years: $0) }
        XCTAssertEqual(testOccurrences(interval: 2, date: date, iterationsCount: expectedDates.count), expectedDates)
    }
}

