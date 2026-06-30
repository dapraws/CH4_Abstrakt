import SwiftUI
import WidgetKit

@main
struct AbstraktWidgetsBundle: WidgetBundle {
    init() {
        AbstraktWidgetFonts.registerCustomFonts()
    }

    var body: some Widget {
        SmallSolidWidget()
        MediumSolidWidget()
        LargeSolidWidget()
    }
}
