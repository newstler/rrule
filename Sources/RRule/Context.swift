//
//  Context.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

    class Context {
        var options: [String: Any]
        var dtstart: Date
        var tz: TimeZone
        var dayOfYearMask: [Bool]?
        var year: Int

        private var lastMonth: Int?
        private var lastYear: Int?

        init(options: [String: Any], dtstart: Date, tz: TimeZone) {
            self.options = options
            self.dtstart = dtstart
            self.tz = tz
            self.year = Calendar.current.component(.year, from: dtstart)
        }

        func rebuild(year: Int, month: Int) {
            self.year = year

            if year != lastYear {
                resetYear()
            }

            if let bynweekday = options["bynweekday"] as? [[Int]], !bynweekday.isEmpty, month != lastMonth || year != lastYear {
                var possibleDateRanges: [[Int]] = []

                switch options["freq"] as? String {
                case "YEARLY":
                    if let bymonth = options["bymonth"] as? [Int] {
                        possibleDateRanges = bymonth.map { elapsedDaysInYearByMonth[$0 - 1..<$0].map { $0 } }
                    } else {
                        possibleDateRanges = [[0, yearLengthInDays()]]
                    }
                case "MONTHLY":
                    possibleDateRanges = [elapsedDaysInYearByMonth[month - 1..<month].map { $0 }]
                default: break
                }

                if !possibleDateRanges.isEmpty {
                    self.dayOfYearMask = Array(repeating: false, count: yearLengthInDays())

                    for range in possibleDateRanges {
                        let yearDayStart = range.first!
                        let yearDayEnd = range.last! - 1

                        for weekday in bynweekday {
                            if let dayOfYear = dayOfYearWithinRange(weekday: weekday, yearDayStart: yearDayStart, yearDayEnd: yearDayEnd) {
                                dayOfYearMask?[dayOfYear] = true
                            }
                        }
                    }
                }
            }

            self.lastYear = year
            self.lastMonth = month
        }

        // MARK: - Private Methods

        private func resetYear() {
            // Reset all year-dependent properties to nil or their default states
            self.dayOfYearMask = nil
            // Add other properties as needed, following the same pattern
            
//            self.daysInYear = nil
//            self.yearLengthInDays = nil
//            self.nextYearLengthInDays = nil
//            self.firstDayOfYear = nil
//            self.firstWeekdayOfYear = nil
//            self.monthByDayOfYear = nil
//            self.monthDayByDayOfYear = nil
//            self.negativeMonthDayByDayOfYear = nil
//            self.weekdayByDayOfYear = nil
//            self.weekNumberByDayOfYear = nil
//            self.negativeWeekNumberByDayOfYear = nil
//            self.elapsedDaysInYearByMonth = nil
        }


        private func yearLengthInDays() -> Int {
            let isLeapYear = Calendar.current.isDateInLeapYear(dtstart)
            return isLeapYear ? 366 : 365
        }

        private func elapsedDaysInYearByMonth() -> [Int] {
            var elapsedDays: [Int] = []
            let calendar = Calendar.current
            var totalDays = 0
            
            for month in 1...12 {
                let dateComponents = DateComponents(year: self.year, month: month)
                guard let date = calendar.date(from: dateComponents),
                      let range = calendar.range(of: .day, in: .month, for: date) else { continue }
                
                totalDays += range.count
                elapsedDays.append(totalDays)
            }
            
            return elapsedDays
        }


        private func dayOfYearWithinRange(weekday: [Int], yearDayStart: Int, yearDayEnd: Int) -> Int? {
            // Assuming weekday contains information about the day of the week and its occurrence
            // This method needs to calculate which day of the year matches these criteria
            // Implementation will depend on the logic you have in your Ruby code
            return nil // Placeholder return
        }

    }

// Helper extension to check if a Date is in a leap year
extension Calendar {
    func isDateInLeapYear(_ date: Date) -> Bool {
        let year = self.component(.year, from: date)
        let dateComponents = DateComponents(year: year, month: 2, day: 29)
        return self.date(from: dateComponents) != nil
    }
}
