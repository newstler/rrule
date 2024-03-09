//
//  ByYearDayTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

class ByYearDayTests: XCTestCase {
    var context: Context!

    override func setUp() {
        super.setUp()
        // Setup the context with specified options and start date
        let options: [String: Any] = ["freq": "YEARLY", "count": 4]
        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        context = Context(options: options, dtstart: startDate, tz: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1997, month: 1)
    }
    
    func testRejectForThe45thDayOfTheYear() {
        let byYearDay = ByYearDay(byYearDays: [45, -45], context: context)
        // February 14, 1997, is the 45th day of the year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: DateComponents(calendar: .current, year: 1997, month: 2, day: 14).date!)! - 1
        
        XCTAssertFalse(byYearDay.reject(index: dayOfYear))
    }

    func testRejectForThe60thDayOfTheYear() {
        let byYearDay = ByYearDay(byYearDays: [45, -45], context: context)
        // March 1, 1997, is the 60th day of the year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: DateComponents(calendar: .current, year: 1997, month: 3, day: 1).date!)! - 1
        
        XCTAssertTrue(byYearDay.reject(index: dayOfYear))
    }

    func testRejectForThe45thFromLastDayOfTheYear() {
        let byYearDay = ByYearDay(byYearDays: [45, -45], context: context)
        // November 17, 1997, is the 45th-from-last day of the year
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: DateComponents(calendar: .current, year: 1997, month: 11, day: 17).date!)! - 1
        
        XCTAssertFalse(byYearDay.reject(index: dayOfYear))
    }
}

