//
//  AllOccurrencesTests.swift
//  
//
//  Created by Yuri Sidorov on 09.03.2024.
//

import XCTest
@testable import RRule

final class AllOccurrencesTests: XCTestCase {
    var context: Context!
    var allOccurrences: AllOccurrences!
    
    override func setUp() {
        super.setUp()
        let options: [String: Any] = ["interval": 1, "wkst": 1]
        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 11, second: 22).date!
        context = Context(options: options, dtstart: startDate, tz: TimeZone(identifier: "America/Los_Angeles")!)
        allOccurrences = AllOccurrences(context: context)
        context.rebuild(year: 1997, month: 1)
    }
    
    func testCombineDatesAndTimesWithSingleDateAndTime() {
        let dates = [0]
        let times: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15]]
        ]
        
        let expectedDate = DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!
        
        let result = allOccurrences.combineDatesAndTimes(dayset: dates, timeset: times)
        XCTAssertEqual(result, [expectedDate])
    }
    
    func testCombineDatesAndTimesWithMultipleDatesAndSingleTime() {
        let dates = [0, 15]
        let times: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 16, hour: 12, minute: 30, second: 15).date!
        ].sorted(by: { $0 < $1 })
        
        let result = allOccurrences.combineDatesAndTimes(dayset: dates, timeset: times).sorted(by: { $0 < $1 })
        XCTAssertEqual(result, expectedDates)
    }
    
    func testCombineDatesAndTimesWithSingleDateAndMultipleTimes() {
        let dates = [0]
        let times: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15]],
            ["hour": [18], "minute": [45], "second": [20]]
        ]
        
        let expectedDates = [
            DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: Calendar(identifier: .gregorian), timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 18, minute: 45, second: 20).date!
        ].sorted(by: { $0 < $1 })
        
        let result = allOccurrences.combineDatesAndTimes(dayset: dates, timeset: times).sorted(by: { $0 < $1 })
        XCTAssertEqual(result, expectedDates)
    }
}
