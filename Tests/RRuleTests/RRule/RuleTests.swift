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
    
    // MARK: Next
    
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
    
  //  FIXME: Returned dates are completely wrong
//    func testYearlyRuleWithByDayConstraint() {
//        let rrule = "FREQ=YEARLY;BYDAY=20MO"
//        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
//        let timezone = TimeZone(identifier: "America/New_York")!
//        dateFormatter.timeZone = timezone
//
//        guard let dtstart = dateFormatter.date(from: "Mon May 19 06:00:00 PDT 1997") else {
//            XCTFail("Failed to parse dtstart")
//            return
//        }
//
//        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
//        guard let startDate = dateFormatter.date(from: "Mon May 19 06:00:00 PDT 1997"),
//              let endDate = dateFormatter.date(from: "Mon May 17 06:00:00 PDT 1999") else {
//            XCTFail("Failed to parse start or end date")
//            return
//        }
//
//        let results = rule.between(startDate: startDate, endDate: endDate)
//        let expectedDates = [
//            "Mon May 19 06:00:00 PDT 1997",
//            "Mon May 18 06:00:00 PDT 1998",
//            "Mon May 17 06:00:00 PDT 1999"
//        ].compactMap { dateFormatter.date(from: $0) }
//
//        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
//        for (result, expected) in zip(results, expectedDates) {
//            XCTAssertEqual(result, expected, "The result should match the expected date.")
//        }
//    }

    // TODO: Switch on when BYWEEKNO is fixed
