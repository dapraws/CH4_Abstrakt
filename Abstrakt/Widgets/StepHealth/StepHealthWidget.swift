import SwiftUI

struct StepHealthWidget: View {
    let snapshot: HealthSummarySnapshot
    private let fontTheme: AppFontTheme = .fusionPixel

    init(snapshot: HealthSummarySnapshot = HealthSummaryProvider.placeholder) {
        self.snapshot = snapshot
    }

    var body: some View {
        ZStack {
            AppColors.widgetBackground

            VStack(alignment: .leading) {
                stairIcon
                    .frame(width: 27, height: 18)

                Spacer()

                Text("You've walked\n\(snapshot.stepsLabel) steps,\ndistance is\n\(snapshot.distanceLabel) \(snapshot.distanceUnitName).")
                    .font(AppFonts.widgetFont(.widgetBody, theme: fontTheme))
                    .lineSpacing(AppFonts.widgetLineSpacing(.widgetBody, theme: fontTheme))
                    .foregroundStyle(AppColors.widgetSecondaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var stairIcon: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().frame(width: 7, height: 3)
            Rectangle().frame(width: 14, height: 7)
            Rectangle().frame(width: 21, height: 12)
        }
        .foregroundStyle(AppColors.widgetPrimaryText)
    }
}

#Preview("Step Health") {
    StepHealthWidget(
        snapshot: HealthSummarySnapshot(
            steps: 8_436,
            distanceKilometers: 5.72
        )
    )
        .frame(width: 170, height: 170)
}
