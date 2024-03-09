//
//  ByMonthDayTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

class ByMonthDayTests: XCTestCase {
    var context: Context!

    override func setUp() {
        super.setUp()
        // Setup the context with specified options and start date
        let options: [String: Any] = ["freq": "MONTHLY", "count": 4]
        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        context = Context(options: options, dtstart: startDate, tz: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1997, month: 1)
    }
    
    func testRejectForTheThirdDayOfTheMonth() {
        let byMonthDay = ByMonthDay(byMonthDays: [3, -3], context: context)
        // January 3, 1997, should not be rejected as it is explicitly included
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: DateComponents(calendar: .current, year: 1997, month: 1, day: 3).date!)!
        XCTAssertFalse(byMonthDay.reject(index: dayOfYear - 1)) // Adjusting index for zero-based array
    }

    func testRejectForTheFourthDayOfTheMonth() {
        let byMonthDay = ByMonthDay(byMonthDays: [3, -3], context: context)
        // January 4, 1997, should be rejected as it is not explicitly included
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: DateComponents(calendar: .current, year: 1997, month: 1, day: 4).date!)!
        XCTAssertTrue(byMonthDay.reject(index: dayOfYear - 1)) // Adjusting index for zero-based array
    }

    func testRejectForTheThirdToLastDayOfTheMonth() {
        let byMonthDay = ByMonthDay(byMonthDays: [3, -3], context: context)
        // January 29, 1997, should not be rejected as it is the third-to-last day
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: DateComponents(calendar: .current, year: 1997, month: 1, day: 29).date!)!
        XCTAssertFalse(byMonthDay.reject(index: dayOfYear - 1)) // Adjusting index for zero-based array
    }
}

