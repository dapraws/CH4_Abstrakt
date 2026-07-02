import Foundation

nonisolated enum WidgetCatalog {
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
    ]

    static func galleryItems(for category: WidgetCategory) -> [WidgetCatalogItem] {
        let ids = galleryOrder[category] ?? galleryOrder[.all] ?? items.map(\.id)
        return ids.compactMap { item(withID: $0) }
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
            
        ],
        .classic: [
            "battery-bars-small",
            "device-storage-small",
        ],
        .portal: [
            "portal-widget-small",
            "daily-dashboard-medium",
        ],
        .health: [
            "step-health-small",
        ],
        .weather: [
            "portal-widget-small",
            "daily-dashboard-medium",
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
