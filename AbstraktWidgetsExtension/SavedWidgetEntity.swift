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

private struct DefaultCatalogItem {
    let id: String
    let name: String
    let size: String
}

private let defaultSmallCatalog: [DefaultCatalogItem] = [
    DefaultCatalogItem(id: "battery", name: "Battery", size: "small"),
    DefaultCatalogItem(id: "steps", name: "Steps", size: "small"),
    DefaultCatalogItem(id: "calendar", name: "Calendar", size: "small"),
    DefaultCatalogItem(id: "reminder", name: "Reminder", size: "small"),
    DefaultCatalogItem(id: "sleep", name: "Sleep", size: "small"),
    DefaultCatalogItem(id: "activity", name: "Activity", size: "small"),
    DefaultCatalogItem(id: "events", name: "Events", size: "small"),
    DefaultCatalogItem(id: "portal", name: "Portal", size: "small"),
    DefaultCatalogItem(id: "storage", name: "Storage", size: "small"),
    DefaultCatalogItem(id: "weather", name: "Weather", size: "small"),
    DefaultCatalogItem(id: "daylight", name: "Daylight", size: "small"),
    DefaultCatalogItem(id: "heart-rate", name: "Heart Rate", size: "small"),
    DefaultCatalogItem(id: "clock", name: "Clock", size: "small"),
    DefaultCatalogItem(id: "gradient", name: "Gradient", size: "small"),
]

private let defaultMediumCatalog: [DefaultCatalogItem] = [
    DefaultCatalogItem(id: "today", name: "Today", size: "medium"),
    DefaultCatalogItem(id: "gradient-medium", name: "Gradient", size: "medium"),
    DefaultCatalogItem(id: "gradient", name: "Gradient", size: "medium"),
]

private let defaultLargeCatalog: [DefaultCatalogItem] = []

private let allDefaultCatalog: [DefaultCatalogItem] = defaultSmallCatalog + defaultMediumCatalog + defaultLargeCatalog

private func matchPreset(for id: String, in presets: [SavedWidgetPreset]) -> SavedWidgetPreset? {
    for preset in presets {
        if preset.id.uuidString.caseInsensitiveCompare(id) == .orderedSame { return preset }
        if preset.widgetID.caseInsensitiveCompare(id) == .orderedSame { return preset }
        if preset.name.caseInsensitiveCompare(id) == .orderedSame { return preset }
    }
    return nil
}

private func matchCatalog(for id: String, in catalog: [DefaultCatalogItem]) -> DefaultCatalogItem? {
    for item in catalog {
        if item.id.caseInsensitiveCompare(id) == .orderedSame { return item }
        if item.name.caseInsensitiveCompare(id) == .orderedSame { return item }
    }
    if id.caseInsensitiveCompare("weather-editorial") == .orderedSame {
        return catalog.first { $0.id == "gradient" }
    }
    if id.caseInsensitiveCompare("weather-editorial-medium") == .orderedSame {
        return catalog.first { $0.id == "gradient-medium" }
    }
    return nil
}

