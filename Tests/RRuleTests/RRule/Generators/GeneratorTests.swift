////
////  GeneratorTests.swift
////  
////
////  Created by Yuri Sidorov on 07.03.2024.
////
//
//import XCTest
//@testable import RRule
//
//final class GeneratorTests: XCTestCase {
//    var context: Context!
//    var generator: Generator!
//    
//    override func setUp() {
//        super.setUp()
//        // Setup context and generator here
//        let options: [String: Any] = ["interval": 1, "wkst": 1]
//        let startDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 11, second: 22).date!
//        context = Context(options: options, startDate: startDate, timeZone: TimeZone(identifier: "America/Los_Angeles")!)
//        generator = Generator(context: context)
//        context.rebuild(year: 1997, month: 1)
//    }
//    
//    func testProcessTimesetWithSingleTimeset() {
//        // Single timeset
//        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 11, second: 22).date!
//        let timeset: [[String: [Int]]] = [
//            ["hour": [12], "minute": [30], "second": [15]]
//        ]
//        
//        let expectedDate = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 12, minute: 30, second: 15).date!
//        
//        let result = generator.processTimeset(date: date, timeset: timeset)
//        XCTAssertEqual(result, [expectedDate], "Should match array with single specified time")
//    }
//    
//    func testProcessTimesetWithMultipleHoursMinutesSeconds() {
//        // Test case for multiple hours, minutes, and seconds in the timeset
//        let date = DateComponents(calendar: .current, timeZone: TimeZone(identifier: "America/Los_Angeles"), year: 1997, month: 1, day: 1, hour: 0, minute: 11, second: 22).date!
//        let timeset: [[String: [Int]]] = [
//            ["hour": [20, 12], "minute": [55, 30], "second": [59, 15]]
//        ]
//        
//        let expectedDates = [
//            "Wed Jan  1 12:30:15 PST 1997",
//            "Wed Jan  1 12:30:59 PST 1997",
//            "Wed Jan  1 12:55:15 PST 1997",
//            "Wed Jan  1 12:55:59 PST 1997",
//            "Wed Jan  1 20:30:15 PST 1997",
//            "Wed Jan  1 20:30:59 PST 1997",
//            "Wed Jan  1 20:55:15 PST 1997",
//            "Wed Jan  1 20:55:59 PST 1997",
//        ].map { DateFormatter.iso8601Full.date(from: $0)! }
//        
//        let result = generator.processTimeset(date: date, timeset: timeset)
//        XCTAssertEqual(result, expectedDates, "Should match array with all specified times")
//    }
//    
//    // Additional tests for multiple timesets can be implemented similarly.
//}
