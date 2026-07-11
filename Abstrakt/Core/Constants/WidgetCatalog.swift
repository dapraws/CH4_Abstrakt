import Foundation

nonisolated enum WidgetCatalog {
    private static let allItemOrder: [String] = [
        "calendar",
        "reminder",
        "battery",
        "steps",
        "activity",
        "events",
        "portal",
        "storage",
        "today",
        "weather",
        "daylight",
        "heart-rate"
    ]

    private static let chipOrder: [WidgetCategory] = [
        .all,
        .portal,
        .healthKit,
        .weatherKit,
        .eventKit,
        .foundation,
        .uiKit,
    ]

    static let items: [WidgetCatalogItem] = [
        WidgetCatalogItem(
            id: "calendar",
            name: "Calendar",
            size: .small,
            categories: [.eventKit, .foundation],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "reminder",
            name: "Reminder",
            size: .small,
            categories: [.eventKit],
            customizations: [.reminderItem],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "battery",
            name: "Battery",
            size: .small,
            categories: [.uiKit],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "steps",
            name: "Steps",
            size: .small,
            categories: [.healthKit],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "activity",
            name: "Activity",
            size: .small,
            categories: [.healthKit],
            customizations: [.activityMode],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "events",
            name: "Events",
            size: .small,
            categories: [.eventKit],
            customizations: [.eventMode],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "portal",
            name: "Portal",
            size: .small,
            categories: [.portal],
            customizations: [.portalApps],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "today",
            name: "Today",
            size: .medium,
            categories: [.weatherKit, .eventKit, .foundation],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "storage",
            name: "Storage",
            size: .small,
            categories: [.foundation],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "daylight",
            name: "Daylight",
            size: .small,
            categories: [.weatherKit],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "weather",
            name: "Weather",
            size: .small,
            categories: [.weatherKit],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "heart-rate",
            name: "Heart Rate",
            size: .small,
            categories: [.healthKit],
            isPro: false
        ),
    ]

    static var featuredCategories: [WidgetCategory] {
        chipOrder.filter { category in
            category == .all || items.contains { $0.categories.contains(category) }
        }
    }

    static func galleryItems(for category: WidgetCategory) -> [WidgetCatalogItem] {
        let orderedItems = allItemOrder.compactMap { item(withID: $0) }
        guard category != .all else {
            return orderedItems
        }

        return orderedItems.filter { $0.categories.contains(category) }
    }

    static func item(withID id: String) -> WidgetCatalogItem? {
        items.first { $0.id == id }
    }

    private static let galleryOrder: [WidgetCategory: [String]] = [
        .all: [
            "calendar",
            "reminder",
            "battery",
            "steps",
            "activity",
            "events",
            "portal",
            "storage",
            "today",
            "daylight",
            "weather",
            "heart-rate",
        ],
        .portal: [
            "portal",
        ],
        .healthKit: [
            "steps",
            "activity",
            "heart-rate"
        ],
        .weatherKit: [
            "today",
            "daylight",
            "weather",
        ],
        .eventKit: [
            "calendar",
            "reminder",
            "events",
            "today",
        ],
        .foundation: [
            "calendar",
            "today",
            "storage",
        ],
        .uiKit: [
            "battery",
        ],
    ]
}
