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
            "HealthKit"
        case .weatherKit:
            "WeatherKit"
        case .foundation:
            "Foundation"
        case .eventKit:
            "EventKit"
        case .uiKit:
            "UIKit"
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
