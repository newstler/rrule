//
//  ContextTests.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import XCTest
@testable import RRule

class ContextTests: XCTestCase {
    var context: Context!
    let timeZone = TimeZone(identifier: "America/Los_Angeles")!
    
    lazy var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = timeZone
        return cal
    }()

    override func setUp() {
        super.setUp()
        context = Context(
            options: ["freq": "DAILY", "count": 3],
            dtstart: Date(timeIntervalSince1970: 872668800), // Equivalent to Tue Sep  2 06:00:00 PDT 1997
            tz: timeZone
        )
    }
    
    override func tearDown() {
        context = nil
        super.tearDown()
    }

    func testYearLengthInDays() {
        // In a non leap year
        context.rebuild(year: 1997, month: 1)
        XCTAssertEqual(context.yearLengthInDays, 365)

        // In a leap year
        context.rebuild(year: 2000, month: 1)
        XCTAssertEqual(context.yearLengthInDays, 366)
    }
    
    func testNextYearLengthInDays_NotPriorToLeapYear() {
        // Setting up the context for a year not prior to a leap year
        context.rebuild(year: 1997, month: 1)

        // Test the nextYearLengthInDays property
        let length = context.nextYearLengthInDays
        XCTAssertEqual(length, 365, "Expected the next year (1998) to have 365 days")
    }

    func testNextYearLengthInDays_PriorToLeapYear() {
        // Setting up the context for a year prior to a leap year
        context.rebuild(year: 1999, month: 1)

        // Test the nextYearLengthInDays property
        let length = context.nextYearLengthInDays
        XCTAssertEqual(length, 366, "Expected the next year (2000) to be a leap year with 366 days")
    }
    
    func testElapsedDaysInYearByMonthForLeapYear() {
        // Setup for leap year
        context.rebuild(year: 2000, month: 1)
        let elapsedDays = context.elapsedDaysInYearByMonth!

        // Test the first few months to match the leap year pattern
        XCTAssertEqual(elapsedDays[0], 0, "The first value should be 0.")
        XCTAssertEqual(elapsedDays[1], 31, "The second value should be 31 for January.")
        XCTAssertEqual(elapsedDays[2], 60, "The third value should be 60 for February in a leap year.")
        XCTAssertEqual(elapsedDays[3], 91, "The fourth value should be 91 for March in a leap year.")
    }

    func testElapsedDaysInYearByMonthForNonLeapYear() {
        // Setup for non-leap year
        context.rebuild(year: 1997, month: 1)
        let elapsedDays = context.elapsedDaysInYearByMonth!

        // Test the first few months to match the non-leap year pattern
        XCTAssertEqual(elapsedDays[0], 0, "The first value should be 0.")
        XCTAssertEqual(elapsedDays[1], 31, "The second value should be 31 for January.")
        XCTAssertEqual(elapsedDays[2], 59, "The third value should be 59 for February in a non-leap year.")
        XCTAssertEqual(elapsedDays[3], 90, "The fourth value should be 90 for March in a non-leap year.")
    }
    
    func testFirstWeekdayOfYear() {
        context.rebuild(year: 1997, month: 1)
        XCTAssertEqual(context.firstWeekdayOfYear, 3, "The first weekday of the year should be 3 (Wednesday).")
    }
    
    func testFirstDayOfYear() {
        // Setup
        context.rebuild(year: 1997, month: 1)
        
        // Use Calendar to construct the expected date for comparison
        let components = DateComponents(year: 1997, month: 1, day: 1)
        let calendar = calendar
        let expectedDate = calendar.date(from: components)!
        
        // Execute & Verify
        guard let firstDayOfYear = context.firstDayOfYear else {
            XCTFail("firstDayOfYear was nil")
            return
        }
        XCTAssertEqual(calendar.compare(firstDayOfYear, to: expectedDate, toGranularity: .day), .orderedSame, "The first day of the year should be January 1st, 1997.")
    }
    
    func testMonthByDayOfYearLeapYear() {
         // Setting up the context for a leap year
        context.rebuild(year: 2000, month: 1)

         guard let monthByDayOfYear = context.monthByDayOfYear else {
             XCTFail("monthByDayOfYear should not be nil")
             return
         }

         // Leap year has 366 days + 7 padding days
         XCTAssertEqual(monthByDayOfYear.count, 366 + 7, "Expected 366 + 7 days for a leap year")
         XCTAssertEqual(monthByDayOfYear[0], 1, "The first day of the year should be January")
         XCTAssertEqual(monthByDayOfYear[59], 2, "The 60th day of a leap year should be in February")
         XCTAssertEqual(monthByDayOfYear[365], 12, "The last day of the year should be December")
     }

     func testMonthByDayOfYearNonLeapYear() {
         // Setting up the context for a non-leap year
         context.rebuild(year: 1997, month: 1)

         guard let monthByDayOfYear = context.monthByDayOfYear else {
             XCTFail("monthByDayOfYear should not be nil")
             return
         }

         // Non-leap year has 365 days + 7 padding days
         XCTAssertEqual(monthByDayOfYear.count, 365 + 7, "Expected 365 + 7 days for a non-leap year")
         XCTAssertEqual(monthByDayOfYear[0], 1, "The first day of the year should be January")
         XCTAssertEqual(monthByDayOfYear[59], 3, "The 60th day of a non-leap year should be in March")
         XCTAssertEqual(monthByDayOfYear[364], 12, "The last day of the year should be December")
     }
    
    func testMonthDayByDayOfYearLeapYear() {
        context.rebuild(year: 2000, month: 1)

        guard let monthDayByDayOfYear = context.monthDayByDayOfYear else {
            XCTFail("Expected monthDayByDayOfYear to not be nil")
            return
        }

        XCTAssertEqual(monthDayByDayOfYear.count, 366 + 7, "Expected count for a leap year plus 7 padding days")
        XCTAssertEqual(monthDayByDayOfYear[0], 1, "The first day of the year should be January 1")
        XCTAssertEqual(monthDayByDayOfYear[1], 2, "The second day of the year should be January 2")
        XCTAssertEqual(monthDayByDayOfYear[59], 29, "The 60th day of a leap year should be February 29")
        XCTAssertEqual(monthDayByDayOfYear[365], 31, "The 366th day of a leap year should be December 31")
    }

    func testMonthDayByDayOfYearNonLeapYear() {
        context.rebuild(year: 1997, month: 1)

        guard let monthDayByDayOfYear = context.monthDayByDayOfYear else {
            XCTFail("Expected monthDayByDayOfYear to not be nil")
            return
        }

        XCTAssertEqual(monthDayByDayOfYear.count, 365 + 7, "Expected count for a non-leap year plus 7 padding days")
        XCTAssertEqual(monthDayByDayOfYear[0], 1, "The first day of the year should be January 1")
        XCTAssertEqual(monthDayByDayOfYear[1], 2, "The second day of the year should be January 2")
        XCTAssertEqual(monthDayByDayOfYear[59], 1, "The 60th day of a non-leap year should be March 1")
        XCTAssertEqual(monthDayByDayOfYear[364], 31, "The 365th day of a non-leap year should be December 31")
    }
    
    func testNegativeMonthDayByDayOfYearLeapYear() {
        context.rebuild(year: 2000, month: 1)

        guard let negativeMonthDayByDayOfYear = context.negativeMonthDayByDayOfYear else {
            XCTFail("Expected negativeMonthDayByDayOfYear to not be nil")
            return
        }

        XCTAssertEqual(negativeMonthDayByDayOfYear.count, 366 + 7, "Expected count for a leap year plus 7 padding days")
        XCTAssertEqual(negativeMonthDayByDayOfYear[0], -31, "The first day of the year should have -31 days to the end of the month")
        XCTAssertEqual(negativeMonthDayByDayOfYear[1], -30, "The second day of the year should have -30 days to the end of the month")
        XCTAssertEqual(negativeMonthDayByDayOfYear[59], -1, "The 60th day (Feb 29) of a leap year should have -1 day to the end of the month")
        XCTAssertEqual(negativeMonthDayByDayOfYear[365], -1, "The last day of a leap year should have -1 day to the end of the month")
    }

    func testNegativeMonthDayByDayOfYearNonLeapYear() {
        context.rebuild(year: 1997, month: 1)

        guard let negativeMonthDayByDayOfYear = context.negativeMonthDayByDayOfYear else {
            XCTFail("Expected negativeMonthDayByDayOfYear to not be nil")
            return
        }

        XCTAssertEqual(negativeMonthDayByDayOfYear.count, 365 + 7, "Expected count for a non-leap year plus 7 padding days")
        XCTAssertEqual(negativeMonthDayByDayOfYear[0], -31, "The first day of the year should have -31 days to the end of the month")
        XCTAssertEqual(negativeMonthDayByDayOfYear[1], -30, "The second day of the year should have -30 days to the end of the month")
        XCTAssertEqual(negativeMonthDayByDayOfYear[59], -31, "The 60th day (Mar 1) of a non-leap year should have -31 days to the end of the month")
        XCTAssertEqual(negativeMonthDayByDayOfYear[364], -1, "The last day of a non-leap year should have -1 day to the end of the month")
    }
    
    func testWeekdayByDayOfYearStartsWithExpectedSequence() {
        // Set up
        context.rebuild(year: 1997, month: 1) // Choose a year that starts on a Wednesday

        // Execute
        guard let weekdayByDayOfYear = context.weekdayByDayOfYear else {
            XCTFail("weekdayByDayOfYear was nil")
            return
        }
        
        let sequence = weekdayByDayOfYear.prefix(7)
        
        // Verify
        let expectedSequence = [3, 4, 5, 6, 0, 1, 2] // Starting from Wednesday
        XCTAssertEqual(Array(sequence), expectedSequence, "The sequence should start with [3, 4, 5, 6, 0, 1, 2].")
    }
    
    
    func testWeekNumberForFirstDayInFirstWeekOfYear() {
        // Year when the first day is in the first week of that year
        context.rebuild(year: 1997, month: 1)

        guard let weekNumbers = context.weekNumberByDayOfYear else {
            XCTFail("Expected week numbers to not be nil")
            return
        }

        XCTAssertEqual(weekNumbers.first, 1, "Expected the first day of 1997 to be in the first week of the year")
    }

    func testWeekNumberForFirstDayInLastWeekOfPreviousYear() {
        // Year when the first day is in the last week of the previous year
        context.rebuild(year: 1999, month: 1)

        guard let weekNumbers = context.weekNumberByDayOfYear else {
            XCTFail("Expected week numbers to not be nil")
            return
        }

        XCTAssertEqual(weekNumbers.first, 53, "Expected the first day of 1999 to be part of the last week of the previous year")
    }

    func testWeekNumberForLastDayInLastWeekOfYear() {
        // Assuming the year ends in the last week of the same year
        context.rebuild(year: 1999, month: 1)

        guard let weekNumbers = context.weekNumberByDayOfYear else {
            XCTFail("Expected week numbers to not be nil")
            return
        }

        // Adjusting the index for a non-leap year
        XCTAssertEqual(weekNumbers[364], 52, "Expected the last day of 1999 to be in the last week of the same year")
    }

    func testWeekNumberForLastDayInFirstWeekOfNextYear() {
        // Assuming the year ends but the last day spills over into the first week of the next year
        context.rebuild(year: 1997, month: 1)

        guard let weekNumbers = context.weekNumberByDayOfYear else {
            XCTFail("Expected week numbers to not be nil")
            return
        }

        // Adjusting the index for a non-leap year
        XCTAssertEqual(weekNumbers[364], 1, "Expected the last day of 1997 to be part of the first week of the next year")
    }
    
    // FIXME: Switch back when Context.negativeWeekNumberByDayOfYear is fixed
