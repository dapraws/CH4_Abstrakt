import SwiftUI
import WidgetKit

@main
struct AbstraktWidgetsBundle: WidgetBundle {
    init() {
        WidgetFonts.registerCustomFonts()
    }

    var body: some Widget {
        SmallSolidWidget()
        MediumSolidWidget()
        LargeSolidWidget()
    }
}
