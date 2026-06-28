import Foundation

enum BottomBarTab: String, CaseIterable, Identifiable {
    case home
    case gallery
    case widgets
    case settings
    case library

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home:
            "Home"
        case .gallery:
            "Gallery"
        case .widgets:
            "WIP"
        case .settings:
            "Settings"
        case .library:
            "Library"
        }
    }

    var systemImage: String {
        switch self {
        case .home:
            "house.fill"
        case .gallery:
            "archivebox.fill"
        case .widgets:
            "square.grid.2x2.fill"
        case .settings:
            "gearshape.fill"
        case .library:
            "circle.fill"
        }
    }
}