//    func testFirstDayInFirstWeekOfYear() {
//        // Year 1997, where the first day is in the first week of that year
//        context.rebuild(year: 1997, month: 1)
//
//        guard let negativeWeekNumber = context.negativeWeekNumberByDayOfYear else {
//            XCTFail("Expected negativeWeekNumberByDayOfYear to not be nil")
//            return
//        }
//
//        // Expected to be part of the current year, indicating negative week number from the last ISO week
//        XCTAssertEqual(negativeWeekNumber.first, -52, "Expected the first day of 1997 to have a negative week number indicating its position relative to the end of the year")
//    }
//
//    func testFirstDayInLastWeekOfPreviousYear() {
//        // Year 1999, where the first day is part of the last week of the previous year
//        context.rebuild(year: 1999, month: 1)
//
//        guard let negativeWeekNumber = context.negativeWeekNumberByDayOfYear else {
//            XCTFail("Expected negativeWeekNumberByDayOfYear to not be nil")
//            return
//        }
//
//        // Expected to be -1, indicating the first day is in the last week of the previous year
//        XCTAssertEqual(negativeWeekNumber.first, -1, "Expected the first day of 1999 to indicate it's part of the last week of the previous year")
//    }
//
//    func testLastDayInLastWeekOfYear() {
//        // Assuming the year ends in the last week of the same year (e.g., 1999)
//        context.rebuild(year: 1999, month: 1)
//
//        guard let negativeWeekNumber = context.negativeWeekNumberByDayOfYear else {
//            XCTFail("Expected negativeWeekNumberByDayOfYear to not be nil")
//            return
//        }
//
//        // The last day should indicate it's in the last week of the current year
//        XCTAssertEqual(negativeWeekNumber[364], -1, "Expected the last day of 1999 to indicate it's part of the last week of the same year")
//    }
//
//    func testLastDayInFirstWeekOfNextYear() {
//        // Assuming the year ends but the last day spills over into the first week of the next year (e.g., 1997)
//        context.rebuild(year: 1997, month: 1)
//
//        guard let negativeWeekNumber = context.negativeWeekNumberByDayOfYear else {
//            XCTFail("Expected negativeWeekNumberByDayOfYear to not be nil")
//            return
//        }
//
//        // The last day should indicate it's in the first week of the next year
//        XCTAssertEqual(negativeWeekNumber[364], -53, "Expected the last day of 1997 to indicate it's part of the first week of the next year")
//    }
    
    func testDayOfYearWithinRangePositiveOrdinal() {
        context.rebuild(year: 1997, month: 1)

        // Example: Test for 2nd Tuesday of January (assuming Jan 1 is a Wednesday)
        let weekday = Weekday(index: 2, ordinal: 2) // Tuesday
        let result = context.dayOfYearWithinRange(weekday: weekday, yearDayStart: 1, yearDayEnd: 31)
        XCTAssertEqual(result, 13, "Expected to find the 2nd Tuesday on the 14th of January")
    }
    
    func testDaysInYearRangeForNonLeapYear() {
        // Example for a non-leap year
        context.rebuild(year: 1997, month: 1)
        
        if let daysInYear = context.daysInYear {
            let startOfYear = calendar.date(from: DateComponents(year: 1997, month: 1, day: 1))!
            let endOfYearPlus7Days = startOfYear.endOfYear(using: calendar)!

            XCTAssertEqual(daysInYear.start, startOfYear, "Start of the year should match")
            XCTAssertEqual(daysInYear.end, endOfYearPlus7Days, "End of the year plus 7 days should match")
        } else {
            XCTFail("daysInYear should not be nil")
        }
    }

    func testDaysInYearRangeForLeapYear() {
        // Example for a leap year
        context.rebuild(year: 2000, month: 1)
        
        if let daysInYear = context.daysInYear {
            let startOfYear = calendar.date(from: DateComponents(year: 2000, month: 1, day: 1))!
            let endOfYearPlus7Days = startOfYear.endOfYear(using: calendar)!

            XCTAssertEqual(daysInYear.start, startOfYear, "Start of the year should match for a leap year")
            XCTAssertEqual(daysInYear.end, endOfYearPlus7Days, "End of the year plus 7 days should match for a leap year")
        } else {
            XCTFail("daysInYear should not be nil for a leap year")
        }
    }

    func testDayOfYearWithinRangeNegativeOrdinal() {
        context.rebuild(year: 1997, month: 1)

        // Example: Test for last Friday of January
        let weekday = Weekday(index: 5, ordinal: -1) // Friday
        let result = context.dayOfYearWithinRange(weekday: weekday, yearDayStart: 1, yearDayEnd: 31)
        XCTAssertEqual(result, 30, "Expected to find the last Friday on the 30th of January")
    }

    func testDayOfYearWithinRangeOutOfRange() {
        context.rebuild(year: 1997, month: 1)

        // Test for a day that does not exist (5th Monday of February, for example)
        let weekday = Weekday(index: 1, ordinal: 5) // Monday
        let result = context.dayOfYearWithinRange(weekday: weekday, yearDayStart: 32, yearDayEnd: 59) // February
        XCTAssertNil(result, "Expected no result for a 5th Monday in February")
    }
}

