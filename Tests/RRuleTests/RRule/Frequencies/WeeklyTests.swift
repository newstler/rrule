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
    var timeset: [[String: [Int]]]!
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!

    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()

    override func setUp() {
        super.setUp()
        let components = DateComponents(year: 1997, month: 1, day: 1)
        guard let date = calendar.date(from: components) else {
            XCTFail("Failed to create the start date")
            return
        }
        context = Context(options: ["interval": 1, "wkst": 1], dtstart: date, tz: timeZone)
        generator = AllOccurrences(context: context)
        timeset = [["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]]
        weeklyFrequency = Weekly(context: context, filters: [], generator: generator, timeset: timeset)

        // Correctly extracting year and month components for the rebuild call
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        context.rebuild(year: year, month: month)
    }

    func testOccurrencesEveryWeek() {
        let startDate = context.dtstart
        var expectedDates: [Date] = []
        for weekOffset in 0..<3 {
            expectedDates.append(addWeeksToDate(startDate, weeks: weekOffset))
        }

        let results = (0..<3).map { _ in weeklyFrequency.nextOccurrences() }.flatMap { $0 }
        XCTAssertEqual(results, expectedDates, "Expected sequential weekly occurrences did not match")
    }

    // Helper method to add weeks to a date
    private func addWeeksToDate(_ date: Date, weeks: Int) -> Date {
        return calendar.date(byAdding: .day, value: 7 * weeks, to: date)!
    }
}

