//
//  DateComponentsFormatter+extensions.swift
//  CoffeeServer
//
//  Created by Michael Critz on 11/15/25.
//

import Foundation

public enum UptimeFormatter {
    /// Formats a time interval as an uptime string.
    /// - Parameter seconds: The time interval in seconds.
    /// - Returns: A string like "D:HH:MM:SS" or "HH:MM:SS" depending on duration.
    public static func formattedUptime(from seconds: TimeInterval) -> String {
        #if canImport(Darwin)
        // On Apple platforms, use DateComponentsFormatter
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: seconds) ?? fallbackFormat(seconds)
        #else
        // On Linux (swift-corelibs-foundation), DateComponentsFormatter is unavailable
        return fallbackFormat(seconds)
        #endif
    }

    // MARK: - Private helpers

    private static func fallbackFormat(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let days = total / 86_400
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60
        let secs = total % 60
        if days > 0 {
            return String(format: "%d:%02d:%02d:%02d", days, hours, minutes, secs)
        } else {
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        }
    }
}
