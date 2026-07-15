//
//  LiveActivityTypography.swift
//  Abstrakt
//

import SwiftUI

enum IslandFontRole {
    case headline
    case title
    case body
    case label
    case badge
    case number
}

struct LiveActivityTypography {
    /// Font for icons when displayed alone
    static func iconOnly(scale: CGFloat = 1) -> Font {
        .system(size: 28 * scale, weight: .medium)
    }
    
    /// Font for single words or short labels (e.g., "WED")
    static func singleWord(scale: CGFloat = 1) -> Font {
        .system(size: 13 * scale, weight: .bold, design: .rounded)
    }
    
    /// Font for numeric values or dynamic data (e.g., steps: "2,561", calories: "173")
    /// Uses monospaced digits to prevent layout shifting.
    static func numericValue(scale: CGFloat = 1) -> Font {
        .system(size: 15 * scale, weight: .bold, design: .rounded).monospacedDigit()
    }
    
    /// Font for splits, secondary details or small headings (e.g., high/low temp, circular progress label)
    static func detailLabel(scale: CGFloat = 1) -> Font {
        .system(size: 11 * scale, weight: .semibold, design: .rounded)
    }
    
    /// Font for micro elements or subtext
    static func microSubtext(scale: CGFloat = 1) -> Font {
        .system(size: 9 * scale, weight: .medium, design: .rounded)
    }

    static func islandFont(_ role: IslandFontRole, scale: CGFloat = 1) -> Font {
        let themeID = AbstraktWidgetFontTheme.sharedAppTheme.id
        let token = IslandFontToken(role: role, themeID: themeID, scale: scale)

        switch token.family {
        case .sfPro:
            return .system(size: token.size, weight: token.weight)
        case .sfProRounded:
            return .system(size: token.size, weight: token.weight, design: .rounded)
        case .quicksand:
            return .custom(token.quicksandName, size: token.size)
        case .fusionPixel:
            return .custom("Fusion-Pixel-10px-Proportional-zh_hant-Regular", size: token.size)
        }
    }

}

enum LiveActivityWidgetMetrics {
    static let islandWidth: CGFloat = 291
    static let lockScreenActivityWidth: CGFloat = 291
    static let expandedIslandCornerRadius: CGFloat = 20
    static let lockScreenActivityCornerRadius: CGFloat = 24
    static let expandedPreviewCornerRadius: CGFloat = 38
    static let activityPreviewCornerRadius: CGFloat = expandedPreviewCornerRadius
    static let islandCornerRadius: CGFloat = expandedIslandCornerRadius
    static let expandedIslandHeight: CGFloat = 112
    static let lockScreenIslandHeight: CGFloat = 96
    static let lockScreenEmptyStateHeight: CGFloat = 118
    static let expandedSurfaceHeight: CGFloat = 96
    static let expandedTodayInfoSurfaceHeight: CGFloat = 102
    static let expandedWeatherInfoSurfaceHeight: CGFloat = 108
    static let expandedCalendarInfoSurfaceHeight: CGFloat = 96
    static let liveActivityTodayInfoSurfaceHeight: CGFloat = 110
    static let liveActivityWeatherInfoSurfaceHeight: CGFloat = 110
    static let liveActivityCalendarInfoSurfaceHeight: CGFloat = 96
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

private enum IslandFontFamily {
    case sfPro
    case sfProRounded
    case quicksand
    case fusionPixel
}

private struct IslandFontToken {
    let size: CGFloat
    let weight: Font.Weight
    let family: IslandFontFamily

    init(role: IslandFontRole, themeID: String, scale: CGFloat) {
        switch role {
        case .headline:
            size = Self.scaledSize(22, themeID: themeID) * scale
            weight = .black
        case .title:
            size = Self.scaledSize(18, themeID: themeID) * scale
            weight = .black
        case .body:
            size = Self.scaledSize(15, themeID: themeID) * scale
            weight = .bold
        case .label:
            size = Self.scaledSize(12, themeID: themeID) * scale
            weight = .bold
        case .badge:
            size = Self.scaledSize(10, themeID: themeID) * scale
            weight = .black
        case .number:
            size = Self.scaledSize(18, themeID: themeID) * scale
            weight = .black
        }

        family = Self.family(for: themeID)
    }

    var quicksandName: String {
        switch weight {
        case .black, .bold, .heavy:
            "Quicksand-Bold"
        case .semibold:
            "Quicksand-SemiBold"
        case .medium:
            "Quicksand-Medium"
        default:
            "Quicksand-Regular"
        }
    }

    private static func family(for themeID: String) -> IslandFontFamily {
        switch themeID {
        case "sf-pro":
            .sfPro
        case "sf-pro-rounded", "system-rounded":
            .sfProRounded
        case "fusion-pixel":
            .fusionPixel
        default:
            .quicksand
        }
    }

    private static func scaledSize(_ size: CGFloat, themeID: String) -> CGFloat {
        switch family(for: themeID) {
        case .sfPro, .sfProRounded:
            size * 0.92
        case .quicksand:
            size
        case .fusionPixel:
            size * 0.78
        }
    }
}
