//
//  LiveActivityWidget.swift
//  Abstrakt
//

import SwiftUI

// MARK: - Smart Pill Models

enum LiveActivityWidgetColor: String, Codable, Hashable {
    case red, blue, green, yellow, purple, cyan, indigo, pink, white, orange, clear
    
    var color: Color {
        switch self {
        case .red: return .red
        case .blue: return .blue
        case .green: return .green
        case .yellow: return .yellow
        case .purple: return .purple
        case .cyan: return .cyan
        case .indigo: return .indigo
        case .pink: return .pink
        case .white: return .white
        case .orange: return .orange
        case .clear: return .clear
        }
    }
}

enum LiveActivityWidgetLayout: String, Codable, Hashable {
    case iconTopTextBottom
    case textTopTextBottom
    case temperatureHighLow
    case caloriesStyle
    case largeTextSplit
    case calendarSplit
    case storageStyle
    case circularProgress
    case largeIcon
    case ringGauge
    case temperatureGauge
    case windCompass
    case analogClock
    case stopwatchDial
    case secondsValue
    case dateFraction
    case calendarStack
    case todayInfo
    case weatherInfo
    case calendarInfo
}

enum LiveActivitySurface: String, Codable, Hashable {
    case smartPills
    case expanded
    case liveActivity
}

struct LiveActivityWidget: Codable, Hashable, Identifiable {
    var id: String
    var name: String
    var iconName: String
    var widgetColor: LiveActivityWidgetColor
    
    var layout: LiveActivityWidgetLayout
    var primaryText: String? = nil
    var secondaryText: String? = nil
    var progress: Double? = nil
    var isSystemImage: Bool = true
    var metadata: [String: String] = [:]
    var supportedSurfaces: Set<LiveActivitySurface> = []
    
    var color: Color { widgetColor.color }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case iconName
        case widgetColor
        case layout
        case primaryText
        case secondaryText
        case progress
        case isSystemImage
        case metadata
        case supportedSurfaces
    }

    init(
        id: String? = nil,
        name: String,
        iconName: String,
        widgetColor: LiveActivityWidgetColor,
        layout: LiveActivityWidgetLayout,
        primaryText: String? = nil,
        secondaryText: String? = nil,
        progress: Double? = nil,
        isSystemImage: Bool = true,
        metadata: [String: String] = [:],
        supportedSurfaces: Set<LiveActivitySurface> = []
    ) {
        self.id = id ?? [
            name,
            layout.rawValue,
            primaryText ?? "",
            secondaryText ?? "",
            iconName
        ]
            .joined(separator: "-")
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
        self.name = name
        self.iconName = iconName
        self.widgetColor = widgetColor
        self.layout = layout
        self.primaryText = primaryText
        self.secondaryText = secondaryText
        self.progress = progress
        self.isSystemImage = isSystemImage
        self.metadata = metadata
        self.supportedSurfaces = supportedSurfaces
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        iconName = try container.decode(String.self, forKey: .iconName)
        widgetColor = try container.decode(LiveActivityWidgetColor.self, forKey: .widgetColor)
        layout = try container.decode(LiveActivityWidgetLayout.self, forKey: .layout)
        primaryText = try container.decodeIfPresent(String.self, forKey: .primaryText)
        secondaryText = try container.decodeIfPresent(String.self, forKey: .secondaryText)
        progress = try container.decodeIfPresent(Double.self, forKey: .progress)
        isSystemImage = try container.decodeIfPresent(Bool.self, forKey: .isSystemImage) ?? true
        metadata = try container.decodeIfPresent([String: String].self, forKey: .metadata) ?? [:]
        supportedSurfaces = try container.decodeIfPresent(Set<LiveActivitySurface>.self, forKey: .supportedSurfaces) ?? []
    }
}

extension LiveActivityWidget {
    func isAvailable(on surface: LiveActivitySurface) -> Bool {
        supportedSurfaces.isEmpty || supportedSurfaces.contains(surface)
    }

    func available(on surface: LiveActivitySurface) -> LiveActivityWidget {
        var widget = self
        widget.supportedSurfaces = [surface]
        return widget
    }
}

extension LiveActivityWidgetLayout {
    var usesFullActivityPreview: Bool {
        switch self {
        case .todayInfo, .weatherInfo, .calendarInfo:
            true
        default:
            false
        }
    }

    func activityPreviewHeight(isLiveActivity: Bool) -> CGFloat {
        switch (self, isLiveActivity) {
        case (.todayInfo, true):
            LiveActivityWidgetMetrics.liveActivityTodayInfoSurfaceHeight
        case (.weatherInfo, true):
            LiveActivityWidgetMetrics.liveActivityWeatherInfoSurfaceHeight
        case (.calendarInfo, true):
            LiveActivityWidgetMetrics.liveActivityCalendarInfoSurfaceHeight
        case (.todayInfo, false):
            LiveActivityWidgetMetrics.expandedTodayInfoSurfaceHeight
        case (.weatherInfo, false):
            LiveActivityWidgetMetrics.expandedWeatherInfoSurfaceHeight
        case (.calendarInfo, false):
            LiveActivityWidgetMetrics.expandedCalendarInfoSurfaceHeight
        default:
            isLiveActivity
                ? LiveActivityWidgetMetrics.lockScreenIslandHeight
                : LiveActivityWidgetMetrics.expandedIslandHeight
        }
    }
}
