import SwiftUI

enum AppColors {
    static let appBackground = dynamicColor(light: 0xF0F2FC, dark: 0x17171D)
    static let topFade = dynamicColor(light: 0xF0F2FC, dark: 0x17171D)
    static let card = dynamicColor(light: 0xF7F8FD, dark: 0x1D1D24)
    static let cardSoft = dynamicColor(light: 0xECEEF7, dark: 0x22222B)
    static let chip = dynamicColor(light: 0xFCFCFC, dark: 0x070707)
    static let chipSelected = dynamicColor(light: 0x141414, dark: 0xF4F4F4)
    static let chipBorder = dynamicColor(light: 0x141414, dark: 0xF4F4F4).opacity(0.07)
    static let chipBorderSelected = dynamicColor(light: 0x141414, dark: 0xF4F4F4).opacity(0.12)
    static let chipText = dynamicColor(light: 0x141414, dark: 0xF4F4F4)
    static let chipTextSelected = dynamicColor(light: 0xF0F2FC, dark: 0x17171D)
    static let tabBar = Color.black
    static let tabBarBorder = Color(red: 22.0 / 255.0, green: 22.0 / 255.0, blue: 22.0 / 255.0)
    static let tabBarIcon = Color.white.opacity(0.42)
    static let tabBarIconSelected = Color.white
    static let separator = Color.white.opacity(0.12)
    static let primaryText = dynamicColor(light: 0x141414, dark: 0xF4F4F4)
    static let secondaryText = dynamicColor(light: 0x141414, dark: 0xF4F4F4).opacity(0.62)
    static let tertiaryText = dynamicColor(light: 0x141414, dark: 0xF4F4F4).opacity(0.42)
    static let accentBlue = Color(red: 0.29, green: 0.63, blue: 1.0)
    static let accentGreen = Color(red: 0.32, green: 0.89, blue: 0.48)
    static let accentPurple = Color(red: 0.55, green: 0.30, blue: 1.0)
    static let accentPink = Color(red: 0.97, green: 0.45, blue: 0.63)
    static let widgetBackground = dynamicColor(light: 0xFDFDFD, dark: 0x060606)
    static let widgetPrimaryText = dynamicColor(light: 0x0A0A0A, dark: 0xF4F4F4)
    static let widgetSecondaryText = dynamicColor(light: 0x0A0A0A, dark: 0xF4F4F4).opacity(0.62)
    static let widgetTertiaryText = dynamicColor(light: 0x0A0A0A, dark: 0xF4F4F4).opacity(0.42)
    static let widgetStroke = dynamicColor(light: 0x0A0A0A, dark: 0xF4F4F4).opacity(0.08)

    private static func dynamicColor(light: UInt32, dark: UInt32) -> Color {
        Color(
            uiColor: UIColor { traits in
                let hex = traits.userInterfaceStyle == .dark ? dark : light
                return UIColor(hex: hex)
            }
        )
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255
        let green = CGFloat((hex >> 8) & 0xFF) / 255
        let blue = CGFloat(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: 1)
    }
}
