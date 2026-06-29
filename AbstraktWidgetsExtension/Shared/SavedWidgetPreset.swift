import Foundation

struct SavedWidgetPreset: Identifiable, Codable, Hashable {
    let id: UUID
    let widgetID: String
    let name: String
    let size: String
    let appearanceMode: String
}
