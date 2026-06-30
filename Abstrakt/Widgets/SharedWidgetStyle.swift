import CoreText
import SwiftUI

enum AbstraktWidgetFontRole {
    case display
    case displayCompact
    case title
    case heading
    case body
    case caption
    case meta
    case iconBadge
}

enum AbstraktWidgetFontTheme: String, CaseIterable, Identifiable {
    case sfPro = "sf-pro"
    case sfProRounded = "sf-pro-rounded"
    case quicksand
    case fusionPixel = "fusion-pixel"

    var id: String { rawValue }

    static var selectedAppTheme: AbstraktWidgetFontTheme {
        from(id: UserDefaults.standard.string(forKey: "appFontTheme") ?? sfProRounded.id)
    }

    static var sharedAppTheme: AbstraktWidgetFontTheme {
        from(
            id: UserDefaults(suiteName: "group.msaf.abstrakt")?.string(forKey: "appFontTheme")
                ?? UserDefaults.standard.string(forKey: "appFontTheme")
                ?? sfProRounded.id
        )
    }

    static func from(id: String) -> AbstraktWidgetFontTheme {
        if id == "system-rounded" {
            return .sfProRounded
        }

        return Self(rawValue: id) ?? .sfProRounded
    }
}

enum AbstraktWidgetFonts {
    static func registerCustomFonts(in bundle: Bundle = .main) {
        AbstraktWidgetFontFile.allCases.forEach { fontFile in
            guard let url = fontFile.url(in: bundle) else {
                return
            }

            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }

    static func font(_ role: AbstraktWidgetFontRole, theme: AbstraktWidgetFontTheme) -> Font {
        let token = AbstraktWidgetFontToken(role: role, theme: theme)

        switch theme {
        case .sfPro:
            return .system(size: token.size, weight: token.systemWeight)
        case .sfProRounded:
            return .system(size: token.size, weight: token.systemWeight, design: .rounded)
        case .quicksand:
            return .custom(quicksandName(for: token.weight), size: token.size)
        case .fusionPixel:
            return .custom("Fusion-Pixel-10px-Proportional-zh_hant-Regular", size: token.size)
        }
    }

    static func lineSpacing(_ role: AbstraktWidgetFontRole, theme: AbstraktWidgetFontTheme) -> CGFloat {
        AbstraktWidgetFontToken(role: role, theme: theme).lineSpacing
    }

    private static func quicksandName(for weight: AbstraktWidgetFontWeight) -> String {
        switch weight {
        case .regular:
            "Quicksand-Regular"
        case .medium:
            "Quicksand-Medium"
        case .semibold:
            "Quicksand-SemiBold"
        case .bold, .black:
            "Quicksand-Bold"
        }
    }
}

struct AbstraktWidgetPalette {
    let colorScheme: ColorScheme

    private var isDark: Bool {
        colorScheme == .dark
    }

    var background: Color {
        isDark ? Color(red: 0.02, green: 0.02, blue: 0.02) : Color.white
    }

    var foreground: Color {
        isDark ? Color(red: 0.96, green: 0.96, blue: 0.96) : Color.black
    }

    var secondaryForeground: Color {
        foreground.opacity(isDark ? 0.62 : 0.62)
    }

    var tertiaryForeground: Color {
        foreground.opacity(isDark ? 0.42 : 0.42)
    }

    var cardBackground: Color {
        isDark ? Color(red: 0.11, green: 0.11, blue: 0.12) : Color(red: 0.95, green: 0.96, blue: 0.98)
    }

    var subtleFill: Color {
        foreground.opacity(isDark ? 0.08 : 0.1)
    }

    var badgeFill: Color {
        foreground.opacity(isDark ? 0.18 : 0.12)
    }
}

private enum AbstraktWidgetFontWeight {
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

private struct AbstraktWidgetFontToken {
    let size: CGFloat
    let weight: AbstraktWidgetFontWeight
    let lineSpacing: CGFloat

    init(role: AbstraktWidgetFontRole, theme: AbstraktWidgetFontTheme) {
        let base = BaseAbstraktWidgetFontToken(role: role)
        size = base.size * theme.sizeScale(for: role)
        weight = base.weight
        lineSpacing = base.lineSpacing + theme.lineSpacingAdjustment(for: role)
    }

    var systemWeight: Font.Weight {
        weight.systemWeight
    }
}

private struct BaseAbstraktWidgetFontToken {
    let size: CGFloat
    let weight: AbstraktWidgetFontWeight
    let lineSpacing: CGFloat

    init(role: AbstraktWidgetFontRole) {
        switch role {
            case .display:
                size = 41
                weight = .bold
                lineSpacing = -2
            case .displayCompact:
                size = 32
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

private extension AbstraktWidgetFontTheme {
    func sizeScale(for role: AbstraktWidgetFontRole) -> CGFloat {
        switch self {
        case .sfPro, .sfProRounded, .quicksand:
            return 1
        case .fusionPixel:
            switch role {
                case .display, .displayCompact, .title:
                    return 0.74
            case .heading, .body:
                return 0.78
            case .caption, .meta, .iconBadge:
                return 0.82
            }
        }
    }

    func lineSpacingAdjustment(for role: AbstraktWidgetFontRole) -> CGFloat {
        switch self {
        case .sfPro, .sfProRounded:
            return 0
        case .quicksand:
            return 1
        case .fusionPixel:
            switch role {
            case .display, .displayCompact, .title:
                return -6
            case .heading, .body:
                return -5
            case .caption, .meta, .iconBadge:
                return -3
            }
        }
    }
}

private enum AbstraktWidgetFontFile: String, CaseIterable {
    case quicksandRegular = "Quicksand-Regular"
    case quicksandMedium = "Quicksand-Medium"
    case quicksandSemiBold = "Quicksand-SemiBold"
    case quicksandBold = "Quicksand-Bold"
    case fusionPixel = "Fusion-Pixel-Regular"

    func url(in bundle: Bundle) -> URL? {
        bundle.url(forResource: rawValue, withExtension: "ttf", subdirectory: "Fonts")
            ?? bundle.url(forResource: rawValue, withExtension: "ttf", subdirectory: "DesignSystem/Fonts")
            ?? bundle.url(forResource: rawValue, withExtension: "ttf")
    }
}
