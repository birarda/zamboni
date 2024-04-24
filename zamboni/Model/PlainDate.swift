//
//  PlainDate.swift
//  zamboni
//
//  Created by Stephen on 2024-04-23.
//

import Foundation

struct PlainDate {
    private var year: Int;
    private var day: Int;
    private var month: Int;
    
    private let pacificTimezone = TimeZone(identifier: "America/Los_Angeles")!
    private let inputDateFormatter: DateFormatter
    
    init() {
        self.inputDateFormatter = DateFormatter()
        inputDateFormatter.dateFormat = "yyyy-M-d HH:mm"
        inputDateFormatter.timeZone = pacificTimezone
        
        // pull the components out of the passed date so we can create a from/to bordering it in pacific
        let components = Calendar.current.dateComponents(in: pacificTimezone, from: Date())
        
        year = components.year!
        day = components.day!
        month = components.month!        
    }
    
    init(apiString: String) {
        self.init()
        
        let apiDate = APIService.dateFormatter.date(from: apiString)!
        
        let components = Calendar.current.dateComponents(in: pacificTimezone, from: apiDate)
        year = components.year!
        day = components.day!
        month = components.month!
    }
    
    func toEndOfDayString() -> String {
        let inputString = "\(self.year)-\(self.month)-\(self.day) 00:00"
        
        let fromDate = inputDateFormatter.date(from: inputString)!
        let toDate = Calendar.current.date(byAdding: .day, value: 1, to: fromDate)!
        
        return APIService.dateFormatter.string(from: toDate)
    }
    
    func toStartString(daysBack: Int) -> String? {
        let inputString = "\(self.year)-\(self.month)-\(self.day) 00:00"
        let fromDate = inputDateFormatter.date(from: inputString)!
        
        if let date = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date()) {
            return APIService.dateFormatter.string(from: date)
        } else {
            return .none
        }
    }
    
    func label() -> String {
        return "\(day) / \(month) / \(year)"
    }
}

extension PlainDate: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine([year, day, month])
    }
}

extension PlainDate : Comparable {
    static func < (lhs: PlainDate, rhs: PlainDate) -> Bool {
        if lhs.year != rhs.year {
            return lhs.year < rhs.year
        } else if lhs.month != rhs.month {
            return lhs.month < rhs.month
        } else {
            return lhs.day < rhs.day
        }
    }
    
    static func == (lhs: PlainDate, rhs: PlainDate) -> Bool {
        return lhs.year == rhs.year && lhs.month == rhs.month
        && lhs.day == rhs.day
    }
}
