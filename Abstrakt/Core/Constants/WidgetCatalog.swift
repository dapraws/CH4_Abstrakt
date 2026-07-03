import Foundation

nonisolated enum WidgetCatalog {
    private static let allItemOrder: [String] = [
        "battery-bars-small",
        "step-health-small",
        "portal-widget-small",
        "device-storage-small",
        "daily-dashboard-medium",
        "classic-weather-small",
        "sun-event-weather-small",
    ]

    private static let chipOrder: [WidgetCategory] = [
        .all,
        .classic,
        .minimalism,
        .portal,
        .health,
        .weather,
        .calendar,
        .clock,
        .utility,
    ]

    static let items: [WidgetCatalogItem] = [
        WidgetCatalogItem(
            id: "battery-bars-small",
            name: "Battery Bars",
            size: .small,
            categories: [.utility, .classic],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "step-health-small",
            name: "Step Health",
            size: .small,
            categories: [.health, .minimalism],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "portal-widget-small",
            name: "Portal Widget",
            size: .small,
            categories: [.portal, .weather, .calendar, .utility],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "daily-dashboard-medium",
            name: "Daily Dashboard",
            size: .medium,
            categories: [.portal, .weather, .calendar, .clock],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "device-storage-small",
            name: "Device Storage",
            size: .small,
            categories: [.utility, .classic],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "classic-weather-small",
            name: "Classic Weather",
            size: .small,
            categories: [.weather, .classic],
            isPro: false
        ),
        WidgetCatalogItem(
            id: "sun-event-weather-small",
            name: "Sun Event Weather",
            size: .small,
            categories: [.weather, .minimalism],
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
}