struct SavedWidgetQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
        return identifiers.compactMap { id in
            if let preset = matchPreset(for: id, in: presets) {
                return entity(for: preset)
            }
            if let item = matchCatalog(for: id, in: allDefaultCatalog) {
                return SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: item.size
                )
            }
            return SavedWidgetEntity(
                id: id,
                name: id.capitalized,
                widgetID: id,
                sizeID: "small"
            )
        }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
        if !presets.isEmpty {
            return presets.map { entity(for: $0) }
        }
        return allDefaultCatalog
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { item in
                SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: item.size
                )
            }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
        if !presets.isEmpty {
            return presets.map { entity(for: $0) }
        }
        return allDefaultCatalog.map { item in
            SavedWidgetEntity(
                id: item.id,
                name: item.name,
                widgetID: item.id,
                sizeID: item.size
            )
        }
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
        let presets = WidgetSharedStore.allSavedPresets
        return identifiers.compactMap { id in
            if let preset = matchPreset(for: id, in: presets) {
                return entity(for: preset)
            }
            if let item = matchCatalog(for: id, in: defaultSmallCatalog) {
                return SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: "small"
                )
            }
            return SavedWidgetEntity(
                id: id,
                name: id.capitalized,
                widgetID: id,
                sizeID: "small"
            )
        }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.savedPresets(size: "small")
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
        if !presets.isEmpty {
            return presets.map { entity(for: $0) }
        }
        return defaultSmallCatalog
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { item in
                SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: "small"
                )
            }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let small = WidgetSharedStore.savedPresets(size: "small")
        if !small.isEmpty {
            return small.map { entity(for: $0) }
        }
        let all = WidgetSharedStore.allSavedPresets
        if !all.isEmpty {
            return all.map { entity(for: $0) }
        }
        return defaultSmallCatalog.map { item in
            SavedWidgetEntity(
                id: item.id,
                name: item.name,
                widgetID: item.id,
                sizeID: "small"
            )
        }
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

struct MediumSavedWidgetQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
        return identifiers.compactMap { id in
            if let preset = matchPreset(for: id, in: presets) {
                return entity(for: preset)
            }
            if let item = matchCatalog(for: id, in: defaultMediumCatalog) {
                return SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: "medium"
                )
            }
            return SavedWidgetEntity(
                id: id,
                name: id.capitalized,
                widgetID: id,
                sizeID: "medium"
            )
        }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.savedPresets(size: "medium")
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
        if !presets.isEmpty {
            return presets.map { entity(for: $0) }
        }
        return defaultMediumCatalog
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { item in
                SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: "medium"
                )
            }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let medium = WidgetSharedStore.savedPresets(size: "medium")
        if !medium.isEmpty {
            return medium.map { entity(for: $0) }
        }
        let all = WidgetSharedStore.allSavedPresets
        if !all.isEmpty {
            return all.map { entity(for: $0) }
        }
        return defaultMediumCatalog.map { item in
            SavedWidgetEntity(
                id: item.id,
                name: item.name,
                widgetID: item.id,
                sizeID: "medium"
            )
        }
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

struct LargeSavedWidgetQuery: EntityStringQuery {
    func entities(for identifiers: [String]) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.allSavedPresets
        return identifiers.compactMap { id in
            if let preset = matchPreset(for: id, in: presets) {
                return entity(for: preset)
            }
            if let item = matchCatalog(for: id, in: defaultLargeCatalog) {
                return SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: "large"
                )
            }
            return SavedWidgetEntity(
                id: id,
                name: id.capitalized,
                widgetID: id,
                sizeID: "large"
            )
        }
    }
    
    func entities(matching string: String) async throws -> [SavedWidgetEntity] {
        let presets = WidgetSharedStore.savedPresets(size: "large")
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
        if !presets.isEmpty {
            return presets.map { entity(for: $0) }
        }
        return defaultLargeCatalog
            .filter { $0.name.localizedCaseInsensitiveContains(string) }
            .map { item in
                SavedWidgetEntity(
                    id: item.id,
                    name: item.name,
                    widgetID: item.id,
                    sizeID: "large"
                )
            }
    }
    
    func suggestedEntities() async throws -> [SavedWidgetEntity] {
        let large = WidgetSharedStore.savedPresets(size: "large")
        if !large.isEmpty {
            return large.map { entity(for: $0) }
        }
        let all = WidgetSharedStore.allSavedPresets
        if !all.isEmpty {
            return all.map { entity(for: $0) }
        }
        return defaultLargeCatalog.map { item in
            SavedWidgetEntity(
                id: item.id,
                name: item.name,
                widgetID: item.id,
                sizeID: "large"
            )
        }
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

extension SavedWidgetEntity: CustomStringConvertible {
    var description: String {
        "SavedWidgetEntity(id: \(id), name: \(name), size: \(sizeID))"
    }
}
