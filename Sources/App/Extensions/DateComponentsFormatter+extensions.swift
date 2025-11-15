//
//  DateComponentsFormatter+extensions.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/15/25.
//

import Foundation

public extension DateComponentsFormatter {
    static let uptimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter
    }()
}
