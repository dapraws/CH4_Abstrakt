import CoreGraphics
import Foundation

struct WidgetCatalogItem: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let size: WidgetSize
    let categories: [WidgetCategory]
    let isPro: Bool

    var displayName: String {
        name
    }

    var primaryCategory: WidgetCategory {
        categories.first(where: { $0.kind == .style }) ?? categories.first ?? .all
    }

    var featuredHeight: CGFloat {
        size.previewHeight
    }
}
