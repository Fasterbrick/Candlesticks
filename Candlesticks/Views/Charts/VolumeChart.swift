//
//  VolumeChart.swift
//  Candlesticks
//
//  Created by Swift on 19/04/2025.
//


// Views/Charts/VolumeChart.swift
import SwiftUI
import Charts
import Foundation // For DateFormatter

struct VolumeChart: View {
    let data: [MarketData]

    // Formatter specific to this chart's axis
    private let axisDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm" // Hour:Minute format
        return formatter
    }()

    var body: some View {
        Chart {
            ForEach(data) { item in // No need for id: \.id when Identifiable
                // Volume Bar
                BarMark(
                    x: .value("Time", item.dateTime),
                    y: .value("Volume", item.volume)
                )
                // Use opacity for slightly lighter colors
                .foregroundStyle(item.isPositive ? Color.green.opacity(0.7) : Color.red.opacity(0.7))
                .cornerRadius(2) // Slightly rounded corners
                .accessibilityLabel("Volume \(item.dateTime, format: .dateTime)")
                .accessibilityValue("\(item.volume, format: .number)")
            }
        }
        .chartXAxis { axisMarks } // Use computed property for axis
        .chartYScale(domain: .automatic(includesZero: true)) // Volume should start from 0
        .chartYAxis { AxisMarks(position: .leading) } // Standard Y axis marks
    }

    // Computed property for X Axis Marks (could be shared if identical to Candlestick)
    private var axisMarks: some AxisContent {
        AxisMarks(values: .stride(by: .hour, count: 1)) { value in
            AxisGridLine()
            AxisTick()
            if let date = value.as(Date.self) {
                // Use the specific formatter for display
                AxisValueLabel(axisDateFormatter.string(from: date))
            }
        }
    }
}