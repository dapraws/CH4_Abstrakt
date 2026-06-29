import Foundation
import CoreGraphics

enum WidgetSize: String, CaseIterable, Codable, Identifiable {
    case small
    case medium
    case large

    var id: String { rawValue }

    var title: String {
        switch self {
        case .small:
            "Small"
        case .medium:
            "Medium"
        case .large:
            "Large"
        }
    }

    var previewHeight: CGFloat {
        previewSize.height
    }

    var previewWidth: CGFloat {
        previewSize.width
    }

    var previewSize: CGSize {
        switch self {
        case .small:
            WidgetSizeTokens.defaultHomeSmall
        case .medium:
            WidgetSizeTokens.defaultHomeMedium
        case .large:
            WidgetSizeTokens.defaultHomeLarge
        }
    }
}
