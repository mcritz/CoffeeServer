//
//  Date+FormattedWithTimezone.swift
//  CoffeeServer
//
//  Created by Michael Critz on 12/3/25.
//

import Foundation

extension Date {
    public func formattedWith(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .short, timeZone: TimeZone = TimeZone(identifier: "America/Los_Angeles")!) -> String {
        var calendar = Foundation.Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.timeZone = timeZone
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle

        return formatter.string(from: self)
    }
}
