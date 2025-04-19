// Views/Charts/CandlestickChart.swift
import SwiftUI
import Charts
import Foundation // For DateFormatter, NumberFormatter

struct CandlestickChart: View {
    let data: [MarketData]

    // Formatter for axis labels and accessibility date strings
    private let axisDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Using HH:mm for consistency
        return formatter
    }()

    // Formatter for accessibility number strings (e.g., consistent decimal places)
    private let accessibilityNumberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2 // Ensure 2 decimal places for prices
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    // Helper function to safely format numbers for accessibility
    private func formatAccessibilityNumber(_ number: Double) -> String {
        return accessibilityNumberFormatter.string(from: NSNumber(value: number)) ?? "\(number)" // Fallback to default string
    }

    var body: some View {
        Chart {
            ForEach(data) { item in
                candleBodyMark(for: item)
                candleWickMark(for: item)
            }
        }
        .chartXAxis { axisMarks }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartYAxis { AxisMarks(position: .leading) }
    }

    // Helper function for Candle Body (RectangleMark)
    private func candleBodyMark(for item: MarketData) -> some ChartContent {
        // --- Prepare accessibility strings beforehand ---
        let timeString = axisDateFormatter.string(from: item.dateTime)
        let openString = formatAccessibilityNumber(item.open)
        let closeString = formatAccessibilityNumber(item.close)
        let label = "Candle \(timeString)"
        let value = "O:\(openString), C:\(closeString)"
        // --- End Accessibility String Preparation ---

        return RectangleMark(
            x: .value("Time", item.dateTime),
            yStart: .value("Price", min(item.open, item.close)),
            yEnd: .value("Price", max(item.open, item.close)),
            width: .fixed(8)
        )
        // Apply style first
        .foregroundStyle(item.isPositive ? Color.green : Color.red)
        // Apply accessibility using the pre-formatted strings
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }

    // Helper function for Candle Wick (RuleMark)
    private func candleWickMark(for item: MarketData) -> some ChartContent {
        // --- Prepare accessibility strings beforehand ---
        let timeString = axisDateFormatter.string(from: item.dateTime)
        let highString = formatAccessibilityNumber(item.high)
        let lowString = formatAccessibilityNumber(item.low)
        let label = "Wick \(timeString)"
        let value = "H:\(highString), L:\(lowString)"
        // --- End Accessibility String Preparation ---

        return RuleMark(
            x: .value("Time", item.dateTime),
            yStart: .value("Low", item.low),
            yEnd: .value("High", item.high)
        )
        // Apply style after lineWidth
        .foregroundStyle(item.isPositive ? Color.green : Color.red)
        // Apply accessibility using the pre-formatted strings
        .accessibilityLabel(label)
        .accessibilityValue(value)
    }

    // Computed property for X Axis Marks (unchanged)
    private var axisMarks: some AxisContent {
        AxisMarks(values: .stride(by: .hour, count: 1)) { value in
            AxisGridLine()
            AxisTick()
            if let date = value.as(Date.self) {
                AxisValueLabel(axisDateFormatter.string(from: date))
            }
        }
    }
}
