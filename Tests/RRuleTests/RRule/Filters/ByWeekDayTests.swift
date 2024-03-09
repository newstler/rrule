//
//  ByWeekDayTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

class ByWeekDayTests: XCTestCase {
    var context: Context!

    override func setUp() {
        super.setUp()
        // Setup the context with specified options and start date
        let options: [String: Any] = ["freq": "WEEKLY", "count": 4]
        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        context = Context(options: options, dtstart: startDate, tz: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1997, month: 1)
    }
    
    func testRejectForFridayOfTheWeek() {
        guard let tuesday = Weekday.parse("TU"), let friday = Weekday.parse("FR") else {
            XCTFail("Failed to parse weekdays")
            return
        }
        let byWeekDay = ByWeekDay(weekdays: [tuesday, friday], context: context)
        let date = DateComponents(calendar: .current, year: 1997, month: 1, day: 3).date!
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)! - 1
        
        XCTAssertFalse(byWeekDay.reject(index: dayOfYear))
    }
    
    func testRejectForSaturdayOfTheWeek() {
        guard let tuesday = Weekday.parse("TU"), let friday = Weekday.parse("FR") else {
            XCTFail("Failed to parse weekdays")
            return
        }
        let byWeekDay = ByWeekDay(weekdays: [tuesday, friday], context: context)
        let date = DateComponents(calendar: .current, year: 1997, month: 1, day: 4).date!
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)! - 1
        
        XCTAssertTrue(byWeekDay.reject(index: dayOfYear))
    }
    
    func testRejectForTuesdayOfTheNextWeek() {
        guard let tuesday = Weekday.parse("TU"), let friday = Weekday.parse("FR") else {
            XCTFail("Failed to parse weekdays")
            return
        }
        let byWeekDay = ByWeekDay(weekdays: [tuesday, friday], context: context)
        let date = DateComponents(calendar: .current, year: 1997, month: 1, day: 7).date!
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date)! - 1
        
        XCTAssertFalse(byWeekDay.reject(index: dayOfYear))
    }
}

