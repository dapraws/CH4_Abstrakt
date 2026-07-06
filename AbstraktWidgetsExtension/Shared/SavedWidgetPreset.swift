import Foundation

struct SavedWidgetPreset: Identifiable, Codable, Hashable {
    let id: UUID
    let widgetID: String
    let name: String
    let size: String
    let appearanceMode: String
    let fontThemeID: String?

    init(
        id: UUID,
        widgetID: String,
        name: String,
        size: String,
        appearanceMode: String,
        fontThemeID: String? = nil
    ) {
        self.id = id
        self.widgetID = widgetID
        self.name = name
        self.size = size
        self.appearanceMode = appearanceMode
        self.fontThemeID = fontThemeID
    }
}
