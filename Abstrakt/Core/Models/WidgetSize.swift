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

    var previewAspectRatio: CGFloat {
        previewWidth / previewHeight
    }

    func previewSize(fittingWidth availableWidth: CGFloat, maximumScale: CGFloat = 1) -> CGSize {
        let maximumWidth = previewWidth * max(maximumScale, 0)
        let width = min(max(availableWidth, 0), maximumWidth)
        return CGSize(width: width, height: width / previewAspectRatio)
    }

    func previewHeight(fittingWidth availableWidth: CGFloat) -> CGFloat {
        previewSize(fittingWidth: availableWidth).height
    }
}
