//
//  ContextTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

class ContextTests: XCTestCase {
    var context: Context!

    override func setUp() {
        super.setUp()
        context = Context(
            options: ["freq": "DAILY", "count": 3],
            dtstart: Date(timeIntervalSince1970: 872668800), // Equivalent to Tue Sep  2 06:00:00 PDT 1997
            tz: TimeZone(identifier: "America/Los_Angeles")!
        )
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func testYearLengthInDays() {
        // In a non leap year
        context.rebuild(year: 1997, month: 1)
        XCTAssertEqual(context.yearLengthInDays, 365)

        // In a leap year
        context.rebuild(year: 2000, month: 1)
        XCTAssertEqual(context.yearLengthInDays, 366)
    }
    
    func testElapsedDaysInYearByMonthForLeapYear() {
        // Setup for leap year
        context.rebuild(year: 2000, month: 1)
        let elapsedDays = context.elapsedDaysInYearByMonth!

        // Test the first few months to match the leap year pattern
        XCTAssertEqual(elapsedDays[0], 0, "The first value should be 0.")
        XCTAssertEqual(elapsedDays[1], 31, "The second value should be 31 for January.")
        XCTAssertEqual(elapsedDays[2], 60, "The third value should be 60 for February in a leap year.")
        XCTAssertEqual(elapsedDays[3], 91, "The fourth value should be 91 for March in a leap year.")
    }

    func testElapsedDaysInYearByMonthForNonLeapYear() {
        // Setup for non-leap year
        context.rebuild(year: 1997, month: 1)
        let elapsedDays = context.elapsedDaysInYearByMonth!

        // Test the first few months to match the non-leap year pattern
        XCTAssertEqual(elapsedDays[0], 0, "The first value should be 0.")
        XCTAssertEqual(elapsedDays[1], 31, "The second value should be 31 for January.")
        XCTAssertEqual(elapsedDays[2], 59, "The third value should be 59 for February in a non-leap year.")
        XCTAssertEqual(elapsedDays[3], 90, "The fourth value should be 90 for March in a non-leap year.")
    }
    
    func testFirstWeekdayOfYear() {
        context.rebuild(year: 1997, month: 1)
        XCTAssertEqual(context.firstWeekdayOfYear, 3, "The first weekday of the year should be 3 (Wednesday).")
    }
    
    func testFirstDayOfYear() {
        // Setup
        context.rebuild(year: 1997, month: 1)
        
        // Use Calendar to construct the expected date for comparison
        var components = DateComponents()
        components.year = 1997
        components.month = 1
        components.day = 1
        let calendar = Calendar.current
        let expectedDate = calendar.date(from: components)!
        
        // Execute & Verify
        guard let firstDayOfYear = context.firstDayOfYear else {
            XCTFail("firstDayOfYear was nil")
            return
        }
        XCTAssertEqual(calendar.compare(firstDayOfYear, to: expectedDate, toGranularity: .day), .orderedSame, "The first day of the year should be January 1st, 1997.")
    }
    
    func testWeekdayByDayOfYearStartsWithExpectedSequence() {
        // Set up
        context.rebuild(year: 1997, month: 1) // Choose a year that starts on a Wednesday

        // Execute
        guard let weekdayByDayOfYear = context.weekdayByDayOfYear else {
            XCTFail("weekdayByDayOfYear was nil")
            return
        }
        
        let sequence = weekdayByDayOfYear.prefix(7)
        
        // Verify
        let expectedSequence = [3, 4, 5, 6, 0, 1, 2] // Starting from Wednesday
        XCTAssertEqual(Array(sequence), expectedSequence, "The sequence should start with [3, 4, 5, 6, 0, 1, 2].")
    }
    
    func testDayOfYearWithinRangePositiveOrdinal() {
        context.rebuild(year: 1997, month: 1)

        // Example: Test for 2nd Tuesday of January (assuming Jan 1 is a Wednesday)
        let weekday = Weekday(index: 2, ordinal: 2) // Tuesday
        let result = context.dayOfYearWithinRange(weekday: weekday, yearDayStart: 1, yearDayEnd: 31)
        XCTAssertEqual(result, 13, "Expected to find the 2nd Tuesday on the 14th of January")
    }

    func testDayOfYearWithinRangeNegativeOrdinal() {
        context.rebuild(year: 1997, month: 1)

        // Example: Test for last Friday of January
        let weekday = Weekday(index: 5, ordinal: -1) // Friday
        let result = context.dayOfYearWithinRange(weekday: weekday, yearDayStart: 1, yearDayEnd: 31)
        XCTAssertEqual(result, 30, "Expected to find the last Friday on the 30th of January")
    }

    func testDayOfYearWithinRangeOutOfRange() {
        context.rebuild(year: 1997, month: 1)

        // Test for a day that does not exist (5th Monday of February, for example)
        let weekday = Weekday(index: 1, ordinal: 5) // Monday
        let result = context.dayOfYearWithinRange(weekday: weekday, yearDayStart: 32, yearDayEnd: 59) // February
        XCTAssertNil(result, "Expected no result for a 5th Monday in February")
    }
}

