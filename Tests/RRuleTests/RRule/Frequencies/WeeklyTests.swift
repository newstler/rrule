//
//  WeeklyTests.swift
//  
//
//  Created by Yuri Sidorov on 10.03.2024.
//

import XCTest
@testable import RRule

class WeeklyTests: XCTestCase {
    var context: Context!
    var weeklyFrequency: Weekly!
    var generator: AllOccurrences!
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    var date: Date!
    var timeset: [[String: [Int]]]!
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()

    func addWeeksToDate(_ date: Date, weeks: Int) -> Date {
        return calendar.date(byAdding: .day, value: 7 * weeks, to: date)!
    }

    func testOccurrences(interval: Int, date: Date) -> [Date] {
        context = Context(options: ["interval": interval, "wkst": 1], dtstart: date, tz: timeZone)
        let components = calendar.dateComponents([.year, .month], from: date)
        generator = AllOccurrences(context: context)
        timeset = [["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]]
        let filter = ByWeekDay(weekdays: [Weekday(index: calendar.component(.weekday, from: date) - 1, ordinal: nil)], context: context)
        weeklyFrequency = Weekly(context: context, filters: [filter], generator: generator, timeset: timeset)
        context.rebuild(year: components.year!, month: components.month!)

        let results = (1...3).map { _ in weeklyFrequency.nextOccurrences() }.flatMap { $0 }
        return results
    }
    
    func testOccurrencesEveryWeek() {
        date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        let expectedDates = [0, 1, 2].map { addWeeksToDate(date, weeks: $0) }
        XCTAssertEqual(testOccurrences(interval: 1, date: date), expectedDates)
    }
    
    func testOccurrencesEveryTwoWeeks() {
        date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        let expectedDates = [0, 2, 4].map { addWeeksToDate(date, weeks: $0) }
        XCTAssertEqual(testOccurrences(interval: 2, date: date), expectedDates)
    }
    
    func testFirstDayOfYearWithFiveDaysLeftInWeek() {
        date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        let expectedDates = [0, 1, 2].map { addWeeksToDate(date, weeks: $0) }
        XCTAssertEqual(testOccurrences(interval: 1, date: date), expectedDates)
    }

    func testDayInFirstMonthWithTwoDaysLeftInWeek() {
        date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 25))!
        let expectedDates = [date, addWeeksToDate(date, weeks: 1), addWeeksToDate(date, weeks: 2)].map { $0 }
        XCTAssertEqual(testOccurrences(interval: 1, date: date), expectedDates)
    }

    func testDayInNextMonthWithSixDaysLeftInWeek() {
        date = calendar.date(from: DateComponents(year: 1997, month: 2, day: 25))!
        let expectedDates = [date, addWeeksToDate(date, weeks: 1), addWeeksToDate(date, weeks: 2)].map { $0 }
        XCTAssertEqual(testOccurrences(interval: 1, date: date), expectedDates)
    }

    func testLastDayOfFebruary() {
        date = calendar.date(from: DateComponents(year: 1997, month: 2, day: 28))!
        let expectedDates = [date, addWeeksToDate(date, weeks: 1), addWeeksToDate(date, weeks: 2)].map { $0 }
        XCTAssertEqual(testOccurrences(interval: 1, date: date), expectedDates)
    }

    func testLastDayOfYear() {
        date = calendar.date(from: DateComponents(year: 1997, month: 12, day: 31))!
        let expectedDates = [date, addWeeksToDate(date, weeks: 1), addWeeksToDate(date, weeks: 2)].map { $0 }
        XCTAssertEqual(testOccurrences(interval: 1, date: date), expectedDates)
    }

}

