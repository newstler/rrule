//
//  MonthlyTests.swift
//  
//
//  Created by Yuri Sidorov on 09.03.2024.
//

import XCTest
@testable import RRule

class MonthlyTests: XCTestCase {
    var context: Context!
    var monthlyFrequency: Monthly!
    var filters: [Filter] = [] // Assuming ByMonthDay conforms to Filter protocol
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()
    
    
    func testSequentialMonths() {
        let date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        let timeset: [[String: [Int]]] = [
            ["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]
        ]
        monthlyFrequency = Monthly(context: context, filters: [ByMonthDay(byMonthDays: [calendar.component(.day, from: date)], context: context)], generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 1, to: date)!])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 2, to: date)!])
    }
    
    func testEveryOtherMonth() {
        let date = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
        context = Context(options: ["interval": 2], dtstart: date, tz: timeZone)
        let timeset: [[String: [Int]]] = [
            ["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]
        ]
        monthlyFrequency = Monthly(context: context, filters: [ByMonthDay(byMonthDays: [calendar.component(.day, from: date)], context: context)], generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 2, to: date)!])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 4, to: date)!])
    }
    
    func testEndOfFebruary() {
        let date = calendar.date(from: DateComponents(year: 1997, month: 2, day: 28))!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        let timeset: [[String: [Int]]] = [
            ["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]
        ]
        monthlyFrequency = Monthly(context: context, filters: [ByMonthDay(byMonthDays: [calendar.component(.day, from: date)], context: context)], generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 1, to: date)!])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 2, to: date)!])
    }
    
    func testEndOfYearExpectingEmptyArray() {
        let date = calendar.date(from: DateComponents(year: 1997, month: 12, day: 31))!
        context = Context(options: ["interval": 1], dtstart: date, tz: timeZone)
        let timeset: [[String: [Int]]] = [
            ["hour": [calendar.component(.hour, from: date)], "minute": [calendar.component(.minute, from: date)], "second": [calendar.component(.second, from: date)]]
        ]
        monthlyFrequency = Monthly(context: context, filters: [ByMonthDay(byMonthDays: [calendar.component(.day, from: date)], context: context)], generator: AllOccurrences(context: context), timeset: timeset, start_date: date)
        let components = calendar.dateComponents([.year, .month], from: date)
        context.rebuild(year: components.year!, month: components.month!)
        
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [date])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 1, to: date)!])
        
        // Returns empty arrays for periods with no matching occurrences.
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [])
        XCTAssertEqual(monthlyFrequency.nextOccurrences(), [calendar.date(byAdding: .month, value: 3, to: date)!])
    }
}

