//
//  WeekdayTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

class WeekdayTests: XCTestCase {
    func testWeekdayParseWithExplicitPositiveOrdinal() {
        // Parsing a weekday string with an explicit positive ordinal
        let weekdayString = "+2SU"
        guard let weekday = Weekday.parse(weekdayString) else {
            XCTFail("Failed to parse weekday string")
            return
        }

        XCTAssertEqual(weekday.ordinal, 2, "The ordinal should be parsed correctly as 2.")
        XCTAssertEqual(weekday.index, 0, "The index for SU (Sunday) should be 0.")
    }
    
    func testWeekdayParseWithImpliedPositiveOrdinal() {
        // Parsing a weekday string with an implied positive ordinal
        let weekdayString = "2SU"
        guard let weekday = Weekday.parse(weekdayString) else {
            XCTFail("Failed to parse weekday string")
            return
        }

        XCTAssertEqual(weekday.ordinal, 2, "The ordinal should be parsed correctly as 2.")
        XCTAssertEqual(weekday.index, 0, "The index for SU (Sunday) should be 0.")
    }
    
    func testWeekdayParseWithNegativeOrdinal() {
        // Parsing a weekday string with a negative ordinal
        let weekdayString = "-3TU"
        guard let weekday = Weekday.parse(weekdayString) else {
            XCTFail("Failed to parse weekday string")
            return
        }

        XCTAssertEqual(weekday.ordinal, -3, "The ordinal should be parsed correctly as -3.")
        XCTAssertEqual(weekday.index, 2, "The index for TU (Tuesday) should be 2.")
    }
}


