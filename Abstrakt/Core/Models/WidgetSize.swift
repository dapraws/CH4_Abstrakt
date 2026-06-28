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
        switch self {
        case .small:
            170
        case .medium:
            170
        case .large:
            376
        }
    }
}
