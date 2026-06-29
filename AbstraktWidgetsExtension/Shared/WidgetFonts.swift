import CoreText
import SwiftUI

enum WidgetFontRole {
    case display
    case title
    case heading
    case body
    case caption
    case meta
    case iconBadge
}

enum WidgetFontTheme {
    case sfPro
    case sfProRounded
    case quicksand
    case fusionPixel
}

enum WidgetFonts {
    static func registerCustomFonts(in bundle: Bundle = .main) {
        CustomWidgetFontFile.allCases.forEach { fontFile in
            guard let url = fontFile.url(in: bundle) else {
                return
            }

            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func font(_ role: WidgetFontRole, theme: WidgetFontTheme) -> Font {
        let token = WidgetFontToken(role: role, theme: theme)

        switch theme {
        case .sfPro:
            return .system(size: token.size, weight: token.systemWeight)
        case .sfProRounded:
            return .system(size: token.size, weight: token.systemWeight, design: .rounded)
        case .quicksand:
            return .custom(quicksandName(for: token.weight), size: token.size)
        case .fusionPixel:
            return .custom(CustomWidgetFontName.fusionPixel, size: token.size)
        }
    }

    static func lineSpacing(_ role: WidgetFontRole, theme: WidgetFontTheme) -> CGFloat {
        WidgetFontToken(role: role, theme: theme).lineSpacing
    }

    private static func quicksandName(for weight: WidgetFontWeight) -> String {
        switch weight {
        case .regular:
            CustomWidgetFontName.quicksandRegular
        case .medium:
            CustomWidgetFontName.quicksandMedium
        case .semibold:
            CustomWidgetFontName.quicksandSemiBold
        case .bold, .black:
            CustomWidgetFontName.quicksandBold
        }
    }
}

private enum WidgetFontWeight {
    case regular
    case medium
    case semibold
    case bold
    case black

    var systemWeight: Font.Weight {
        switch self {
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

private struct WidgetFontToken {
    let size: CGFloat
    let weight: WidgetFontWeight
    let lineSpacing: CGFloat

    init(role: WidgetFontRole, theme: WidgetFontTheme) {
        let base = BaseWidgetFontToken(role: role)
        size = base.size * theme.sizeScale(for: role)
        weight = base.weight
        lineSpacing = base.lineSpacing + theme.lineSpacingAdjustment(for: role)
    }

    var systemWeight: Font.Weight {
        weight.systemWeight
    }
}

private struct BaseWidgetFontToken {
    let size: CGFloat
    let weight: WidgetFontWeight
    let lineSpacing: CGFloat

    init(role: WidgetFontRole) {
        switch role {
        case .display:
            size = 41
            weight = .bold
            lineSpacing = -2
        case .title:
            size = 30
            weight = .bold
            lineSpacing = -1
        case .heading:
            size = 18
            weight = .bold
            lineSpacing = 0
        case .body:
            size = 13
            weight = .medium
            lineSpacing = 2
        case .caption:
            size = 10
            weight = .medium
            lineSpacing = 0
        case .meta:
            size = 9
            weight = .semibold
            lineSpacing = 0
        case .iconBadge:
            size = 7
            weight = .black
            lineSpacing = 0
        }
    }
}

private extension WidgetFontTheme {
    func sizeScale(for role: WidgetFontRole) -> CGFloat {
        switch self {
        case .sfPro, .sfProRounded, .quicksand:
            return 1
        case .fusionPixel:
            switch role {
            case .display, .title:
                return 0.74
            case .heading, .body:
                return 0.78
            case .caption, .meta, .iconBadge:
                return 0.82
            }
        }
    }

    func lineSpacingAdjustment(for role: WidgetFontRole) -> CGFloat {
        switch self {
        case .sfPro, .sfProRounded:
            return 0
        case .quicksand:
            return 1
        case .fusionPixel:
            switch role {
            case .display, .title:
                return -6
            case .heading, .body:
                return -5
            case .caption, .meta, .iconBadge:
                return -3
            }
        }
    }
}

private enum CustomWidgetFontName {
    static let quicksandRegular = "Quicksand-Regular"
    static let quicksandMedium = "Quicksand-Medium"
    static let quicksandSemiBold = "Quicksand-SemiBold"
    static let quicksandBold = "Quicksand-Bold"
    static let fusionPixel = "Fusion-Pixel-10px-Proportional-zh_hant-Regular"
}

private enum CustomWidgetFontFile: String, CaseIterable {
    case quicksandRegular = "Quicksand-Regular"
    case quicksandMedium = "Quicksand-Medium"
    case quicksandSemiBold = "Quicksand-SemiBold"
    case quicksandBold = "Quicksand-Bold"
    case fusionPixel = "Fusion-Pixel-Regular"

    func url(in bundle: Bundle) -> URL? {
        bundle.url(forResource: rawValue, withExtension: "ttf", subdirectory: "Fonts")
            ?? bundle.url(forResource: rawValue, withExtension: "ttf")
    }
}
