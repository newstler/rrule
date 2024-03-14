//
//  RuleTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

final class RuleTests: XCTestCase {
    var calendar = Calendar.current
    var dateFormatter = DateFormatter()
    
    override func setUp() {
        super.setUp()
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
    func testSequentialReturnValues() {
        let rrule = "FREQ=DAILY;COUNT=10"
        
        // Assuming you have an initializer or method to create a Date from a string
        let timezone = TimeZone(identifier: "America/Los_Angeles")!
        calendar.timeZone = timezone
        
        let dtstart = dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997")!
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        
        // Adjust these expected dates to the correct values and time zone adjustments
        let expectedFirstDate = dtstart // You may need to adjust this based on your actual implementation
        let expectedSecondDate = calendar.date(byAdding: .day, value: 1, to: dtstart)!
        let expectedThirdDate = calendar.date(byAdding: .day, value: 2, to: dtstart)!
        
        XCTAssertEqual(rule.next(), expectedFirstDate, "The first date should match the initial dtstart value.")
        XCTAssertEqual(rule.next(), expectedSecondDate, "The second date should be one day after dtstart.")
        XCTAssertEqual(rule.next(), expectedThirdDate, "The third date should be two days after dtstart.")
    }
}
