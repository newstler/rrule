//
//  Humanizer.swift
//  
//
//  Created by Yuri Sidorov on 07.03.2024.
//

import Foundation

    class Humanizer {
        let rrule: Rule  // Assuming `Rule` is a class that has been defined as part of the translation.
        let options: [String: Any]
        
        static let dayNames = [
            "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
        ]
        
        var buffer: String = "every"
        
        init(rrule: Rule, options: [String: Any]) {
            self.rrule = rrule
            self.options = options
        }
        
        func toString() -> String {
            guard let freq = options["freq"] as? String else { return "Invalid frequency" }
            
            switch freq.lowercased() {
            case "daily":
                daily()
            case "weekly":
                weekly()
            case "monthly":
                monthly()
            default:
                break
            }
            
            // Example for handling `until` and `count` options, similar logic can be applied for other options
            if let until = options["until"] {
                // Implement logic for `until`
            } else if let count = options["count"] as? Int {
                add("for")
                add(String(count))
                add(plural: count) ? "times" : "time"
            }
            
            return buffer
        }
        
        private func add(_ string: String) {
            buffer += " \(string)"
        }
        
        private func plural(_ num: Int) -> Bool {
            num % 100 != 1
        }
        
        // Implement `daily`, `weekly`, `monthly` functions based on the Ruby code logic
        
        private func daily() {
            // Example implementation
            if let interval = options["interval"] as? Int, interval != 1 {
                add(String(interval))
            }
            // Continue translating the logic from Ruby
        }
        
        private func weekly() {
            // Example implementation
            if let interval = options["interval"] as? Int, interval != 1 {
                add(String(interval))
            }
            // Continue translating the logic from Ruby
        }
        
        private func monthly() {
            // Example implementation
            if let interval = options["interval"] as? Int, interval != 1 {
                add(String(interval))
            }
            // Continue translating the logic from Ruby
        }
        
        // Add other methods as needed, translating the Ruby logic to Swift
    }
