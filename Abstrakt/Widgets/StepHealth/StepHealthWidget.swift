import SwiftUI

struct StepHealthRenderSnapshot: Codable, Hashable {
    let stepsLabel: String
    let distanceLabel: String
    let distanceUnitName: String

    init(steps: Int, distanceValue: Double, distanceUnitName: String) {
        stepsLabel = steps.formatted(.number)
        distanceLabel = distanceValue.formatted(.number.precision(.fractionLength(2)))
        self.distanceUnitName = distanceUnitName
    }

    init(stepsLabel: String, distanceLabel: String, distanceUnitName: String) {
        self.stepsLabel = stepsLabel
        self.distanceLabel = distanceLabel
        self.distanceUnitName = distanceUnitName
    }
}

#if !WIDGET_EXTENSION
extension StepHealthRenderSnapshot {
    init(snapshot: HealthSummarySnapshot) {
        self.init(
            stepsLabel: snapshot.stepsLabel,
            distanceLabel: snapshot.distanceLabel,
            distanceUnitName: snapshot.distanceUnitName
        )
    }
}
#endif

struct StepHealthWidget: View {
    let snapshot: StepHealthRenderSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: StepHealthRenderSnapshot,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    #if !WIDGET_EXTENSION
    init(
        snapshot: HealthSummarySnapshot = HealthSummaryProvider.placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.init(
            snapshot: StepHealthRenderSnapshot(snapshot: snapshot),
            fontTheme: fontTheme,
            clipsToWidgetShape: clipsToWidgetShape
        )
    }
    #endif

    var body: some View {
        ZStack {
            palette.background
            widgetContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? 22 : 0,
                style: .continuous
            )
        )
    }

    private var widgetContent: some View {
        VStack(alignment: .leading) {
            stairIcon
                .frame(width: 27, height: 18)

            Spacer()

            VStack(alignment: .leading, spacing: textLineSpacing) {
                Text("You've walked")
                    .foregroundStyle(palette.foreground.opacity(0.4))
                Text("\(snapshot.stepsLabel) steps,")
                    .foregroundStyle(palette.secondaryForeground)
                Text("distance is")
                    .foregroundStyle(palette.foreground.opacity(0.4))
                Text("\(snapshot.distanceLabel) \(snapshot.distanceUnitName).")
                    .foregroundStyle(palette.secondaryForeground)
            }
            .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
            .multilineTextAlignment(.leading)
            .minimumScaleFactor(0.78)
            .lineLimit(1)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(18)
    }

    private var stairIcon: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().frame(width: 7, height: 3)
            Rectangle().frame(width: 14, height: 7)
            Rectangle().frame(width: 21, height: 12)
        }
        .foregroundStyle(palette.foreground)
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }

    private var textLineSpacing: CGFloat {
        max(1, AbstraktWidgetFonts.lineSpacing(.body, theme: fontTheme) - 1)
    }
}

#Preview("Step Health") {
    StepHealthWidget(
        snapshot: StepHealthRenderSnapshot(
            steps: 8_436,
            distanceValue: 5.72,
            distanceUnitName: "kilometers"
        )
    )
    .frame(width: 170, height: 170)
}
