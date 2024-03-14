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
    
    // MARK: Between
    
    func testWeeklyRuleWithSpecificTimeCriteria() {
        let rrule = "FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU"
        
        let timezone = TimeZone(identifier: "Australia/ACT")!
        calendar.timeZone = timezone
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        dateFormatter.timeZone = timezone
        
        guard let dtstart = dateFormatter.date(from: "Sun, 04 Feb 2018 04:00:00 +1000") else {
            XCTFail("Failed to parse dtstart")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Sun, 08 Apr 2018 00:00:00 +0000"),
              let endDate = dateFormatter.date(from: "Fri, 08 Jun 2018 23:59:59 +0000") else {
            XCTFail("Failed to parse start or end date")
            return
        }
        
        let expectedDates = [
            "Sun, 08 Apr 2018 23:59:59 +1000",
            "Sun, 15 Apr 2018 23:59:59 +1000",
            "Sun, 22 Apr 2018 23:59:59 +1000",
            "Sun, 29 Apr 2018 23:59:59 +1000",
            "Sun, 06 May 2018 23:59:59 +1000",
            "Sun, 13 May 2018 23:59:59 +1000",
            "Sun, 20 May 2018 23:59:59 +1000",
            "Sun, 27 May 2018 23:59:59 +1000",
            "Sun, 03 Jun 2018 23:59:59 +1000",
        ].compactMap(dateFormatter.date(from:))
        
        let results = rule.between(startDate: startDate, endDate: endDate)
        XCTAssertEqual(results, expectedDates, "The results should match the expected dates.")
    }
    
    func testWeeklyRuleStartingBeyondBeginning() {
        let rrule = "FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let dtstart = dateFormatter.date(from: "2018-02-04 04:00:00 +1000"),
              let startDate = dateFormatter.date(from: "2018-05-13 23:59:59 +1000"),
              let endDate = dateFormatter.date(from: "2018-06-08 23:59:59 +0000") else {
            XCTFail("Failed to parse dates")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: "Australia/Brisbane")
        let results = rule.between(startDate: startDate, endDate: endDate)
        let expectedDates = [
            dateFormatter.date(from: "2018-05-13 23:59:59 +1000")!,
            dateFormatter.date(from: "2018-05-20 23:59:59 +1000")!,
            dateFormatter.date(from: "2018-05-27 23:59:59 +1000")!,
            dateFormatter.date(from: "2018-06-03 23:59:59 +1000")!,
        ]
        
        XCTAssertEqual(results, expectedDates, "The results should match the expected dates.")
    }
    
    func testWeeklyRuleWithLimit() {
        let rrule = "FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let dtstart = dateFormatter.date(from: "2018-02-04 04:00:00 +1000"),
              let startDate = dateFormatter.date(from: "2018-04-08 00:00:00 +0000"),
              let endDate = dateFormatter.date(from: "2018-06-08 23:59:59 +0000") else {
            XCTFail("Failed to parse dates")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: "Australia/Brisbane")
        let results = rule.between(startDate: startDate, endDate: endDate, limit: 2)
        let expectedDates = [
            dateFormatter.date(from: "2018-04-08 23:59:59 +1000")!,
            dateFormatter.date(from: "2018-04-15 23:59:59 +1000")!,
        ]
        
        XCTAssertEqual(results, expectedDates, "The results should match the expected dates with the limit applied.")
    }
    
    func testWeeklyRuleStartingBeyondBeginningWithLimit() {
        let rrule = "FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU"
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(identifier: "Australia/Brisbane")
        
        guard let dtstart = dateFormatter.date(from: "Sun, 04 Feb 2018 04:00:00 +1000"),
              let startDate = dateFormatter.date(from: "Sun, 13 May 2018 23:59:59 +1000"),
              let endDate = dateFormatter.date(from: "Fri, 08 Jun 2018 23:59:59 +0000") else {
            XCTFail("Failed to parse dates")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: "Australia/Brisbane")
        let results = rule.between(startDate: startDate, endDate: endDate, limit: 2)
        let expectedDates = [
            dateFormatter.date(from: "Sun, 13 May 2018 23:59:59 +1000")!,
            dateFormatter.date(from: "Sun, 20 May 2018 23:59:59 +1000")!,
        ]
        
        XCTAssertEqual(results, expectedDates, "The results should match the expected dates, starting beyond the beginning with a limit.")
    }

    func testDailyRuleWithInterval() {
        let rrule = "FREQ=DAILY;INTERVAL=2"
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        guard let dtstart = dateFormatter.date(from: "1997-09-02 06:00:00 -0400"),
              let startDate = dateFormatter.date(from: "1997-09-02 06:00:00 -0400"),
              let endDate = dateFormatter.date(from: "1997-10-22 06:00:00 -0400") else {
            XCTFail("Failed to parse dates")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: "America/New_York")
        let results = rule.between(startDate: startDate, endDate: endDate)
        // Generate expected dates by iterating from dtstart to endDate with a step of 2 days
        var expectedDates: [Date] = []
        var currentDate = dtstart
        while currentDate <= endDate {
            expectedDates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 2, to: currentDate)!
        }
        
        XCTAssertEqual(results, expectedDates, "The results should match the expected dates with the interval applied.")
    }
    
    func testDailyRuleWithIntervalAndLimit() {
        let rrule = "FREQ=DAILY;INTERVAL=2"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        
        guard let dtstart = dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: "America/New_York")
        guard let startDate = dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997"),
              let endDate = dateFormatter.date(from: "Wed Oct 22 06:00:00 PDT 1997") else {
            XCTFail("Failed to parse start or end date")
            return
        }
        
        let results = rule.between(startDate: startDate, endDate: endDate, limit: 5)
        let expectedDates = [
            dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997")!,
            dateFormatter.date(from: "Thu Sep  4 06:00:00 PDT 1997")!,
            dateFormatter.date(from: "Sat Sep  6 06:00:00 PDT 1997")!,
            dateFormatter.date(from: "Mon Sep  8 06:00:00 PDT 1997")!,
            dateFormatter.date(from: "Wed Sep 10 06:00:00 PDT 1997")!,
        ]
        
        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }

    func testWeeklyRuleWithIntervalAndWeekStart() {
        let rrule = "FREQ=WEEKLY;INTERVAL=2;WKST=SU"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        dateFormatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
        
        guard let dtstart = dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: "America/New_York")
        guard let startDate = dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997"),
              let endDate = dateFormatter.date(from: "Tue Feb 17 06:00:00 PST 1998") else {
            XCTFail("Failed to parse start or end date")
            return
        }
        
        let results = rule.between(startDate: startDate, endDate: endDate)
        let expectedDates = [
            "Tue Sep  2 06:00:00 PDT 1997",
            "Tue Sep 16 06:00:00 PDT 1997",
            "Tue Sep 30 06:00:00 PDT 1997",
            "Tue Oct 14 06:00:00 PDT 1997",
            "Tue Oct 28 06:00:00 PST 1997",
            "Tue Nov 11 06:00:00 PST 1997",
            "Tue Nov 25 06:00:00 PST 1997",
            "Tue Dec  9 06:00:00 PST 1997",
            "Tue Dec 23 06:00:00 PST 1997",
            "Tue Jan  6 06:00:00 PST 1998",
            "Tue Jan 20 06:00:00 PST 1998",
            "Tue Feb  3 06:00:00 PST 1998",
            "Tue Feb 17 06:00:00 PST 1998",
        ].compactMap(dateFormatter.date(from:))
        
        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }

    func testMonthlyRuleWithNegativeByMonthDay() {
        let rrule = "FREQ=MONTHLY;BYMONTHDAY=-3"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone
        
        guard let dtstart = dateFormatter.date(from: "Sun Sep 28 06:00:00 PDT 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Sun Sep 28 06:00:00 PDT 1997"),
              let endDate = dateFormatter.date(from: "Thu Feb 26 06:00:00 PST 1998") else {
            XCTFail("Failed to parse start or end date")
            return
        }
        
        let results = rule.between(startDate: startDate, endDate: endDate)
        let expectedDates = [
            "Sun Sep 28 06:00:00 PDT 1997",
            "Wed Oct 29 06:00:00 PST 1997",
            "Fri Nov 28 06:00:00 PST 1997",
            "Mon Dec 29 06:00:00 PST 1997",
            "Thu Jan 29 06:00:00 PST 1998",
            "Thu Feb 26 06:00:00 PST 1998",
        ].compactMap(dateFormatter.date(from:))
        
        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }
    
    func testMonthlyRuleWithIntervalAndByDay() {
        let rrule = "FREQ=MONTHLY;INTERVAL=2;BYDAY=TU"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone
        
        guard let dtstart = dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Tue Sep  2 06:00:00 PDT 1997"),
              let endDate = dateFormatter.date(from: "Tue Mar 31 06:00:00 PST 1998") else {
            XCTFail("Failed to parse start or end date")
            return
        }
        
        let results = rule.between(startDate: startDate, endDate: endDate)
        let expectedDates = [
            "Tue Sep  2 06:00:00 PDT 1997",
            "Tue Sep  9 06:00:00 PDT 1997",
            "Tue Sep 16 06:00:00 PDT 1997",
            "Tue Sep 23 06:00:00 PDT 1997",
            "Tue Sep 30 06:00:00 PDT 1997",
            "Tue Nov  4 06:00:00 PST 1997",
            "Tue Nov 11 06:00:00 PST 1997",
            "Tue Nov 18 06:00:00 PST 1997",
            "Tue Nov 25 06:00:00 PST 1997",
            "Tue Jan  6 06:00:00 PST 1998",
            "Tue Jan 13 06:00:00 PST 1998",
            "Tue Jan 20 06:00:00 PST 1998",
            "Tue Jan 27 06:00:00 PST 1998",
            "Tue Mar  3 06:00:00 PST 1998",
            "Tue Mar 10 06:00:00 PST 1998",
            "Tue Mar 17 06:00:00 PST 1998",
            "Tue Mar 24 06:00:00 PST 1998",
            "Tue Mar 31 06:00:00 PST 1998",
        ].compactMap(dateFormatter.date(from:))
        
        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }
}
