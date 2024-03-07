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
        // Assuming `rebuild` method sets the `dtstart` to Jan 1st of the given year.
        // Swift's Date handling does not have a direct equivalent of Ruby's `Time.parse`, and setting a specific year might need extra methods not shown here.
        // In a non leap year
//        context.dtstart = Calendar.current.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        XCTAssertEqual(context.yearLengthInDays, 365)

        // In a leap year
//        context.dtstart = Calendar.current.date(from: DateComponents(year: 2000, month: 1, day: 1))!
//        XCTAssertEqual(context.yearLengthInDays, 366)
    }
    
//    func testElapsedDaysInYearByMonthForLeapYear() {
//        // Setup for leap year
////        context.rebuild(year: 2000, month: 1)
//        let elapsedDays = context.elapsedDaysInYearByMonth!
//
//        // Test the first few months to match the leap year pattern
//        XCTAssertEqual(elapsedDays[0], 0, "The first value should be 0.")
//        XCTAssertEqual(elapsedDays[1], 31, "The second value should be 31 for January.")
//        XCTAssertEqual(elapsedDays[2], 60, "The third value should be 60 for February in a leap year.")
//        XCTAssertEqual(elapsedDays[3], 91, "The fourth value should be 91 for March in a leap year.")
//    }

    func testElapsedDaysInYearByMonthForNonLeapYear() {
        // Setup for non-leap year
//        context.rebuild(year: 1997, month: 1)
        let elapsedDays = context.elapsedDaysInYearByMonth!

        // Test the first few months to match the non-leap year pattern
        XCTAssertEqual(elapsedDays[0], 0, "The first value should be 0.")
        XCTAssertEqual(elapsedDays[1], 31, "The second value should be 31 for January.")
        XCTAssertEqual(elapsedDays[2], 59, "The third value should be 59 for February in a non-leap year.")
        XCTAssertEqual(elapsedDays[3], 90, "The fourth value should be 90 for March in a non-leap year.")
    }
    
    func testFirstWeekdayOfYear() {
//        // Setup
//        let year = 2022 // Use an example year where January 1st is a Wednesday
//        let context = Context(year: year)
//        
        // Execute & Verify
        XCTAssertEqual(context.firstWeekdayOfYear, 3, "The first weekday of the year should be 3 (Wednesday).")
    }
    
    func testFirstDayOfYear() {
        // Setup
//        let context = Context(year: 1997)
        
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
//        let context = Context(year: 2022) // Choose a year that starts on a Wednesday
        // It's important to choose a year that matches the expected sequence
        // For this example, 2022 is just a placeholder and likely needs to be adjusted

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
}

