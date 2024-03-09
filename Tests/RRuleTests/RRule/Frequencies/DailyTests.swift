//
//  DailyTests.swift
//  
//
//  Created by Yuri Sidorov on 09.03.2024.
//

import XCTest
@testable import RRule

class DailyTests: XCTestCase {
    var context: Context!
    var dailyFrequency: Daily!
    var filters: [Filter] = [] // Assuming you have defined a Filter protocol as discussed
    var timeset: [[String: [Int]]] = [] // Assuming timeset is correctly structured for your use case
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()
    
    func testSequentialDays() {
        let date = DateComponents(calendar: calendar, timeZone: timeZone, year: 1997, month: 1, day: 1).date!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        dailyFrequency = Daily(context: context, filters: filters, generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 1, to: date)!])
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 2, to: date)!])
    }
    
    func testEveryOtherDay() {
        let date = DateComponents(calendar: calendar, timeZone: timeZone, year: 1997, month: 1, day: 1).date!
        context = Context(options: ["interval": 2], dtstart: date, tz: timeZone)
        dailyFrequency = Daily(context: context, filters: filters, generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 2, to: date)!])
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 4, to: date)!])
    }
    
    func testEndOfFebruary() {
        let date = DateComponents(calendar: calendar, timeZone: timeZone, year: 1997, month: 2, day: 28).date!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        dailyFrequency = Daily(context: context, filters: filters, generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 1, to: date)!])
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [calendar.date(byAdding: .day, value: 2, to: date)!])
    }
    
    func testEndOfYear() {
        let date = DateComponents(calendar: calendar, timeZone: timeZone, year: 1997, month: 12, day: 31).date!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        dailyFrequency = Daily(context: context, filters: filters, generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        // Fetch the first occurrence (Dec 31, 1997)
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [date])
        
        // Fetch the next occurrence (Jan 1, 1998)
        let expectedDate1 = calendar.date(byAdding: .day, value: 1, to: date)!
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [expectedDate1])
        
        // Fetch the next occurrence (Jan 2, 1998)
        let expectedDate2 = calendar.date(byAdding: .day, value: 2, to: date)!
        XCTAssertEqual(dailyFrequency.nextOccurrences(), [expectedDate2])
    }

}

