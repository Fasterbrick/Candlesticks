//
//  MarketDataViewModel.swift
//  Candlesticks
//
//  Created by Swift on 19/04/2025.
//


// ViewModel/MarketDataViewModel.swift
import SwiftUI // Needed for ObservableObject, @Published
import Foundation // Needed for Date, NSError

// Manages the data and loading state for the views
class MarketDataViewModel: ObservableObject {
    @Published var marketData: [MarketData] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // Function to load data (can be called from the view)
    func loadData() {
        isLoading = true
        errorMessage = nil // Clear previous errors

        // Simulate async loading (or replace with actual network/file loading)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }

            // Use the globally accessible sample data and parser
            do {
                self.marketData = try CSVParser.parse(csvString: CSVSampleData.sample)
            } catch {
                self.errorMessage = error.localizedDescription
                self.marketData = [] // Clear data on error
            }
            self.isLoading = false
        }
    }
}

// Moved sample data here for encapsulation, could also be in its own file.
// Made static for easy access without instantiating anything.
struct CSVSampleData {
    static let sample = """
    DateTime,Open,High,Low,Close,Volume,Spread,Real_Volume
    2025-04-17 15:00:00+01:00,84361.82,84745.49,84252.2,84561.14,15016,2844,0
    2025-04-17 16:00:00+01:00,84561.02,84867.65,84555.73,84755.86,27410,2490,0
    2025-04-17 17:00:00+01:00,84755.86,84771.75,84294.97,84454.97,27156,2527,0
    2025-04-17 18:00:00+01:00,84454.97,84470.95,83712.01,84097.14,25851,2464,0
    2025-04-17 19:00:00+01:00,84097.97,84722.28,84096.13,84564.18,22303,2866,0
    2025-04-17 20:00:00+01:00,84564.18,85095.6,84422.87,84932.57,26228,2275,0
    """
}