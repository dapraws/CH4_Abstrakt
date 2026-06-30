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
            widgetID: "battery-bars-small",
            name: "Battery Bars | Classic",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0002") ?? UUID(),
            widgetID: "step-health-small",
            name: "Step Health | Minimalism",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0004") ?? UUID(),
            widgetID: "portal-widget-small",
            name: "Portal Widget | Apps",
            size: .small,
            appearanceMode: .system
        ),
        WidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0003") ?? UUID(),
            widgetID: "daily-dashboard-medium",
            name: "Daily Dashboard | Portal",
            size: .medium,
            appearanceMode: .system
        ),
    ]
}
