//
//  MarketData.swift
//  Candlesticks
//
//  Created by Swift on 19/04/2025.
//


// Data/MarketData.swift
import Foundation // Needed for UUID, Date

// Data Model
struct MarketData: Identifiable {
    let id = UUID()
    let dateTime: Date
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Int
    let spread: Int // Included from original struct
    let realVolume: Int // Included from original struct

    // Computed property to determine candle color
    var isPositive: Bool {
        close >= open
    }
}