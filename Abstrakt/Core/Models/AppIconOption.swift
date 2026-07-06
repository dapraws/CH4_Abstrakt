//
//  AppIconOption.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 06/07/26.
//

import Foundation

/// A selectable app icon shown in the icon picker.
///
/// - `alternateIconName` is the key registered under `CFBundleAlternateIcons`
///   in the app's `Info.plist`, or `nil` for the primary icon.
/// - `previewAssetName` is an image in `Assets.xcassets/AppIcons/` used as a
///   thumbnail in the picker.
/// - Alternate icon PNGs are copied as loose app resources and referenced by
///   `Info.plist`.
struct AppIconOption: Identifiable, Hashable {
    let id: String
    let displayName: String
    let alternateIconName: String?
    let previewAssetName: String

    var isPrimary: Bool { alternateIconName == nil }
}

extension AppIconOption {
    /// All options in the order shown in the picker. First entry is the
    /// primary icon (uses the existing `AppIcon` asset as its thumbnail).
    static let all: [AppIconOption] = [
        AppIconOption(id: "default", displayName: "Default", alternateIconName: nil, previewAssetName: "AbstraktDefaultPreview"),
        AppIconOption(id: "glass", displayName: "Glass", alternateIconName: "AbstraktGlass", previewAssetName: "AbstraktGlassPreview"),
        AppIconOption(id: "purple", displayName: "Purple", alternateIconName: "AbstraktPurple", previewAssetName: "AbstraktPurplePreview"),
        AppIconOption(id: "blue", displayName: "Blue", alternateIconName: "AbstraktBlue", previewAssetName: "AbstraktBluePreview"),
    ]

    static let primary = all[0]

    static func from(id: String) -> AppIconOption {
        all.first { $0.id == id } ?? primary
    }

    /// Resolves the option matching a live `UIApplication.alternateIconName`
    /// value (`nil` means the primary icon is active).
    static func from(alternateIconName: String?) -> AppIconOption {
        guard let alternateIconName else { return primary }
        return all.first { $0.alternateIconName == alternateIconName } ?? primary
    }
}
