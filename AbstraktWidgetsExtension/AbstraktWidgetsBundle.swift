import SwiftUI
import WidgetKit

@main
struct AbstraktWidgetsBundle: WidgetBundle {
    var body: some Widget {
        SmallSolidWidget()
        MediumSolidWidget()
        LargeSolidWidget()
        DynamicIslandActivity()
    }
}
