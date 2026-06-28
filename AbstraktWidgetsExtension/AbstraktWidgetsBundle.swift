import SwiftUI
import WidgetKit

@main
struct AbstraktWidgetsBundle: WidgetBundle {
    var body: some Widget {
        BatteryBarsHomeWidget()
        StepHealthHomeWidget()
        DailyDashboardHomeWidget()
    }
}
