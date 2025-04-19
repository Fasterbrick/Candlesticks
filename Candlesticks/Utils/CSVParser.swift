//
//  CSVParser.swift
//  Candlesticks
//
//  Created by Swift on 19/04/2025.
//


// Utils/CSVParser.swift
import Foundation // For Date parsing, String manipulation, NSError

// Provides static function to parse CSV string into MarketData array
struct CSVParser {

    // Custom Error for specific parsing issues
    enum ParserError: Error, LocalizedError {
        case invalidDateFormat(row: Int, value: String)
        case invalidNumberFormat(row: Int)
        case incorrectColumnCount(row: Int, expected: Int, actual: Int)

        var errorDescription: String? {
            switch self {
            case .invalidDateFormat(let row, let value):
                return "Invalid date format at row \(row): \(value)"
            case .invalidNumberFormat(let row):
                return "Invalid number format at row \(row)"
            case .incorrectColumnCount(let row, let expected, let actual):
                return "Incorrect column count at row \(row): Expected \(expected), got \(actual)"
            }
        }
    }

    // Parses a CSV String into an array of MarketData objects
    static func parse(csvString: String) throws -> [MarketData] {
        var result: [MarketData] = []
        let rows = csvString.components(separatedBy: .newlines)

        // Prefer the specific custom format first for the sample data
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ" // e.g., 2025-04-17 15:00:00+01:00

        // Fallback ISO8601 formatter
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        // Start from index 1 to skip header row
        for i in 1..<rows.count {
            let rowString = rows[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if rowString.isEmpty { continue } // Skip empty lines

            let columns = rowString.components(separatedBy: ",")
            guard columns.count == 8 else { // Expect exactly 8 columns
                throw ParserError.incorrectColumnCount(row: i + 1, expected: 8, actual: columns.count)
            }

            // Parse Date (try custom, then ISO)
            guard let dateTime = customFormatter.date(from: columns[0]) ?? isoFormatter.date(from: columns[0]) else {
                throw ParserError.invalidDateFormat(row: i + 1, value: columns[0])
            }

            // Parse Numbers
            guard let open = Double(columns[1]),
                  let high = Double(columns[2]),
                  let low = Double(columns[3]),
                  let close = Double(columns[4]),
                  let volume = Int(columns[5]),
                  let spread = Int(columns[6]), // Keep parsing all original columns
                  let realVolume = Int(columns[7]) else {
                throw ParserError.invalidNumberFormat(row: i + 1)
            }

            // Create MarketData object
            let data = MarketData(
                dateTime: dateTime, open: open, high: high, low: low, close: close,
                volume: volume, spread: spread, realVolume: realVolume
            )
            result.append(data)
        }

        // Sort by date ascending before returning
        result.sort { $0.dateTime < $1.dateTime }
        return result
    }
}