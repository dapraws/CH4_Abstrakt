import Foundation

enum WidgetCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case all
    case portal
    case healthKit
    case weatherKit
    case foundation
    case eventKit
    case uiKit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            "All"
        case .portal:
            "Portal"
        case .healthKit:
            "Health"
        case .weatherKit:
            "Weather"
        case .foundation:
            "Time"
        case .eventKit:
            "Calendar"
        case .uiKit:
            "Device"
        }
    }

    var systemImage: String {
        switch self {
        case .all:
            "square.grid.3x3.fill"
        case .portal:
            "square.on.square"
        case .healthKit:
            "heart.fill"
        case .weatherKit:
            "cloud.sun.fill"
        case .foundation:
            "clock.fill"
        case .eventKit:
            "calendar"
        case .uiKit:
            "iphone"
        }
    }
}

// MARK: - Localization

extension WidgetCategory {
    var localizedTitle: String {
        switch self {
        case .all:
            L("widget_category.all")
        case .portal:
            L("widget_category.portal")
        case .healthKit:
            L("widget_category.health")
        case .weatherKit:
            L("widget_category.weather")
        case .foundation:
            L("widget_category.time")
        case .eventKit:
            L("widget_category.calendar")
        case .uiKit:
            L("widget_category.device")
        }
    }
}
