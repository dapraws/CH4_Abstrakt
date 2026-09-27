import SwiftUI

enum GradientTheme: String, CaseIterable, Identifiable, Codable {
    case rubyAurora = "ruby-aurora"
    case fractalPrism = "fractal-prism"
    case sunsetAmber = "sunset-amber"
    case dither = "dither"

    var id: String { rawValue }

    static let defaultTheme: GradientTheme = .rubyAurora

    static func from(id: String?) -> GradientTheme {
        guard let id else { return .defaultTheme }
        if id == "velvet-violet" { return .fractalPrism }
        if id == "dither" || id == "bayer" || id == "phosphor-dither" || id == "acid-dither" || id == "monochrome-dither" {
            return .dither
        }
        if id == "midnight-cyan" || id == "emerald-matrix" || id == "emerald-pulse" || id == "matrix" {
            return .defaultTheme
        }
        return GradientTheme(rawValue: id) ?? .defaultTheme
    }

    var displayName: String {
        switch self {
        case .rubyAurora:
            "Ruby"
        case .fractalPrism:
            "Fractal"
        case .sunsetAmber:
            "Amber"
        case .dither:
            "Dither"
        }
    }

    var baseGradient: [Color] {
        switch self {
        case .rubyAurora:
            [Color(red: 0.36, green: 0.05, blue: 0.10), Color(red: 0.20, green: 0.03, blue: 0.06)]
        case .fractalPrism:
            [Color(red: 0.04, green: 0.03, blue: 0.08), Color(red: 0.12, green: 0.08, blue: 0.20)]
        case .sunsetAmber:
            [Color(red: 0.08, green: 0.08, blue: 0.09), Color(red: 0.14, green: 0.06, blue: 0.02)]
        case .dither:
            [Color(red: 0.04, green: 0.04, blue: 0.05), Color(red: 0.07, green: 0.07, blue: 0.08)]
        }
    }

    var topLeftGlow: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.58, green: 0.08, blue: 0.16)
        case .fractalPrism:
            Color(red: 0.40, green: 0.18, blue: 0.70)
        case .sunsetAmber:
            Color(red: 0.06, green: 0.06, blue: 0.07)
        case .dither:
            Color(white: 0.10)
        }
    }

    var midFieldGlow: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.82, green: 0.12, blue: 0.22)
        case .fractalPrism:
            Color(red: 0.12, green: 0.65, blue: 0.78)
        case .sunsetAmber:
            Color(red: 0.22, green: 0.08, blue: 0.02).opacity(0.80)
        case .dither:
            Color(white: 0.85)
        }
    }

    var highlightArc: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.94, green: 0.48, blue: 0.58).opacity(0.35)
        case .fractalPrism:
            Color(red: 0.90, green: 0.35, blue: 0.65).opacity(0.35)
        case .sunsetAmber:
            Color(red: 0.98, green: 0.55, blue: 0.18).opacity(0.25)
        case .dither:
            Color.white.opacity(0.35)
        }
    }

    var haloTransition: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.65, green: 0.07, blue: 0.15).opacity(0.85)
        case .fractalPrism:
            Color(red: 0.50, green: 0.20, blue: 0.80).opacity(0.75)
        case .sunsetAmber:
            Color(red: 0.88, green: 0.34, blue: 0.05).opacity(0.88)
        case .dither:
            Color(white: 0.60).opacity(0.80)
        }
    }

    var bottomRightDome: Color {
        switch self {
        case .rubyAurora:
            Color(red: 0.22, green: 0.03, blue: 0.06)
        case .fractalPrism:
            Color(red: 0.85, green: 0.30, blue: 0.55)
        case .sunsetAmber:
            Color(red: 1.00, green: 0.50, blue: 0.10)
        case .dither:
            Color(white: 0.03)
        }
    }

    var swatchColors: [Color] {
        [midFieldGlow, bottomRightDome]
    }
}

// Backward-compatibility alias
typealias WeatherEditorialGradientTheme = GradientTheme
