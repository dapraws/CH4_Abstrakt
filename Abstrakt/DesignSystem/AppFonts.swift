import CoreText
import SwiftUI

enum AppFontRole {
    case display
    case title
    case heading1
    case heading2
    case heading3
    case body
    case subBody
    case subHeading
    case caption
    case meta
    case chip
    case tab
    case iconBadge
    case widgetDisplay
    case widgetTitle
    case widgetHeading
    case widgetBody
    case widgetCaption
    case widgetMeta
}

enum AppFontTheme: String, CaseIterable, Identifiable {
    case sfPro = "sf-pro"
    case sfProRounded = "sf-pro-rounded"
    case quicksand
    case fusionPixel = "fusion-pixel"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sfPro:
            "SF Pro"
        case .sfProRounded:
            "SF Pro Rounded"
        case .quicksand:
            "Quicksand"
        case .fusionPixel:
            "Fusion Pixel"
        }
    }

    var previewText: String {
        switch self {
        case .sfPro:
            "Crisp system clarity"
        case .sfProRounded:
            "Friendly native rhythm"
        case .quicksand:
            "Soft rounded widgets"
        case .fusionPixel:
            "Pixel-perfect energy"
        }
    }

    static func from(id: String) -> AppFontTheme {
        if id == "system-rounded" {
            return .sfProRounded
        }

        return Self(rawValue: id) ?? AppFonts.defaultTheme
    }
}

enum AppFonts {
    static let appFontStorageKey = "appFontTheme"
    static let defaultTheme: AppFontTheme = .sfProRounded

    static var selectedAppTheme: AppFontTheme {
        AppFontTheme.from(id: UserDefaults.standard.string(forKey: appFontStorageKey) ?? defaultTheme.id)
    }

