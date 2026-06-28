import Foundation

struct WidgetPreset: Identifiable, Codable, Hashable {
    let id: UUID
    let widgetID: String
    let name: String
    let size: WidgetSize
    let appearanceMode: WidgetAppearanceMode
}
