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
        // Common setup for all tests, if any.
    }
    
    func testYearLengthInDaysNonLeapYear() {
        context = Context(options: ["freq": "DAILY", "count": 3], startDate: Date(timeIntervalSince1970: 852076800), timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1997, month: 1)
        
        XCTAssertEqual(context.yearLengthInDays, 365)
    }
    
    func testYearLengthInDaysLeapYear() {
        context = Context(options: ["freq": "DAILY", "count": 3], startDate: Date(timeIntervalSince1970: 852076800), timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 2000, month: 1)
        
        XCTAssertEqual(context.yearLengthInDays, 366)
    }
    
    func testNextYearLengthInDaysNotPriorToLeapYear() {
        context = Context(options: ["freq": "DAILY", "count": 3], startDate: Date(timeIntervalSince1970: 852076800), timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1997, month: 1)
        
        XCTAssertEqual(context.nextYearLengthInDays, 365)
    }
    
    func testNextYearLengthInDaysPriorToLeapYear() {
        context = Context(options: ["freq": "DAILY", "count": 3], startDate: Date(timeIntervalSince1970: 852076800), timeZone: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1999, month: 1)
        
        XCTAssertEqual(context.nextYearLengthInDays, 366)
    }
    
    // Additional tests can be translated in a similar manner.
}

