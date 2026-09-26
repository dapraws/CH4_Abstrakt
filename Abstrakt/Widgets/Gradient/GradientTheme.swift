import SwiftUI

enum GradientTheme: String, CaseIterable, Identifiable, Codable {
    case rubyAurora = "ruby-aurora"
    case midnightCyan = "midnight-cyan"
    case fractalPrism = "fractal-prism"
    case sunsetAmber = "sunset-amber"

    var id: String { rawValue }

    static let defaultTheme: GradientTheme = .rubyAurora

    static func from(id: String?) -> GradientTheme {
        guard let id else { return .defaultTheme }
        if id == "velvet-violet" { return .fractalPrism }
        return GradientTheme(rawValue: id) ?? .defaultTheme
    }

    var displayName: String {
        switch self {
        case .rubyAurora:
            "Ruby"
        case .midnightCyan:
            "Cyan"
        case .fractalPrism:
            "Fractal"
        case .sunsetAmber:
            "Amber"
        }
    }

    var baseGradient: [Color] {
        switch self {
        case .rubyAurora:
            [Color(red: 0.36, green: 0.05, blue: 0.10), Color(red: 0.20, green: 0.03, blue: 0.06)]
        case .midnightCyan:
            [Color(red: 0.04, green: 0.14, blue: 0.20), Color(red: 0.02, green: 0.06, blue: 0.10)]
        case .fractalPrism:
            [Color(red: 0.72, green: 0.06, blue: 0.24), Color(red: 0.92, green: 0.68, blue: 0.46)]
        case .sunsetAmber:
            [Color(red: 0.08, green: 0.08, blue: 0.09), Color(red: 0.14, green: 0.06, blue: 0.02)]
        }
    }

    var topLeftGlow: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.58, green: 0.08, blue: 0.16)
        case .midnightCyan:
            Color(red: 0.08, green: 0.32, blue: 0.44)
        case .fractalPrism:
            Color(red: 0.88, green: 0.12, blue: 0.28)
        case .sunsetAmber:
            Color(red: 0.06, green: 0.06, blue: 0.07)
        }
    }

    var midFieldGlow: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.82, green: 0.12, blue: 0.22)
        case .midnightCyan:
            Color(red: 0.10, green: 0.68, blue: 0.80)
        case .fractalPrism:
            Color(red: 0.95, green: 0.46, blue: 0.16)
        case .sunsetAmber:
            Color(red: 0.22, green: 0.08, blue: 0.02).opacity(0.80)
        }
    }

    var highlightArc: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.94, green: 0.48, blue: 0.58).opacity(0.35)
        case .midnightCyan:
            Color(red: 0.48, green: 0.90, blue: 0.95).opacity(0.35)
        case .fractalPrism:
            Color(red: 0.98, green: 0.70, blue: 0.40).opacity(0.35)
        case .sunsetAmber:
            Color(red: 0.98, green: 0.55, blue: 0.18).opacity(0.25)
        }
    }

    var haloTransition: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.65, green: 0.07, blue: 0.15).opacity(0.85)
        case .midnightCyan:
            Color(red: 0.08, green: 0.48, blue: 0.60).opacity(0.85)
        case .fractalPrism:
            Color(red: 0.92, green: 0.35, blue: 0.12).opacity(0.85)
        case .sunsetAmber:
            Color(red: 0.88, green: 0.34, blue: 0.05).opacity(0.88)
        }
    }

    var bottomRightDome: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.22, green: 0.03, blue: 0.06)
        case .midnightCyan:
            Color(red: 0.03, green: 0.08, blue: 0.12)
        case .fractalPrism:
            Color(red: 0.92, green: 0.68, blue: 0.46)
        case .sunsetAmber:
            Color(red: 1.00, green: 0.50, blue: 0.10)
        }
    }

    var swatchColors: [Color] {
        [midFieldGlow, bottomRightDome]
    }
}

// Backward-compatibility alias
typealias WeatherEditorialGradientTheme = GradientTheme
