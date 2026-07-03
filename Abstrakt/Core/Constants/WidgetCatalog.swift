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
        "heart-beat-small"
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
            id: "sun-event-weather-small",
            name: "Sun Event",
            size: .small,
            categories: [.weather, .minimalism],
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
            id: "heart-beat-small",
            name: "Heart Beat",
            size: .small,
            categories: [.health, .minimalism],
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
            "battery-bars-small",
            "step-health-small",
            "portal-widget-small",
            "device-storage-small",
            "daily-dashboard-medium",
            "sun-event-weather-small",
            "classic-weather-small",
            "heart-beat-small",
            
        ],
        .classic: [
            "battery-bars-small",
            "device-storage-small",
            "classic-weather-small"
        ],
        .portal: [
            "portal-widget-small",
            "daily-dashboard-medium",
        ],
        .health: [
            "step-health-small",
            "heart-beat-small"
        ],
        .weather: [
            "portal-widget-small",
            "daily-dashboard-medium",
            "sun-event-weather-small",
            "classic-weather-small",
        ],
        .calendar: [
            "portal-widget-small",
            "daily-dashboard-medium",
        ],
        .clock: [
            "daily-dashboard-medium",
        ],
    ]
}
