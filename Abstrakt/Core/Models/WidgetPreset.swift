import Foundation

struct WidgetPreset: Identifiable, Codable, Hashable {
    let id: UUID
    let widgetID: String
    let name: String
    let size: WidgetSize
    let appearanceMode: WidgetAppearanceMode
}

extension WidgetPreset {
    static let seededLibrary: [WidgetPreset] = [
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0001") ?? UUID(),
            widgetID: "battery",
            name: "Battery",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0002") ?? UUID(),
            widgetID: "steps",
            name: "Steps",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0009") ?? UUID(),
            widgetID: "activity",
            name: "Activity",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0010") ?? UUID(),
            widgetID: "events",
            name: "Events",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0004") ?? UUID(),
            widgetID: "portal",
            name: "Portal",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0003") ?? UUID(),
            widgetID: "today",
            name: "Today",
            size: .medium,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0005") ?? UUID(),
            widgetID: "storage",
            name: "Storage",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0006") ?? UUID(),
            widgetID: "weather",
            name: "Weather",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0007") ?? UUID(),
            widgetID: "daylight",
            name: "Daylight",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0008") ?? UUID(),
            widgetID: "heart-rate",
            name: "Heart Rate",
            size: .small,
            appearanceMode: .system
        ),
    ]
}
