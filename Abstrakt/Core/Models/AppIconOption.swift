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
/// - `previewAssetName` is an image in `Assets.xcassets/AppIcons/` used only as
///   a thumbnail in the picker. Preview thumbnails live in the asset catalog;
///   the real alternate icons are loose PNGs referenced by the plist.
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
        AppIconOption(id: "default", displayName: "Default", alternateIconName: nil, previewAssetName: "AppIconPreviewDefault"),
        AppIconOption(id: "noir", displayName: "Noir", alternateIconName: "AbstraktNoir", previewAssetName: "AppIconPreviewNoir"),
        AppIconOption(id: "frost", displayName: "Frost", alternateIconName: "AbstraktFrost", previewAssetName: "AppIconPreviewFrost"),
        AppIconOption(id: "aurora", displayName: "Aurora", alternateIconName: "AbstraktAurora", previewAssetName: "AppIconPreviewAurora"),
        AppIconOption(id: "sunset", displayName: "Sunset", alternateIconName: "AbstraktSunset", previewAssetName: "AppIconPreviewSunset"),
        AppIconOption(id: "ocean", displayName: "Ocean", alternateIconName: "AbstraktOcean", previewAssetName: "AppIconPreviewOcean"),
        AppIconOption(id: "bloom", displayName: "Bloom", alternateIconName: "AbstraktBloom", previewAssetName: "AppIconPreviewBloom"),
        AppIconOption(id: "mono", displayName: "Mono", alternateIconName: "AbstraktMono", previewAssetName: "AppIconPreviewMono"),
        AppIconOption(id: "pixel", displayName: "Pixel", alternateIconName: "AbstraktPixel", previewAssetName: "AppIconPreviewPixel"),
        AppIconOption(id: "neon", displayName: "Neon", alternateIconName: "AbstraktNeon", previewAssetName: "AppIconPreviewNeon"),
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
