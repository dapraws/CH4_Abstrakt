import SwiftUI

enum AppFontRole {
    case largeTitle
    case title
    case titleCompact
    case body
    case bodyStrong
    case caption
    case chip
    case tab
}

enum AppFonts {
    static func font(_ role: AppFontRole) -> Font {
        switch role {
        case .largeTitle:
            .system(size: 34, weight: .bold, design: .rounded)
        case .title:
            .system(size: 28, weight: .bold, design: .rounded)
        case .titleCompact:
            .system(size: 20, weight: .bold, design: .rounded)
        case .body:
            .system(size: 15, weight: .medium, design: .rounded)
        case .bodyStrong:
            .system(size: 15, weight: .bold, design: .rounded)
        case .caption:
            .system(size: 13, weight: .semibold, design: .rounded)
        case .chip:
            .system(size: 12, weight: .bold, design: .rounded)
        case .tab:
            .system(size: 14, weight: .bold, design: .rounded)
        }
    }
}
