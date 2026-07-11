import SwiftUI
import WidgetKit

struct SleepSnapshot: Codable, Hashable {
    let date: Date
    let accessAuthorized: Bool
    let targetBedtimeMinutes: Int?
    let recommendedSleepMinutes: Int
    let efficiencyPercent: Int

    init(
        date: Date = .now,
        accessAuthorized: Bool = true,
        targetBedtimeMinutes: Int? = nil,
        recommendedSleepMinutes: Int = 0,
        efficiencyPercent: Int = 0
    ) {
        self.date = date
        self.accessAuthorized = accessAuthorized
        self.targetBedtimeMinutes = targetBedtimeMinutes
        self.recommendedSleepMinutes = max(0, recommendedSleepMinutes)
        self.efficiencyPercent = min(max(0, efficiencyPercent), 100)
    }

    var hasSleepData: Bool {
        targetBedtimeMinutes != nil && recommendedSleepMinutes > 0
    }

    var durationLabel: String {
        let hours = recommendedSleepMinutes / 60
        let minutes = recommendedSleepMinutes % 60

        if hours > 0, minutes > 0 {
            return "\(hours)H \(minutes)M"
        }

        if hours > 0 {
            return "\(hours)H"
        }

        return "\(minutes)M"
    }

    var efficiencyLabel: String {
        "\(efficiencyPercent)%"
    }

    var bedtimeDisplay: (time: String, meridiem: String) {
        guard let targetBedtimeMinutes else {
            return ("--:--", "--")
        }

        let calendar = Calendar.autoupdatingCurrent
        let startOfDay = calendar.startOfDay(for: date)
        let bedtimeDate = calendar.date(
            byAdding: .minute,
            value: targetBedtimeMinutes,
            to: startOfDay
        ) ?? date

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "h:mm a"
        let parts = formatter.string(from: bedtimeDate).split(separator: " ", maxSplits: 1).map(String.init)
        if parts.count == 2 {
            return (parts[0], parts[1])
        }

        return (parts.first ?? "--:--", "PM")
    }
}

extension SleepSnapshot {
    static let placeholder = SleepSnapshot(
        date: .now,
        accessAuthorized: true,
        targetBedtimeMinutes: 23 * 60 + 46,
        recommendedSleepMinutes: 7 * 60 + 42,
        efficiencyPercent: 64
    )

    static let permissionNeeded = SleepSnapshot(
        date: .now,
        accessAuthorized: false
    )

    static let empty = SleepSnapshot(
        date: .now,
        accessAuthorized: true
    )
}

struct SleepWidget: View {
    private static let widgetCornerRadius: CGFloat = 22
    private static let accentOrange = Color(red: 1, green: 0.35, blue: 0.22)
    private static let pillCornerRadius: CGFloat = 6

    let snapshot: SleepSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: SleepSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    var body: some View {
        ZStack {
            palette.background
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? Self.widgetCornerRadius : 0,
                style: .continuous
            )
        )
        .containerBackground(for: .widget) {
            palette.background
        }
    }

    @ViewBuilder
    private var content: some View {
        if !snapshot.accessAuthorized {
            emptyState(
                title: "Sleep",
                subtitle: "Allow Health access"
            )
        } else if !snapshot.hasSleepData {
            emptyState(
                title: "Sleep",
                subtitle: "No sleep data yet"
            )
        } else {
            widgetContent
        }
    }

    private var widgetContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top) {
                    Text(verbatim: "Sleep")
                        .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                        .foregroundStyle(palette.foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: 8)

                    Image("sleep-color")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 4) {
                    Text(verbatim: "Target Bedtime")
                        .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                        .foregroundStyle(palette.secondaryForeground)

                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(verbatim: snapshot.bedtimeDisplay.time)
                            .font(AbstraktWidgetFonts.font(.displayCompact, theme: fontTheme))
                            .foregroundStyle(palette.foreground)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        Text(verbatim: snapshot.bedtimeDisplay.meridiem)
                            .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                            .foregroundStyle(palette.tertiaryForeground)
                            .padding(.bottom, 2)
                    }
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 17)

            Spacer(minLength: 0)

            HStack(spacing: 8) {
                metadataPill(
                    icon: "moon.stars.fill",
                    iconColor: Self.activeTint,
                    text: snapshot.durationLabel,
                    isLeadingPill: true
                )
                .frame(maxWidth: .infinity)

                metadataPill(
                    icon: "chart.bar.fill",
                    iconColor: Self.accentOrange,
                    text: snapshot.efficiencyLabel,
                    isLeadingPill: false
                )
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func metadataPill(
        icon: String,
        iconColor: Color,
        text: String,
        isLeadingPill: Bool
    ) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(iconColor)

            Text(verbatim: text)
                .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                .foregroundStyle(palette.secondaryForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 7)
        .frame(height: 32)
        .background(palette.cardBackground)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: Self.pillCornerRadius,
                bottomLeadingRadius: isLeadingPill ? 14 : Self.pillCornerRadius,
                bottomTrailingRadius: isLeadingPill ? Self.pillCornerRadius : 14,
                topTrailingRadius: Self.pillCornerRadius,
                style: .continuous
            )
        )
    }

    private func emptyState(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(verbatim: title)
                    .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                    .foregroundStyle(palette.foreground)

                Spacer(minLength: 0)

                Image(systemName: "bed.double.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Self.accentOrange)
            }

            Spacer(minLength: 0)

            Text(verbatim: subtitle)
                .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                .foregroundStyle(palette.secondaryForeground)
                .lineLimit(2)
                .minimumScaleFactor(0.76)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }

    private static var activeTint: Color {
        Color(red: 0.47, green: 0.74, blue: 1.0)
    }
}

#Preview("Sleep") {
    SleepWidget()
        .frame(width: 170, height: 170)
}
