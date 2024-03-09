//
//  GeneratorTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

final class GeneratorTests: XCTestCase {
    var context: Context!
    var generator: Generator!
    
    override func setUp() {
        super.setUp()
        // Setup context and generator here
        let options: [String: Any] = ["interval": 1, "wkst": 1]
        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 11, second: 22).date!
        context = Context(options: options, dtstart: startDate, tz: TimeZone(identifier: "America/Los_Angeles")!)
        generator = Generator(context: context)
        context.rebuild(year: 1997, month: 1)
    }
    
    func testProcessTimesetWithSingleTimeset() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 11, second: 22).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15]]
        ]
        
        let expectedDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!
        
        let result = generator.processTimeset(date: date, timeset: timeset)
        XCTAssertEqual(result, [expectedDate], "Should match array with single specified time")
    }
    
    func testProcessTimesetWithMultipleHours() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [12, 15], "minute": [30], "second": [15]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 15, minute: 30, second: 15).date!
        ].sorted()
        
        let result = generator.processTimeset(date: date, timeset: timeset).sorted()
        XCTAssertEqual(result, expectedDates, "Should match array with times for multiple hours")
    }
    
    func testProcessTimesetWithMultipleMinutes() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 11, second: 22).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [12], "minute": [15, 30], "second": [15]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 15, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!
        ].sorted(by: { $0 < $1 })
        
        let result = generator.processTimeset(date: date, timeset: timeset).sorted(by: { $0 < $1 })
        XCTAssertEqual(result, expectedDates, "Should match array with times for multiple minutes")
    }
    
    func testProcessTimesetWithMultipleSeconds() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15, 59]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 59).date!
        ].sorted(by: { $0 < $1 })
        
        let result = generator.processTimeset(date: date, timeset: timeset).sorted(by: { $0 < $1 })
        XCTAssertEqual(result, expectedDates)
    }
    
    func testProcessTimesetWithMultipleHoursMinutesSeconds() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [12, 20], "minute": [30, 55], "second": [15, 59]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 59).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 55, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 55, second: 59).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 30, second: 59).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 55, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 55, second: 59).date!
        ].sorted(by: { $0 < $1 })
        
        let result = generator.processTimeset(date: date, timeset: timeset).sorted(by: { $0 < $1 })
        XCTAssertEqual(result, expectedDates)
    }
    
    func testProcessTimesetWithUnsortedMultipleHoursMinutesSeconds() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [20, 12], "minute": [55, 30], "second": [59, 15]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 59).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 55, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 55, second: 59).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 30, second: 59).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 55, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 55, second: 59).date!
        ].sorted(by: { $0 < $1 })
        
        let result = generator.processTimeset(date: date, timeset: timeset).sorted(by: { $0 < $1 })
        XCTAssertEqual(result, expectedDates)
    }
    
    func testProcessTimesetWithMultipleTimesets() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15]],
            ["hour": [18], "minute": [45], "second": [20]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 18, minute: 45, second: 20).date!
        ]
        
        let result = generator.processTimeset(date: date, timeset: timeset)
        XCTAssertEqual(result, expectedDates)
    }

    func testProcessTimesetWithMultipleTimesetsAndMultipleHourSets() {
        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1).date!
        let timeset: [[String: [Int]]] = [
            ["hour": [12, 20], "minute": [30], "second": [15, 45]],
            ["hour": [18], "minute": [22, 45], "second": [20]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 45).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 20, minute: 30, second: 45).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 18, minute: 22, second: 20).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 18, minute: 45, second: 20).date!
        ].sorted(by: { $0 < $1 })
        
        let result = generator.processTimeset(date: date, timeset: timeset).sorted(by: { $0 < $1 })
        XCTAssertEqual(result, expectedDates)
    }

}
