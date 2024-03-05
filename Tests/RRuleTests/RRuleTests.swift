import XCTest
@testable import RRule

final class RRuleTests: XCTestCase {
//    func testExample() throws {
//        // XCTest Documentation
//        // https://developer.apple.com/documentation/xctest
//
//        // Defining Test Cases and Test Methods
//        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
//    }
//    
    func testDailyRecurrence() {
          let rruleString = "FREQ=DAILY;INTERVAL=2"
          guard let rule = try? RRuleParser.parse(rruleString: rruleString) else {
              XCTFail("Parsing failed for rule: \(rruleString)")
              return
          }
          
          let startDate = DateComponents(calendar: .current, year: 2024, month: 3, day: 1).date!
          let endDate = DateComponents(calendar: .current, year: 2024, month: 3, day: 10).date!
          let dates = rule.generateDates(startingFrom: startDate, endingBy: endDate)
          
          XCTAssertEqual(dates.count, 5, "Expected 5 occurrences but got \(dates.count)")
      }
      
      func testWeeklyRecurrenceByDay() {
          // This test should verify weekly recurrence that specifies certain days of the week
      }
      
      func testMonthlyRecurrenceByMonthDay() {
          // This test should verify monthly recurrence by specific days of the month
      }
      
      // Add more tests for yearly recurrence, leap years, exclusions, and edge cases
      
      // Utility function to help with date comparisons if needed
      func datesContain(_ dates: [Date], year: Int, month: Int, day: Int) -> Bool {
          let calendar = Calendar.current
          return dates.contains(where: { date in
              let components = calendar.dateComponents([.year, .month, .day], from: date)
              return components.year == year && components.month == month && components.day == day
          })
      }
}