//    func testYearlyRuleWithByWeekNoAndByDay() {
//        let rrule = "FREQ=YEARLY;BYWEEKNO=20;BYDAY=MO"
//        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
//        let timezone = TimeZone(identifier: "America/New_York")!
//        dateFormatter.timeZone = timezone
//
//        guard let dtstart = dateFormatter.date(from: "Mon May 12 06:00:00 EDT 1997") else {
//            XCTFail("Failed to parse dtstart")
//            return
//        }
//
//        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
//        guard let startDate = dateFormatter.date(from: "Mon May 12 06:00:00 EDT 1997"),
//              let endDate = dateFormatter.date(from: "Mon May 17 06:00:00 EDT 1999") else {
//            XCTFail("Failed to parse start or end date")
//            return
//        }
//
//        let results = rule.between(startDate: startDate, endDate: endDate)
//        let expectedDatesStrings = [
//            "Mon May 12 06:00:00 EDT 1997",
//            "Mon May 11 06:00:00 EDT 1998",
//            "Mon May 17 06:00:00 EDT 1999"
//        ]
//        let expectedDates = expectedDatesStrings.compactMap { dateFormatter.date(from: $0) }
//
//        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
//        for (result, expected) in zip(results, expectedDates) {
//            XCTAssertEqual(result, expected, "The result should match the expected date.")
//        }
//    }

    
    func testYearlyRuleWithByMonthAndByDay() {
        let rrule = "FREQ=YEARLY;BYMONTH=3;BYDAY=TH"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Thu Mar 13 06:00:00 EST 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }

        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Thu Mar 13 06:00:00 EST 1997"),
              let endDate = dateFormatter.date(from: "Thu Mar 25 06:00:00 EST 1999") else {
            XCTFail("Failed to parse start or end date")
            return
        }

        let results = rule.between(startDate: startDate, endDate: endDate)
        let expectedDatesStrings = [
            "Thu Mar 13 06:00:00 EST 1997",
            "Thu Mar 20 06:00:00 EST 1997",
            "Thu Mar 27 06:00:00 EST 1997",
            "Thu Mar  5 06:00:00 EST 1998",
            "Thu Mar 12 06:00:00 EST 1998",
            "Thu Mar 19 06:00:00 EST 1998",
            "Thu Mar 26 06:00:00 EST 1998",
            "Thu Mar  4 06:00:00 EST 1999",
            "Thu Mar 11 06:00:00 EST 1999",
            "Thu Mar 18 06:00:00 EST 1999",
            "Thu Mar 25 06:00:00 EST 1999"
        ]
        let expectedDates = expectedDatesStrings.compactMap(dateFormatter.date(from:))

        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }
    
    func testYearlyRuleWithMultipleMonthsAndDay() {
        let rrule = "FREQ=YEARLY;BYDAY=TH;BYMONTH=6,7,8"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Thu Jun 5 06:00:00 EDT 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }

        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Thu Jun 5 06:00:00 EDT 1997"),
              let endDate = dateFormatter.date(from: "Thu Aug 26 06:00:00 EDT 1999") else {
            XCTFail("Failed to parse start or end date")
            return
        }

        let results = rule.between(startDate: startDate, endDate: endDate)
        let expectedDates = [
            "Thu Jun 5 06:00:00 EDT 1997",
            "Thu Jun 12 06:00:00 EDT 1997",
            "Thu Jun 19 06:00:00 EDT 1997",
            "Thu Jun 26 06:00:00 EDT 1997",
            "Thu Jul 3 06:00:00 EDT 1997",
            "Thu Jul 10 06:00:00 EDT 1997",
            "Thu Jul 17 06:00:00 EDT 1997",
            "Thu Jul 24 06:00:00 EDT 1997",
            "Thu Jul 31 06:00:00 EDT 1997",
            "Thu Aug 7 06:00:00 EDT 1997",
            "Thu Aug 14 06:00:00 EDT 1997",
            "Thu Aug 21 06:00:00 EDT 1997",
            "Thu Aug 28 06:00:00 EDT 1997",
            "Thu Jun 4 06:00:00 EDT 1998",
            "Thu Jun 11 06:00:00 EDT 1998",
            "Thu Jun 18 06:00:00 EDT 1998",
            "Thu Jun 25 06:00:00 EDT 1998",
            "Thu Jul 2 06:00:00 EDT 1998",
            "Thu Jul 9 06:00:00 EDT 1998",
            "Thu Jul 16 06:00:00 EDT 1998",
            "Thu Jul 23 06:00:00 EDT 1998",
            "Thu Jul 30 06:00:00 EDT 1998",
            "Thu Aug 6 06:00:00 EDT 1998",
            "Thu Aug 13 06:00:00 EDT 1998",
            "Thu Aug 20 06:00:00 EDT 1998",
            "Thu Aug 27 06:00:00 EDT 1998",
            "Thu Jun 3 06:00:00 EDT 1999",
            "Thu Jun 10 06:00:00 EDT 1999",
            "Thu Jun 17 06:00:00 EDT 1999",
            "Thu Jun 24 06:00:00 EDT 1999",
            "Thu Jul 1 06:00:00 EDT 1999",
            "Thu Jul 8 06:00:00 EDT 1999",
            "Thu Jul 15 06:00:00 EDT 1999",
            "Thu Jul 22 06:00:00 EDT 1999",
            "Thu Jul 29 06:00:00 EDT 1999",
            "Thu Aug 5 06:00:00 EDT 1999",
            "Thu Aug 12 06:00:00 EDT 1999",
            "Thu Aug 19 06:00:00 EDT 1999",
            "Thu Aug 26 06:00:00 EDT 1999"
        ].compactMap { dateFormatter.date(from: $0) }

        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }

    
    func testMonthlyRuleByDayAndByMonthDay() {
        let rrule = "FREQ=MONTHLY;BYDAY=SA;BYMONTHDAY=7,8,9,10,11,12,13"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Sat Sep 13 06:00:00 EDT 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }

        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Sat Sep 13 06:00:00 EDT 1997"),
              let endDate = dateFormatter.date(from: "Sat Jun 13 06:00:00 EDT 1998") else {
            XCTFail("Failed to parse start or end date")
            return
        }

        let results = rule.between(startDate: startDate, endDate: endDate)

        let expectedDates = [
            "Sat Sep 13 06:00:00 EDT 1997",
            "Sat Oct 11 06:00:00 EDT 1997",
            "Sat Nov 8 06:00:00 EST 1997",
            "Sat Dec 13 06:00:00 EST 1997",
            "Sat Jan 10 06:00:00 EST 1998",
            "Sat Feb 7 06:00:00 EST 1998",
            "Sat Mar 7 06:00:00 EST 1998",
            "Sat Apr 11 06:00:00 EDT 1998",
            "Sat May 9 06:00:00 EDT 1998",
            "Sat Jun 13 06:00:00 EDT 1998"
        ].compactMap { dateFormatter.date(from: $0) }

        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }

    func testYearlyRuleWithIntervalAndComplexConstraints() {
        let rrule = "FREQ=YEARLY;INTERVAL=4;BYMONTH=11;BYDAY=TU;BYMONTHDAY=2,3,4,5,6,7,8"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Tue Nov 5 06:00:00 EST 1996") else {
            XCTFail("Failed to parse dtstart")
            return
        }

        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Tue Nov 5 06:00:00 EST 1996"),
              let endDate = dateFormatter.date(from: "Tue Nov 2 06:00:00 EST 2004") else {
            XCTFail("Failed to parse start or end date")
            return
        }

        let results = rule.between(startDate: startDate, endDate: endDate)

        let expectedDates = [
            "Tue Nov 5 06:00:00 EST 1996",
            "Tue Nov 7 06:00:00 EST 2000",
            "Tue Nov 2 06:00:00 EST 2004"
        ].compactMap { dateFormatter.date(from: $0) }

        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }
    
    func testMonthlyRuleByDayWithBySetPos() {
        let rrule = "FREQ=MONTHLY;BYDAY=MO,TU,WE,TH,FR;BYSETPOS=-2"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone
        
        guard let dtstart = dateFormatter.date(from: "Mon Sep 29 06:00:00 EDT 1997") else {
            XCTFail("Failed to parse dtstart")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Mon Sep 29 06:00:00 EDT 1997"),
              let endDate = dateFormatter.date(from: "Mon Mar 30 06:00:00 EST 1998") else {
            XCTFail("Failed to parse start or end date")
            return
        }
        
        let results = rule.between(startDate: startDate, endDate: endDate)
        
        let expectedDates = [
            "Mon Sep 29 06:00:00 EDT 1997",
            "Thu Oct 30 06:00:00 EST 1997",
            "Thu Nov 27 06:00:00 EST 1997",
            "Tue Dec 30 06:00:00 EST 1997",
            "Thu Jan 29 06:00:00 EST 1998",
            "Thu Feb 26 06:00:00 EST 1998",
            "Mon Mar 30 06:00:00 EST 1998"
        ].compactMap { dateFormatter.date(from: $0) }
        
        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }

    func testDailyCountStopsBeforeRangeEnds() {
        let rrule = "FREQ=DAILY;COUNT=7"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/Los_Angeles")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Thu Feb 6 16:00:00 PST 2014") else {
            XCTFail("Failed to parse dtstart")
            return
        }

        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        guard let startDate = dateFormatter.date(from: "Sun Feb 9 16:00:00 PST 2014"),
              let endDate = dateFormatter.date(from: "Wed Feb 19 16:00:00 PST 2014") else {
            XCTFail("Failed to parse start or end date")
            return
        }

        let results = rule.between(startDate: startDate, endDate: endDate)

        let expectedDates = [
            "Sun Feb 9 16:00:00 PST 2014",
            "Mon Feb 10 16:00:00 PST 2014",
            "Tue Feb 11 16:00:00 PST 2014",
            "Wed Feb 12 16:00:00 PST 2014"
        ].compactMap { dateFormatter.date(from: $0) }

        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }

    func testDailyRuleWithExdate() {
        let rrule = "FREQ=DAILY;COUNT=10"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        
        let timezone = TimeZone(identifier: "America/Los_Angeles")!
        dateFormatter.timeZone = timezone
        
        guard let dtstart = dateFormatter.date(from: "Tue Sep  2 06:00:00 PST 1997"),
              let exdate1 = dateFormatter.date(from: "Fri Sep  5 06:00:00 PST 1997"),
              let exdate2 = dateFormatter.date(from: "Mon Sep  8 06:00:00 PST 1997") else {
            XCTFail("Failed to parse dates")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier, exdate: [exdate1, exdate2])
        
        let results = rule.all()
        let expectedDates = [
            "Tue Sep  2 06:00:00 PST 1997",
            "Wed Sep  3 06:00:00 PST 1997",
            "Thu Sep  4 06:00:00 PST 1997",
            "Sat Sep  6 06:00:00 PST 1997",
            "Sun Sep  7 06:00:00 PST 1997",
            "Tue Sep  9 06:00:00 PST 1997",
            "Wed Sep 10 06:00:00 PST 1997",
            "Thu Sep 11 06:00:00 PST 1997",
        ].compactMap(dateFormatter.date(from:))
        
        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }
    
    func testWeeklyRuleWithIntervalAndByDay() {
        let rrule = "FREQ=WEEKLY;INTERVAL=4;BYDAY=TH"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        
        let timezone = TimeZone(identifier: "America/Los_Angeles")!
        dateFormatter.timeZone = timezone
        
        guard let dtstart = dateFormatter.date(from: "Thu Jan 28 17:00:00 PST 2016") else {
            XCTFail("Failed to parse dtstart")
            return
        }
        
        let rule = Rule(rrule: rrule, dtstart: dtstart, tzid: timezone.identifier)
        
        guard let startDate = dateFormatter.date(from: "Tue May 24 14:34:59 PDT 2016"),
              let endDate = dateFormatter.date(from: "Sun Jul 24 14:35:09 PDT 2016") else {
            XCTFail("Failed to parse start or end date")
            return
        }
        
        let results = rule.between(startDate: startDate, endDate: endDate)
        
        let expectedDates = [
            "Thu Jun 16 17:00:00 PDT 2016",
            "Thu Jul 14 17:00:00 PDT 2016"
        ].compactMap(dateFormatter.date(from:))
        
        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }

    func testWeeklyRuleWithIntervalAndByDayParseFunction() {
        let rrule = "FREQ=WEEKLY;INTERVAL=4;BYDAY=TH"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        
        let timezone = TimeZone(identifier: "America/Los_Angeles")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Thu Jan 28 17:00:00 PST 2016") else {
            XCTFail("Failed to parse dtstart")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)

        guard let startDate = dateFormatter.date(from: "Tue May 24 14:34:59 PDT 2016"),
              let endDate = dateFormatter.date(from: "Sun Jul 24 14:35:09 PDT 2016") else {
            XCTFail("Failed to parse start or end date")
            return
        }

        let results = rule.between(startDate: startDate, endDate: endDate)
        let expectedDates = [
            "Thu Jun 16 17:00:00 PDT 2016",
            "Thu Jul 14 17:00:00 PDT 2016"
        ].compactMap(dateFormatter.date(from:))

        XCTAssertEqual(results.count, expectedDates.count, "The number of results should match the expected count.")
        for (result, expected) in zip(results, expectedDates) {
            XCTAssertEqual(result, expected, "The result should match the expected date.")
        }
    }
    
    func testDailyRuleWithYearBorderStart() {
        let rrule = "FREQ=DAILY"
        dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss zzz yyyy"
        let timezone = TimeZone(identifier: "America/Los_Angeles")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Thu Dec 31 16:00:00 PST 2015") else {
            XCTFail("Failed to parse dtstart")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)

        guard let oneMonthBefore = calendar.date(byAdding: .month, value: -1, to: dtstart),
              let oneMonthAfter = calendar.date(byAdding: .month, value: 1, to: dtstart) else {
            XCTFail("Failed to calculate dates one month before and after dtstart")
            return
        }

        let results = rule.between(startDate: oneMonthBefore, endDate: oneMonthAfter)
        guard let firstResult = results.first else {
            XCTFail("No results returned by the rule")
            return
        }

        XCTAssertEqual(firstResult, dtstart, "The first result should match the dtstart date right on the year border.")
    }

    func testMonthlyRuleByDayBySetPosNotExist() {
        let rrule = "FREQ=MONTHLY;BYDAY=WE;BYSETPOS=5"
        let timezone = TimeZone(identifier: "America/Chicago")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Wed Jan 30 09:00:00 PST 2013"),
              let startTime = dateFormatter.date(from: "Sun Jul 31 22:00:00 PDT 2016"),
              let expectedInstance = dateFormatter.date(from: "Wed Aug 31 09:00:00 PDT 2016"),
              let endTime = dateFormatter.date(from: "Wed Aug 31 21:59:59 PDT 2016") else {
            XCTFail("Failed to parse dates")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)
        let results = rule.between(startDate: startTime, endDate: endTime)

        XCTAssertEqual(results, [expectedInstance], "The results should match the expected instance when BYSETPOS specifies a non-existing position.")
    }
    
    func testIteratingWithFloorDateLimitsRange() {
        let rrule = "FREQ=DAILY"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Tue Sep 2 06:00:00 PDT 1997"),
              let startTime = dateFormatter.date(from: "Mon Sep 3 06:00:00 PDT 2018"),
              let endTime = dateFormatter.date(from: "Thu Sep 10 06:00:00 PDT 2018") else {
            XCTFail("Failed to parse dates")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)
        let results = rule.between(startDate: startTime, endDate: endTime)

        let expectedDates = [
            "Tue Sep 3 06:00:00 PDT 2018",
            "Wed Sep 4 06:00:00 PDT 2018",
            "Thu Sep 5 06:00:00 PDT 2018"
        ].compactMap(dateFormatter.date(from:))

        XCTAssertEqual(Array(results.prefix(3)), expectedDates, "The results within the given range should match the expected dates.")
    }

    func testIteratingWithCountLimitsRange() {
        let rrule = "FREQ=DAILY;COUNT=10"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Tue Sep 2 06:00:00 PDT 1997"),
              let startTime = dateFormatter.date(from: "Wed Sep 3 06:00:00 PDT 1997"),
              let endTime = dateFormatter.date(from: "Thu Sep 10 06:00:00 PDT 2018") else {
            XCTFail("Failed to parse dates")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)
        let results = rule.between(startDate: startTime, endDate: endTime)

        let expectedDates = [
            "Wed Sep 3 06:00:00 PDT 1997",
            "Thu Sep 4 06:00:00 PDT 1997",
            "Fri Sep 5 06:00:00 PDT 1997"
        ].compactMap(dateFormatter.date(from:))

        XCTAssertEqual(Array(results.prefix(3)), expectedDates, "The results within the given range should match the expected dates.")
    }

    func testIteratingWithIntervalLimitsRange() {
        let rrule = "FREQ=DAILY;INTERVAL=10"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Tue Sep 2 06:00:00 PDT 1997"),
              let startTime = dateFormatter.date(from: "Wed Sep 3 06:00:00 PDT 1997"),
              let endTime = dateFormatter.date(from: "Thu Sep 30 06:00:00 PDT 2018") else {
            XCTFail("Failed to parse dates")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)
        let results = rule.between(startDate: startTime, endDate: endTime)

        let expectedDates = [
            "Fri Sep 12 06:00:00 PDT 1997",
            "Mon Sep 22 06:00:00 PDT 1997",
            "Thu Oct 2 06:00:00 PDT 1997"
        ].compactMap(dateFormatter.date(from:))

        XCTAssertEqual(Array(results.prefix(3)), expectedDates, "The results within the given range should match the expected dates.")
    }

    func testIteratingWithIntervalAndCountLimitsRange() {
        let rrule = "FREQ=DAILY;INTERVAL=10;COUNT=5"
        let timezone = TimeZone(identifier: "America/New_York")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Tue Sep 2 06:00:00 PDT 1997"),
              let startTime = dateFormatter.date(from: "Wed Sep 3 06:00:00 PDT 1997"),
              let endTime = dateFormatter.date(from: "Thu Sep 30 06:00:00 PDT 2018") else {
            XCTFail("Failed to parse dates")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)
        let results = rule.between(startDate: startTime, endDate: endTime)

        let expectedDates = [
            "Fri Sep 12 06:00:00 PDT 1997",
            "Mon Sep 22 06:00:00 PDT 1997",
            "Thu Oct 2 06:00:00 PDT 1997"
        ].compactMap(dateFormatter.date(from:))

        XCTAssertEqual(Array(results.prefix(3)), expectedDates, "The results within the given range should match the expected dates.")
    }

    // MARK: From
    
    func testFromWithWeeklyRuleAndTimeCriteria() {
        let rrule = "FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU"
        let timezone = TimeZone(identifier: "Australia/Brisbane")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Sun Feb 4 04:00:00 +1000 2018"),
              let fromDate = dateFormatter.date(from: "Sun Apr 8 00:00:00 +0000 2018") else {
            XCTFail("Failed to parse dates")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)
        let results = rule.from(startDate: fromDate, limit: 9)

        let expectedDates = [
            "Sun Apr 8 23:59:59 +1000 2018",
            "Sun Apr 15 23:59:59 +1000 2018",
            "Sun Apr 22 23:59:59 +1000 2018",
            "Sun Apr 29 23:59:59 +1000 2018",
            "Sun May 6 23:59:59 +1000 2018",
            "Sun May 13 23:59:59 +1000 2018",
            "Sun May 20 23:59:59 +1000 2018",
            "Sun May 27 23:59:59 +1000 2018",
            "Sun Jun 3 23:59:59 +1000 2018"
        ].compactMap(dateFormatter.date(from:))

        XCTAssertEqual(results, expectedDates, "The results from the start date with a limit should match the expected dates.")
    }

    func testFromWithWeeklyRuleStartingBeyondBeginning() {
        let rrule = "FREQ=WEEKLY;BYSECOND=59;BYMINUTE=59;BYHOUR=23;WKST=SU"
        let timezone = TimeZone(identifier: "Australia/Brisbane")!
        dateFormatter.timeZone = timezone

        guard let dtstart = dateFormatter.date(from: "Sun Feb 4 04:00:00 +1000 2018"),
              let fromStartDate = dateFormatter.date(from: "Sun May 13 23:59:59 +1000 2018") else {
            XCTFail("Failed to parse dates")
            return
        }

        let rule = RRule.parse(rrule, dtstart: dtstart, tzid: timezone.identifier)
        let results = rule.from(startDate: fromStartDate, limit: 4)

        let expectedDates = [
            "Sun May 13 23:59:59 +1000 2018",
            "Sun May 20 23:59:59 +1000 2018",
            "Sun May 27 23:59:59 +1000 2018",
            "Sun Jun 3 23:59:59 +1000 2018"
        ].compactMap(dateFormatter.date(from:))

        XCTAssertEqual(results, expectedDates, "The results from the specified start date with a limit should match the expected dates.")
    }
}
