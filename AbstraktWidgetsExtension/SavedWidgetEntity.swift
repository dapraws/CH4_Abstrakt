//
//  SavedWidgetEntity.swift
//  AbstraktWidgetsExtension
//
//  Created by Daffa Yuranizar Arrifi on 04/07/26.
//

import Foundation
import AppIntents

struct SavedWidgetEntity: AppEntity {
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Saved Widget")
    
    var id: String
    
    @Property(title: "Name")
    var name: String
    
    @Property(title: "Widget ID")
    var widgetID: String
    
    @Property(title: "Size")
    var sizeID: String
    
    var thumbnailData: Data?
    
    init(id: String, name: String, widgetID: String, sizeID: String, thumbnailData: Data? = nil) {
        self.id = id
        self.name = name
        self.widgetID = widgetID
        self.sizeID = sizeID
        self.thumbnailData = thumbnailData
    }
    
    init() {
        self.id = ""
        self.name = ""
        self.widgetID = ""
        self.sizeID = ""
        self.thumbnailData = nil
    }

    var displayRepresentation: DisplayRepresentation {
        if let imageData = thumbnailData {
            let displayImage = DisplayRepresentation.Image(data: imageData)
            return DisplayRepresentation(title: "\(name)", image: displayImage)
        }

        return DisplayRepresentation(title: "\(name)")
    }

    static var defaultQuery = SavedWidgetQuery()
}

struct SavedWidgetQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
        return identifiers.compactMap { id in
            presets.first { $0.id.uuidString == id }.map { entity(for: $0) }
        }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
        return presets.map { entity(for: $0) }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        WidgetSharedStore.allSavedPresets.map { entity(for: $0) }
    }
    
    private func entity(for preset: SavedWidgetPreset) -> SavedWidgetEntity {
        SavedWidgetEntity(
            id: preset.id.uuidString,
            name: preset.name,
            widgetID: preset.widgetID,
            sizeID: preset.size,
            thumbnailData: thumbnailData(for: preset)
        )
    }
    
    private func thumbnailData(for preset: SavedWidgetPreset) -> Data? {
        guard let url = WidgetSharedStore.thumbnailURL(for: preset.id.uuidString) else {
            return nil
        }
        return try? Data(contentsOf: url)
    }
}

struct SmallSavedWidgetQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().entities(for: identifiers)
        return presets.filter { $0.sizeID == "small" }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().entities(matching: string)
        return presets.filter { $0.sizeID == "small" }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().suggestedEntities()
        return presets.filter { $0.sizeID == "small" }
    }
}

struct MediumSavedWidgetQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().entities(for: identifiers)
        return presets.filter { $0.sizeID == "medium" }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().entities(matching: string)
        return presets.filter { $0.sizeID == "medium" }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().suggestedEntities()
        return presets.filter { $0.sizeID == "medium" }
    }
}

struct LargeSavedWidgetQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().entities(for: identifiers)
        return presets.filter { $0.sizeID == "large" }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().entities(matching: string)
        return presets.filter { $0.sizeID == "large" }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let presets = try await SavedWidgetQuery().suggestedEntities()
        return presets.filter { $0.sizeID == "large" }
    }
}

extension SavedWidgetEntity: CustomStringConvertible {
    var description: String {
        "SavedWidgetEntity(id: \(id), name: \(name), size: \(sizeID))"
    }
}
