import SwiftUI
import Charts

// Data Model (No changes)
struct MarketData: Identifiable {
    let id = UUID()
    let dateTime: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
    let spread: Int
    let realVolume: Int

    var isPositive: Bool {
        close >= open
    }
}

// Main Content View (No changes)
struct ContentView: View {
    @State private var marketData: [MarketData] = []
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading {
                    ProgressView("Loading data...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                        .foregroundStyle(.red)
                        .padding()
                } else if marketData.isEmpty {
                    Text("No data available")
                        .padding()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Price Chart")
                                .font(.headline)

                            CandlestickChart(data: marketData)
                                .frame(height: 300)
                                .padding(.bottom)

                            Text("Volume Chart")
                                .font(.headline)

                            VolumeChart(data: marketData)
                                .frame(height: 120)

                            // Use the simplified DataTable view
                            DataTable(data: marketData)
                                .padding(.top)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Market Data Visualization")
            .toolbar {
                Button("Load Sample Data") {
                    loadSampleData()
                }
            }
            .onAppear {
                loadSampleData()
            }
        }
    }

    // Data Loading and Parsing (No changes)
    func loadSampleData() {
        isLoading = true

        let sampleCSV = """
        DateTime,Open,High,Low,Close,Volume,Spread,Real_Volume
        2025-04-17 15:00:00+01:00,84361.82,84745.49,84252.2,84561.14,15016,2844,0
        2025-04-17 16:00:00+01:00,84561.02,84867.65,84555.73,84755.86,27410,2490,0
        2025-04-17 17:00:00+01:00,84755.86,84771.75,84294.97,84454.97,27156,2527,0
        2025-04-17 18:00:00+01:00,84454.97,84470.95,83712.01,84097.14,25851,2464,0
        2025-04-17 19:00:00+01:00,84097.97,84722.28,84096.13,84564.18,22303,2866,0
        2025-04-17 20:00:00+01:00,84564.18,85095.6,84422.87,84932.57,26228,2275,0
        """

        do {
            marketData = try parseCSV(csvString: sampleCSV)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func parseCSV(csvString: String) throws -> [MarketData] {
        var result: [MarketData] = []

        let rows = csvString.components(separatedBy: .newlines)
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let fallbackFormatter = DateFormatter()
        fallbackFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"

        for i in 1..<rows.count {
            let row = rows[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if row.isEmpty { continue }

            let columns = row.components(separatedBy: ",")
            if columns.count >= 8 {
                guard let dateTime = dateFormatter.date(from: columns[0]) ?? fallbackFormatter.date(from: columns[0]) else {
                    throw NSError(domain: "CSV Parser", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid date format at row \(i): \(columns[0])"])
                }

                guard let open = Double(columns[1]),
                        let high = Double(columns[2]),
                        let low = Double(columns[3]),
                        let close = Double(columns[4]),
                        let volume = Int(columns[5]),
                        let spread = Int(columns[6]),
                        let realVolume = Int(columns[7]) else {
                    throw NSError(domain: "CSV Parser", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid number format at row \(i)"])
                }

                let data = MarketData(
                    dateTime: dateTime,
                    open: open,
                    high: high,
                    low: low,
                    close: close,
                    volume: volume,
                    spread: spread,
                    realVolume: realVolume
                )

                result.append(data)
            }
        }
        result.sort { $0.dateTime < $1.dateTime }
        return result
    }
}

// Candlestick Chart View (No changes)
struct CandlestickChart: View {
    let data: [MarketData]

    private let axisDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        Chart {
            ForEach(data, id: \.id) { item in
                RectangleMark(
                    x: .value("Date", item.dateTime),
                    yStart: .value("Price", min(item.open, item.close)),
                    yEnd: .value("Price", max(item.open, item.close)),
                    width: .fixed(8)
                )
                .foregroundStyle(item.isPositive ? Color.green : Color.red)
                 .accessibilityLabel("Candle \(item.dateTime, format: .dateTime)")
                 .accessibilityValue("Open: \(item.open, format: .number), Close: \(item.close, format: .number)")


                RuleMark(
                    x: .value("Date", item.dateTime),
                    yStart: .value("Low", item.low),
                    yEnd: .value("High", item.high)
                )
                .foregroundStyle(item.isPositive ? Color.green : Color.red)
                .lineWidth(1)
                 .accessibilityLabel("Wick \(item.dateTime, format: .dateTime)")
                 .accessibilityValue("High: \(item.high, format: .number), Low: \(item.low, format: .number)")
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                 AxisGridLine()
                 AxisTick()
                 if let date = value.as(Date.self) {
                     AxisValueLabel(axisDateFormatter.string(from: date))
                 } else {
                     AxisValueLabel("Invalid Date")
                 }
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
        .chartYAxis {
            AxisMarks(position: .leading)
        }
    }
}

// Volume Chart View (No changes)
struct VolumeChart: View {
    let data: [MarketData]

    private let axisDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    var body: some View {
        Chart {
            ForEach(data, id: \.id) { item in
                BarMark(
                    x: .value("Date", item.dateTime),
                    y: .value("Volume", item.volume)
                )
                .foregroundStyle(item.isPositive ? Color.green.opacity(0.7) : Color.red.opacity(0.7))
                .cornerRadius(2)
                .accessibilityLabel("Volume \(item.dateTime, format: .dateTime)")
                .accessibilityValue("\(item.volume, format: .number)")
            }
        }
        .chartXAxis {
             AxisMarks(values: .stride(by: .hour, count: 1)) { value in
                 AxisGridLine()
                 AxisTick()
                 if let date = value.as(Date.self) {
                     AxisValueLabel(axisDateFormatter.string(from: date))
                 } else {
                     AxisValueLabel("Invalid Date")
                 }
             }
        }
        .chartYScale(domain: .automatic(includesZero: true))
        .chartYAxis {
             AxisMarks(position: .leading)
        }
    }
}

// Data Table View (Simplified using LazyVStack/HStack without fixed frames)
struct DataTable: View {
    let data: [MarketData]

    // Use horizontal spacing in HStacks
    private let horizontalSpacing: CGFloat = 8
    private let verticalSpacing: CGFloat = 4 // Reduced vertical spacing for a more compact look

    var body: some View {
        VStack(alignment: .leading) { // Keep the title layout
            Text("Market Data Table")
                .font(.headline)
                .padding(.bottom, 4) // <-- Error was reported near here

            // Use LazyVStack for vertical stacking and scrolling efficiency
            // Without strict column alignment via fixed frames
            LazyVStack(alignment: .leading, spacing: verticalSpacing) { // Align content leading
                // Header Row using HStack - uses Spacers for distribution
                HStack(spacing: horizontalSpacing) {
                    Text("Time").bold()
                    Spacer() // Push elements apart
                    Text("Open").bold()
                    Spacer()
                    Text("High").bold()
                    Spacer()
                    Text("Low").bold()
                    Spacer()
                    Text("Close").bold()
                    Spacer()
                    Text("Vol").bold()
                }
                .font(.caption)
                .padding(.horizontal, 2) // Add slight horizontal padding to the header

                Divider() // Horizontal divider

                // Data Rows using ForEach and HStack - uses Spacers for distribution
                ForEach(data, id: \.id) { item in
                    HStack(spacing: horizontalSpacing) {
                        Text(formatTime(item.dateTime))
                        Spacer() // Push elements apart
                        Text(formatPrice(item.open))
                        Spacer()
                        Text(formatPrice(item.high))
                        Spacer()
                        Text(formatPrice(item.low))
                        Spacer()
                        Text(formatPrice(item.close))
                            .foregroundStyle(item.isPositive ? Color.green : Color.red) // Apply color
                        Spacer()
                        Text(formatVolume(item.volume))
                    }
                    .font(.caption)
                    .padding(.horizontal, 2) // Add slight horizontal padding to data rows
                }
            }
            // Optional: Add padding to the LazyVStack itself if needed
            // .padding(.horizontal)
        }
    }

    // MARK: - Formatting Functions (No changes)

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

    private func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: price)) ?? String(format: "%.2f", price)
    }

    private func formatVolume(_ volume: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if volume >= 1_000_000 {
            formatter.multiplier = 0.000001
            formatter.positiveSuffix = "M"
            formatter.negativeSuffix = "M"
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 1
        } else if volume >= 1000 {
            formatter.multiplier = 0.001
            formatter.positiveSuffix = "K"
            formatter.negativeSuffix = "K"
            formatter.minimumFractionDigits = 0
             formatter.maximumFractionDigits = 1
        } else {
             formatter.multiplier = 1.0
             formatter.positiveSuffix = ""
             formatter.negativeSuffix = ""
             formatter.minimumFractionDigits = 0
             formatter.maximumFractionDigits = 0
        }

        return formatter.string(from: NSNumber(value: volume)) ?? "\(volume)"
    }
}

// App Entry Point (No changes)
@main
struct MarketDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
