//
//  ContentView.swift
//  Candlesticks
//
//  Created by Swift on 19/04/2025.
//


// Views/ContentView.swift
import SwiftUI
import Charts // Required if subviews use Charts directly, good practice to import

struct ContentView: View {
    // Observe the ViewModel
    @StateObject private var viewModel = MarketDataViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // Display content based on ViewModel state
                if viewModel.isLoading {
                    ProgressView("Loading data...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorDisplayView(message: errorMessage) // Extracted error view
                } else if viewModel.marketData.isEmpty {
                    Text("No data available").padding()
                } else {
                    // Main content area when data is loaded
                    DataDisplayArea(marketData: viewModel.marketData) // Extracted content view
                }
            }
            .navigationTitle("Market Data")
            .toolbar {
                Button("Reload Data") {
                    viewModel.loadData() // Use ViewModel's load function
                }
            }
            .onAppear {
                // Load data when the view first appears
                if viewModel.marketData.isEmpty {
                    viewModel.loadData()
                }
            }
        }
    }
}

// Helper View for displaying errors (keeps ContentView cleaner)
struct ErrorDisplayView: View {
    let message: String
    var body: some View {
        Text("Error: \(message)")
            .foregroundStyle(.red)
            .padding()
    }
}

// Helper View for the main content area (keeps ContentView cleaner)
struct DataDisplayArea: View {
    let marketData: [MarketData]
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Price Chart").font(.headline)
                CandlestickChart(data: marketData) // Use dedicated chart view
                    .frame(height: 300)
                    .padding(.bottom)

                Text("Volume Chart").font(.headline)
                VolumeChart(data: marketData) // Use dedicated chart view
                    .frame(height: 120)

                DataTable(data: marketData) // Use dedicated table view
                    .padding(.top)
            }
            .padding()
        }
    }
}