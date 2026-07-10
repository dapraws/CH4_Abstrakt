//
//  LiveActivityTypography.swift
//  Abstrakt
//

import SwiftUI

struct LiveActivityTypography {
    /// Font for icons when displayed alone
    static let iconOnly = Font.system(size: 28, weight: .medium)
    
    /// Font for single words or short labels (e.g., "WED")
    static let singleWord = Font.system(size: 13, weight: .bold, design: .rounded)
    
    /// Font for numeric values or dynamic data (e.g., steps: "2,561", calories: "173")
    /// Uses monospaced digits to prevent layout shifting.
    static let numericValue = Font.system(size: 15, weight: .bold, design: .rounded).monospacedDigit()
    
    /// Font for splits, secondary details or small headings (e.g., high/low temp, circular progress label)
    static let detailLabel = Font.system(size: 11, weight: .semibold, design: .rounded)
    
    /// Font for micro elements or subtext
    static let microSubtext = Font.system(size: 9, weight: .medium, design: .rounded)
}

extension View {
    /// Helper to apply common text styling rules to prevent truncation inside Live Activities
    func liveActivityTextFormatting() -> some View {
        self
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .allowsTightening(true)
    }
}
