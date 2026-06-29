import SwiftUI

struct BatteryBarsWidget: View {
    let snapshot: BatterySnapshot
    private let fontTheme: AppFontTheme = .sfProRounded

    init(snapshot: BatterySnapshot = BatteryStatusProvider.currentSnapshot()) {
        self.snapshot = snapshot
    }

    var body: some View {
        ZStack {
            AppColors.widgetBackground

            VStack(spacing: 24) {
                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill")
                        .font(AppFonts.widgetFont(.caption, theme: fontTheme))
                        .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))

                    Text("\(snapshot.level)%")
                        .font(AppFonts.widgetFont(.widgetHeading, theme: fontTheme))
                        .foregroundStyle(AppColors.widgetPrimaryText)
                }

                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { index in
                        BatteryLevelBar(
                            fillFraction: snapshot.barFillFraction(at: index),
                            fillColor: Color(red: 1, green: 0.35, blue: 0.22),
                            backgroundColor: AppColors.widgetPrimaryText.opacity(0.08)
                        )
                    }
                }

                Text(snapshot.timeRemainingLabel)
                    .font(AppFonts.widgetFont(.widgetCaption, theme: fontTheme))
                    .foregroundStyle(AppColors.widgetTertiaryText)
            }
            .padding(14)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

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
        snapshot: BatterySnapshot(
            level: 76,
            estimatedMinutesRemaining: 456,
            isCharging: false
        )
    )
        .frame(width: 170, height: 170)
}
