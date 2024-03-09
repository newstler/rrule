//
//  BySetPositionTests.swift
//  
//
//  Created by Yuri Sidorov on 09.03.2024.
//

import XCTest
@testable import RRule

final class BySetPositionTests: XCTestCase {
    var context: Context!
    var bySetPosition: BySetPosition!
    
    override func setUp() {
        super.setUp()
        let options: [String: Any] = ["interval": 1, "wkst": 1]
        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 0, second: 0).date!
        context = Context(options: options, dtstart: startDate, tz: TimeZone(identifier: "America/Los_Angeles")!)
        context.rebuild(year: 1997, month: 1)
    }

    func testCombineDatesAndTimesWithSingleSetPosition() {
        let positions = [0] // Adjusted for zero-based indexing
        let dates = [0, 1, 2, 3, 4]
        let times: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15]]
        ]
        
        bySetPosition = BySetPosition(bySetPositions: positions, context: context)
        let result = bySetPosition.combineDatesAndTimes(dayset: dates, timeset: times)
        
        let expectedDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!
        
        XCTAssertEqual(result, [expectedDate])
    }
    
    func testCombineDatesAndTimesWithMultipleSetPositions() {
        let positions = [1, 3] // Adjusted for zero-based indexing
        let dates = [0, 1, 2, 3, 4]
        let times: [[String: [Int]]] = [
            ["hour": [12], "minute": [30], "second": [15]]
        ]
        
        bySetPosition = BySetPosition(bySetPositions: positions, context: context)
        let result = bySetPosition.combineDatesAndTimes(dayset: dates, timeset: times)
        
        let expectedDates = [
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!,
            DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 3, hour: 12, minute: 30, second: 15).date!
        ].sorted(by: { $0 < $1 })
        
        XCTAssertEqual(result.sorted(by: { $0 < $1 }), expectedDates)
    }
}
