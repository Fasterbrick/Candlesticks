//
//  DataFormatter.swift
//  Candlesticks
//
//  Created by Swift on 19/04/2025.
//


// Utils/DataFormatter.swift
import Foundation // For DateFormatter, NumberFormatter (though using String(format:))

// Provides static methods for consistent data formatting
struct DataFormatter {

    // Formats a Date into HH:mm string
    static func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    // Formats a Double price value to 2 decimal places
    static func formatPrice(_ price: Double) -> String {
        // Using String(format:) is concise for simple cases
        String(format: "%.2f", price)
        // Alternative using NumberFormatter for more options (locale, etc.)
        // let formatter = NumberFormatter()
        // formatter.numberStyle = .decimal
        // formatter.minimumFractionDigits = 2
        // formatter.maximumFractionDigits = 2
        // return formatter.string(from: NSNumber(value: price)) ?? "\(price)"
    }

    // Formats an Int volume into a shortened string (e.g., 1.5K, 2.1M)
    static func formatVolume(_ volume: Int) -> String {
        let num = Double(volume)
        switch num {
        case ..<1000:
            // Return as is if less than 1000
            return "\(volume)"
        case 1000..<1_000_000:
            // Format as K (thousands) with one decimal place
            return String(format: "%.1fK", num / 1000.0)
        default:
            // Format as M (millions) with one decimal place
            return String(format: "%.1fM", num / 1_000_000.0)
        }
    }
}