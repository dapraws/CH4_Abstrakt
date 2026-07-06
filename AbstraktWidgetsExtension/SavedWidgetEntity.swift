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
    
    init(id: String, name: String, widgetID: String, sizeID: String) {
        self.id = id
        self.name = name
        self.widgetID = widgetID
        self.sizeID = sizeID
    }
    
    init() {
        self.id = ""
        self.name = ""
        self.widgetID = ""
        self.sizeID = ""
    }
    
    var displayRepresentation: DisplayRepresentation {
        if let imageURL = WidgetSharedStore.thumbnailURL(for: id),
           FileManager.default.fileExists(atPath: imageURL.path) {
            let displayImage = DisplayRepresentation.Image(url: imageURL)
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
            if let preset = presets.first(where: { $0.id.uuidString == id }) {
                return SavedWidgetEntity(
                    id: preset.id.uuidString,
                    name: preset.name,
                    widgetID: preset.widgetID,
                    sizeID: preset.size
                )
            }
            return nil
        }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
        return presets
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map {
                SavedWidgetEntity(
                    id: $0.id.uuidString,
                    name: $0.name,
                    widgetID: $0.widgetID,
                    sizeID: $0.size
                )
            }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
        return presets.map {
            SavedWidgetEntity(
                id: $0.id.uuidString,
                name: $0.name,
                widgetID: $0.widgetID,
                sizeID: $0.size
            )
        }
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
