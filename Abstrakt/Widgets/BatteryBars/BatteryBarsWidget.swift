import SwiftUI

// MARK: - Render Snapshot

struct BatteryBarsRenderSnapshot: Codable, Hashable {
    let level: Int
    let estimatedMinutesRemaining: Int?
    let isCharging: Bool

    var normalizedLevel: Double {
        Double(max(0, min(100, level))) / 100.0
    }

    func barFillFraction(at index: Int) -> Double {
        min(max((normalizedLevel * 5.0) - Double(index), 0), 1)
    }

    var timeRemainingLabel: String {
        if isCharging {
            return "Charging"
        }

        guard let estimatedMinutesRemaining else {
            return "Estimating"
        }

        return Self.durationLabel(for: estimatedMinutesRemaining)
    }

    static func durationLabel(for minutes: Int) -> String {
        let clampedMinutes = max(0, minutes)
        let hours = clampedMinutes / 60
        let remainingMinutes = clampedMinutes % 60

        switch (hours, remainingMinutes) {
        case (0, 0):
            return "< 1 min"
        case (0, _):
            return "\(remainingMinutes)m"
        case (_, 0):
            return "\(hours)h"
        default:
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

#if !WIDGET_EXTENSION
extension BatteryBarsRenderSnapshot {
    init(snapshot: BatterySnapshot) {
        self.init(
            level: snapshot.level,
            estimatedMinutesRemaining: snapshot.estimatedMinutesRemaining,
            isCharging: snapshot.isCharging
        )
    }
}
#endif

// MARK: - Widget

struct BatteryBarsWidget: View {
    let snapshot: BatteryBarsRenderSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: BatteryBarsRenderSnapshot,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    #if !WIDGET_EXTENSION
    init(
        snapshot: BatterySnapshot = BatteryStatusProvider.currentSnapshot(),
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.init(
            snapshot: BatteryBarsRenderSnapshot(snapshot: snapshot),
            fontTheme: fontTheme,
            clipsToWidgetShape: clipsToWidgetShape
        )
    }
    #endif

    // MARK: Body

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

    // MARK: Content

    private var widgetContent: some View {
        VStack(spacing: 24) {
            HStack(spacing: 5) {
                Image(systemName: "bolt.fill")
                    .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                    .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))

                Text("\(snapshot.level)%")
                    .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                    .foregroundStyle(palette.foreground)
            }

            HStack(spacing: 6) {
                ForEach(0..<5, id: \.self) { index in
                    BatteryLevelBar(
                        fillFraction: snapshot.barFillFraction(at: index),
                        fillColor: Color(red: 1, green: 0.35, blue: 0.22),
                        backgroundColor: palette.subtleFill
                    )
                }
            }

            Text(snapshot.timeRemainingLabel)
                .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(palette.tertiaryForeground)
        }
        .padding(14)
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

// MARK: - Level Bar

private struct BatteryLevelBar: View {
    let fillFraction: Double
    let fillColor: Color
    let backgroundColor: Color

    private let barSize = CGSize(width: 21, height: 44)

    var body: some View {
        RoundedRectangle(cornerRadius: 4, style: .continuous)
            .fill(backgroundColor)
            .frame(width: barSize.width, height: barSize.height)
            .overlay(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(fillColor)
                    .frame(width: barSize.width, height: barSize.height * min(max(fillFraction, 0), 1))
            }
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }
}

#Preview("Battery Bars") {
    BatteryBarsWidget(
        snapshot: BatteryBarsRenderSnapshot(
            level: 76,
            estimatedMinutesRemaining: 456,
            isCharging: false
        )
    )
    .frame(width: 170, height: 170)
}
