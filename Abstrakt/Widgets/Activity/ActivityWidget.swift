import SwiftUI
import WidgetKit

enum ActivityMode: String, CaseIterable, Codable, Hashable, Identifiable {
    case today
    case weekly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today:
            "Today"
        case .weekly:
            "Weekly"
        }
    }

    static func from(id: String?) -> ActivityMode {
        ActivityMode(rawValue: id ?? "") ?? .today
    }
}

struct ActivitySnapshot: Codable, Hashable {
    let mode: ActivityMode
    let exerciseMinutes: Int
    let activeEnergyCalories: Int
    let sleepMinutes: Int

    var title: String {
        mode.title
    }

    var exerciseLabel: String {
        exerciseMinutes.formatted(.number)
    }

    var activeEnergyLabel: String {
        activeEnergyCalories.formatted(.number)
    }

    var sleepLabel: String {
        let hours = sleepMinutes / 60
        let minutes = sleepMinutes % 60

        if hours > 0, minutes > 0 {
            return "\(hours)H \(minutes)M"
        }

        if hours > 0 {
            return "\(hours)H"
        }

        return "\(minutes)M"
    }
}

struct ActivityWidget: View {
    let snapshot: ActivitySnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: ActivitySnapshot = .previewToday,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    var body: some View {
        ZStack {
            if clipsToWidgetShape {
                palette.background
            }

            widgetContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? 22 : 0,
                style: .continuous
            )
        )
        .containerBackground(for: .widget) {
            palette.background
        }
    }

    private var widgetContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text(snapshot.title)
                    .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                    .foregroundStyle(palette.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 10)

                Image("heart-color")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
            }

            Spacer()

            VStack(alignment: .leading, spacing: metricSpacing) {
                metricRow(value: snapshot.activeEnergyLabel, unit: "CAL")
                metricRow(value: snapshot.exerciseLabel, unit: "EXERCISE")
                metricRow(value: snapshot.sleepLabel, unit: "SLEPT")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(15)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func metricRow(value: String, unit: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(value)
                .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                .foregroundStyle(palette.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(unit)
                .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                .foregroundStyle(palette.tertiaryForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }

    private var metricSpacing: CGFloat {
        max(4, AbstraktWidgetFonts.lineSpacing(.heading, theme: fontTheme))
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

extension ActivitySnapshot {
    static let previewToday = ActivitySnapshot(
        mode: .today,
        exerciseMinutes: 42,
        activeEnergyCalories: 652,
        sleepMinutes: 432
    )

    static let previewWeekly = ActivitySnapshot(
        mode: .weekly,
        exerciseMinutes: 286,
        activeEnergyCalories: 652,
        sleepMinutes: 432
    )
}

#Preview("Activity - Today") {
    ZStack {
        Color.gray.ignoresSafeArea()
        ActivityWidget(snapshot: .previewToday)
            .frame(width: 170, height: 170)
    }
}

#Preview("Activity - Weekly") {
    ZStack {
        Color.gray.ignoresSafeArea()
        ActivityWidget(snapshot: .previewWeekly)
            .frame(width: 170, height: 170)
    }
}
