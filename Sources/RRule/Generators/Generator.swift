//
//  Generator.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

class Generator {
    let context: Context
    
    init(context: Context) {
        self.context = context
    }
    
    func combineDatesAndTimes(dayset: [Int?], timeset: [[String: [Int]]]) -> [Date] {
        fatalError("Subclasses must implement `combineDatesAndTimes`.")
    }
    
    func processTimeset(date: Date, timeset: [[String: [Int]]]) -> [Date] {
        guard !timeset.isEmpty else { return [date] }
        
        var resultDates: [Date] = []
        
        for time in timeset {
            guard let hours = time["hour"], let minutes = time["minute"], let seconds = time["second"] else { continue }
            
            for hour in hours.sorted() {
                for minute in minutes.sorted() {
                    for second in seconds.sorted() {
                        var dateComponents = context.calendar.dateComponents([.year, .month, .day, .timeZone], from: date)
                        dateComponents.hour = hour
                        dateComponents.minute = minute
                        dateComponents.second = second
                        dateComponents.timeZone = context.tz
                        
                        if let specificDate = context.calendar.date(from: dateComponents) {
                            resultDates.append(specificDate)
                        }
                    }
                }
            }
        }
        
        return resultDates
    }
}
