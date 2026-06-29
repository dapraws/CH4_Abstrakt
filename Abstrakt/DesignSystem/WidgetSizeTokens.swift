import CoreGraphics
import Foundation

struct WidgetDeviceDimensions: Identifiable, Hashable {
    let screenSize: CGSize
    let homeSmall: CGSize
    let homeMedium: CGSize
    let homeLarge: CGSize
    let lockCircular: CGSize?
    let lockRectangular: CGSize?
    let lockInline: CGSize?

    var id: String {
        "\(Int(screenSize.width))x\(Int(screenSize.height))"
    }
}

enum WidgetSizeTokens {
    static let defaultHomeSmall = CGSize(width: 170, height: 170)
    static let defaultHomeMedium = CGSize(width: 364, height: 170)
    static let defaultHomeLarge = CGSize(width: 364, height: 382)

    static let iPhoneDimensions: [WidgetDeviceDimensions] = [
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 430, height: 932),
            homeSmall: CGSize(width: 170, height: 170),
            homeMedium: CGSize(width: 364, height: 170),
            homeLarge: CGSize(width: 364, height: 382),
            lockCircular: CGSize(width: 76, height: 76),
            lockRectangular: CGSize(width: 172, height: 76),
            lockInline: CGSize(width: 257, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 428, height: 926),
            homeSmall: CGSize(width: 170, height: 170),
            homeMedium: CGSize(width: 364, height: 170),
            homeLarge: CGSize(width: 364, height: 382),
            lockCircular: CGSize(width: 76, height: 76),
            lockRectangular: CGSize(width: 172, height: 76),
            lockInline: CGSize(width: 257, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 414, height: 896),
            homeSmall: CGSize(width: 169, height: 169),
            homeMedium: CGSize(width: 360, height: 169),
            homeLarge: CGSize(width: 360, height: 379),
            lockCircular: CGSize(width: 76, height: 76),
            lockRectangular: CGSize(width: 160, height: 72),
            lockInline: CGSize(width: 248, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 414, height: 736),
            homeSmall: CGSize(width: 159, height: 159),
            homeMedium: CGSize(width: 348, height: 157),
            homeLarge: CGSize(width: 348, height: 357),
            lockCircular: CGSize(width: 76, height: 76),
            lockRectangular: CGSize(width: 170, height: 76),
            lockInline: CGSize(width: 248, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 393, height: 852),
            homeSmall: CGSize(width: 158, height: 158),
            homeMedium: CGSize(width: 338, height: 158),
            homeLarge: CGSize(width: 338, height: 354),
            lockCircular: CGSize(width: 72, height: 72),
            lockRectangular: CGSize(width: 160, height: 72),
            lockInline: CGSize(width: 234, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 390, height: 844),
            homeSmall: CGSize(width: 158, height: 158),
            homeMedium: CGSize(width: 338, height: 158),
            homeLarge: CGSize(width: 338, height: 354),
            lockCircular: CGSize(width: 72, height: 72),
            lockRectangular: CGSize(width: 160, height: 72),
            lockInline: CGSize(width: 234, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 375, height: 812),
            homeSmall: CGSize(width: 155, height: 155),
            homeMedium: CGSize(width: 329, height: 155),
            homeLarge: CGSize(width: 329, height: 345),
            lockCircular: CGSize(width: 72, height: 72),
            lockRectangular: CGSize(width: 157, height: 72),
            lockInline: CGSize(width: 225, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 375, height: 667),
            homeSmall: CGSize(width: 148, height: 148),
            homeMedium: CGSize(width: 321, height: 148),
            homeLarge: CGSize(width: 321, height: 324),
            lockCircular: CGSize(width: 68, height: 68),
            lockRectangular: CGSize(width: 153, height: 68),
            lockInline: CGSize(width: 225, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 360, height: 780),
            homeSmall: CGSize(width: 155, height: 155),
            homeMedium: CGSize(width: 329, height: 155),
            homeLarge: CGSize(width: 329, height: 345),
            lockCircular: CGSize(width: 72, height: 72),
            lockRectangular: CGSize(width: 157, height: 72),
            lockInline: CGSize(width: 225, height: 26)
        ),
        WidgetDeviceDimensions(
            screenSize: CGSize(width: 320, height: 568),
            homeSmall: CGSize(width: 141, height: 141),
            homeMedium: CGSize(width: 292, height: 141),
            homeLarge: CGSize(width: 292, height: 311),
            lockCircular: nil,
            lockRectangular: nil,
            lockInline: nil
        ),
    ]
}
