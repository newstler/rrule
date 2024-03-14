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
        
        XCTAssertEqual(rule.next(), dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997"), "The first date should match the initial dtstart value.")
        XCTAssertEqual(rule.next(), dateFormatter.date(from: "Tue Sep  3 06:00:00 PDT 1997"), "The second date should be one day after dtstart.")
        XCTAssertEqual(rule.next(), dateFormatter.date(from: "Tue Sep  4 06:00:00 PDT 1997"), "The third date should be two days after dtstart.")
    }
}
