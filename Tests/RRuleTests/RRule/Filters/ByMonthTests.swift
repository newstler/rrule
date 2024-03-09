//
//  ByMonthTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

class ByMonthTests: XCTestCase {
    var context: Context!
    
    override func setUp() {
        super.setUp()
        let options: [String: Any] = ["freq": "MONTHLY", "count": 4]
        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        context = Context(options: options, dtstart: startDate, tz: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1997, month: 1)
    }
    
    func testRejectForDayInJanuary() {
        let byMonth = ByMonth(byMonths: [1, 3], context: context)
        let date = DateComponents(calendar: .current, year: 1997, month: 1, day: 15).date!
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)!
        
        XCTAssertFalse(byMonth.reject(index: dayOfYear - 1))
    }
    
    func testRejectForDayInFebruary() {
        let byMonth = ByMonth(byMonths: [1, 3], context: context)
        let date = DateComponents(calendar: .current, year: 1997, month: 2, day: 15).date!
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)!
        
        XCTAssertTrue(byMonth.reject(index: dayOfYear - 1))
    }
    
    func testRejectForDayInMarch() {
        let byMonth = ByMonth(byMonths: [1, 3], context: context)
        let date = DateComponents(calendar: .current, year: 1997, month: 3, day: 15).date!
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date)!
        
        XCTAssertFalse(byMonth.reject(index: dayOfYear - 1))
    }
}

