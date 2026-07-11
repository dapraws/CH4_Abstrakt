import CoreGraphics
import Foundation

struct WidgetCatalogItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let size: WidgetSize
    let categories: [WidgetCategory]
    let customizations: [WidgetCustomization]
    let isPro: Bool

    nonisolated init(
        id: String,
        name: String,
        size: WidgetSize,
        categories: [WidgetCategory],
        customizations: [WidgetCustomization] = [],
        isPro: Bool
    ) {
        self.id = id
        self.name = name
        self.size = size
        self.categories = categories
        self.customizations = customizations
        self.isPro = isPro
    }

    var displayName: String {
        name
    }

    var primaryCategory: WidgetCategory {
        categories.first ?? .all
    }

    var featuredHeight: CGFloat {
        size.previewHeight
    }
}

enum WidgetCustomization: String, CaseIterable, Codable, Hashable, Identifiable {
    case portalApps
    case activityMode
    case eventMode
    case reminderItem

    var id: String { rawValue }
}
