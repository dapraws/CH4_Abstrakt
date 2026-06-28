import Foundation

enum WidgetCategoryKind: String, Codable {
    case content
    case style
}

enum WidgetCategory: String, CaseIterable, Codable, Hashable, Identifiable {
    case all
    case classic
    case portal
    case minimalism
    case bento
    case health
    case weather
    case clock
    case calendar
    case utility
    case playful

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            "All"
        case .classic:
            "Classic"
        case .portal:
            "Portal"
        case .minimalism:
            "Minimalism"
        case .bento:
            "Bento"
        case .health:
            "Health"
        case .weather:
            "Weather"
        case .clock:
            "Clock"
        case .calendar:
            "Calendar"
        case .utility:
            "Utility"
        case .playful:
            "Playful"
        }
    }

    var systemImage: String {
        switch self {
        case .all:
            "square.grid.3x3.fill"
        case .classic:
            "star.fill"
        case .portal:
            "square.on.square"
        case .minimalism:
            "circle.lefthalf.filled"
        case .bento:
            "square.grid.2x2.fill"
        case .health:
            "heart.fill"
        case .weather:
            "cloud.sun.fill"
        case .clock:
            "clock.fill"
        case .calendar:
            "calendar"
        case .utility:
            "slider.horizontal.3"
        case .playful:
            "sparkles"
        }
    }

    var kind: WidgetCategoryKind {
        switch self {
        case .all:
            .content
        case .classic, .portal, .minimalism, .bento, .playful:
            .style
        case .health, .weather, .clock, .calendar, .utility:
            .content
        }
    }
}
