//
//  DataTable.swift
//  Candlesticks
//
//  Created by Swift on 19/04/2025.
//


// Views/DataTable/DataTable.swift
import SwiftUI

struct DataTable: View {
    let data: [MarketData]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Market Data Table")
                .font(.headline)
                .padding(.bottom, 5) // Reduced padding slightly

            // Use Grid for layout
            Grid(alignment: .leadingFirstTextBaseline, horizontalSpacing: 10, verticalSpacing: 5) {
                headerRow // Use computed property for header
                Divider().gridCellUnsizedAxes(.horizontal) // Span divider across columns

                // Loop through data for rows
                ForEach(data) { item in
                    dataRow(for: item) // Use helper function for data row
                    Divider().gridCellUnsizedAxes(.horizontal)
                }
            }
            .font(.caption) // Apply caption font to the entire grid
        }
    }

    // Computed property for the header row (improves body readability)
    private var headerRow: some View {
        GridRow {
            HeaderCell("Time")
            HeaderCell("Open")
            HeaderCell("High")
            HeaderCell("Low")
            HeaderCell("Close")
            HeaderCell("Vol")
        }
    }

    // Helper function to create a data row (improves body readability)
    private func dataRow(for item: MarketData) -> some View {
        GridRow {
            // Use static formatters from DataFormatter utility
            DataCell(DataFormatter.formatTime(item.dateTime))
            DataCell(DataFormatter.formatPrice(item.open))
            DataCell(DataFormatter.formatPrice(item.high))
            DataCell(DataFormatter.formatPrice(item.low))
            closePriceCell(for: item) // Use specific helper for styled cell
            DataCell(DataFormatter.formatVolume(item.volume))
        }
    }

    // Helper function for the Close price cell with color styling
    private func closePriceCell(for item: MarketData) -> some View {
        DataCell(DataFormatter.formatPrice(item.close))
            .foregroundStyle(item.isPositive ? .green : .red)
    }

    // --- Internal Cell Components ---
    // Kept private here as they are simple and only used by DataTable.
    // Could be moved to DataTableCell.swift if they become complex or reused.

    private func HeaderCell(_ text: String) -> some View {
        Text(text)
            .fontWeight(.semibold) // Use semibold for headers
            .lineLimit(1)
    }

    private func DataCell(_ text: String) -> some View {
        Text(text)
            .lineLimit(1) // Prevent wrapping in cells
    }
}