    static func registerCustomFonts(in bundle: Bundle = .main) {
        CustomFontFile.allCases.forEach { fontFile in
            guard let url = fontFile.url(in: bundle) else {
                assertionFailure("Missing bundled font: \(fontFile.resourceName).ttf")
                return
            }

            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func font(_ role: AppFontRole, theme: AppFontTheme? = nil) -> Font {
        let resolvedTheme = theme ?? selectedAppTheme
        let token = FontToken(role: role, theme: resolvedTheme)

        switch resolvedTheme {
        case .sfPro:
            return .system(size: token.size, weight: token.systemWeight)
        case .sfProRounded:
            return .system(size: token.size, weight: token.systemWeight, design: .rounded)
        case .quicksand:
            return .custom(quicksandName(for: token.weight), size: token.size)
        case .fusionPixel:
            return .custom(CustomFontName.fusionPixel, size: token.size)
        }
    }

    static func lineSpacing(_ role: AppFontRole, theme: AppFontTheme? = nil) -> CGFloat {
        FontToken(role: role, theme: theme ?? selectedAppTheme).lineSpacing
    }

    static func widgetFont(_ role: AppFontRole, theme: AppFontTheme) -> Font {
        font(role, theme: theme)
    }

    static func widgetLineSpacing(_ role: AppFontRole, theme: AppFontTheme) -> CGFloat {
        lineSpacing(role, theme: theme)
    }

    private static func quicksandName(for weight: AppFontWeight) -> String {
        switch weight {
        case .light:
            CustomFontName.quicksandLight
        case .regular:
            CustomFontName.quicksandRegular
        case .medium:
            CustomFontName.quicksandMedium
        case .semibold:
            CustomFontName.quicksandSemiBold
        case .bold, .black:
            CustomFontName.quicksandBold
        }
    }
}

private enum AppFontWeight {
    case light
    case regular
    case medium
    case semibold
    case bold
    case black

    var systemWeight: Font.Weight {
        switch self {
        case .light:
            .light
        case .regular:
            .regular
        case .medium:
            .medium
        case .semibold:
            .semibold
        case .bold:
            .bold
        case .black:
            .black
        }
    }
}

private struct FontToken {
    let size: CGFloat
    let weight: AppFontWeight
    let lineSpacing: CGFloat

    init(role: AppFontRole, theme: AppFontTheme) {
        let base = BaseFontToken(role: role)
        size = base.size * theme.sizeScale(for: role)
        weight = base.weight
        lineSpacing = base.lineSpacing + theme.lineSpacingAdjustment(for: role)
    }

    var systemWeight: Font.Weight {
        weight.systemWeight
    }
}

private struct BaseFontToken {
    let size: CGFloat
    let weight: AppFontWeight
    let lineSpacing: CGFloat

    init(role: AppFontRole) {
        switch role {
        case .display:
            size = 34
            weight = .bold
            lineSpacing = -1
        case .title:
            size = 28
            weight = .bold
            lineSpacing = -1
        case .heading1:
            size = 24
            weight = .black
            lineSpacing = -1
        case .heading2:
            size = 20
            weight = .bold
            lineSpacing = 0
        case .heading3:
            size = 17
            weight = .bold
            lineSpacing = 0
        case .body:
            size = 15
            weight = .medium
            lineSpacing = 2
        case .subBody:
            size = 14
            weight = .medium
            lineSpacing = 2
        case .subHeading:
            size = 15
            weight = .bold
            lineSpacing = 2
        case .caption:
            size = 13
            weight = .semibold
            lineSpacing = 1
        case .meta:
            size = 10
            weight = .bold
            lineSpacing = 0
        case .chip:
            size = 12
            weight = .bold
            lineSpacing = 0
        case .tab:
            size = 14
            weight = .bold
            lineSpacing = 0
        case .iconBadge:
            size = 10
            weight = .black
            lineSpacing = 0
        case .widgetDisplay:
            size = 41
            weight = .bold
            lineSpacing = -2
        case .widgetTitle:
            size = 30
            weight = .bold
            lineSpacing = -1
        case .widgetHeading:
            size = 18
            weight = .bold
            lineSpacing = 0
        case .widgetBody:
            size = 13
            weight = .medium
            lineSpacing = 2
        case .widgetCaption:
            size = 10
            weight = .medium
            lineSpacing = 0
        case .widgetMeta:
            size = 9
            weight = .semibold
            lineSpacing = 0
        }
    }
}

private extension AppFontTheme {
    func sizeScale(for role: AppFontRole) -> CGFloat {
        switch self {
        case .sfPro, .sfProRounded:
            return 1
        case .quicksand:
            return 1
        case .fusionPixel:
            switch role {
            case .display, .title, .heading1, .widgetDisplay, .widgetTitle:
                return 0.74
            case .heading2, .heading3, .body, .subBody, .subHeading, .widgetHeading, .widgetBody:
                return 0.78
            case .caption, .meta, .chip, .tab, .iconBadge, .widgetCaption, .widgetMeta:
                return 0.82
            }
        }
    }

    func lineSpacingAdjustment(for role: AppFontRole) -> CGFloat {
        switch self {
        case .sfPro, .sfProRounded:
            return 0
        case .quicksand:
            return 1
        case .fusionPixel:
            switch role {
            case .display, .title, .heading1, .widgetDisplay, .widgetTitle:
                return -6
            case .heading2, .heading3, .body, .subBody, .subHeading, .widgetHeading, .widgetBody:
                return -5
            case .caption, .meta, .chip, .tab, .iconBadge, .widgetCaption, .widgetMeta:
                return -3
            }
        }
    }
}

private enum CustomFontName {
    static let quicksandLight = "Quicksand-Light"
    static let quicksandRegular = "Quicksand-Regular"
    static let quicksandMedium = "Quicksand-Medium"
    static let quicksandSemiBold = "Quicksand-SemiBold"
    static let quicksandBold = "Quicksand-Bold"
    static let fusionPixel = "Fusion-Pixel-10px-Proportional-zh_hant-Regular"
}

private enum CustomFontFile: String, CaseIterable {
    case quicksandLight = "Quicksand-Light"
    case quicksandRegular = "Quicksand-Regular"
    case quicksandMedium = "Quicksand-Medium"
    case quicksandSemiBold = "Quicksand-SemiBold"
    case quicksandBold = "Quicksand-Bold"
    case fusionPixel = "Fusion-Pixel-Regular"

    var resourceName: String {
        rawValue
    }

    func url(in bundle: Bundle) -> URL? {
        bundle.url(forResource: resourceName, withExtension: "ttf", subdirectory: "DesignSystem/Fonts")
            ?? bundle.url(forResource: resourceName, withExtension: "ttf")
    }
}
