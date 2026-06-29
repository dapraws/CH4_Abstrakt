import Foundation
import SwiftUI
import WidgetKit

struct SmallSolidWidgetEntry: TimelineEntry {
    let date: Date
    let selectedWidgetID: String?
    let battery: BatteryWidgetEntry
    let health: StepWidgetEntry
}

struct MediumSolidWidgetEntry: TimelineEntry {
    let date: Date
    let selectedWidgetID: String?
    let dashboard: DashboardWidgetEntry
}

struct LargeSolidWidgetEntry: TimelineEntry {
    let date: Date
    let selectedWidgetID: String?
    let battery: BatteryWidgetEntry
    let health: StepWidgetEntry
    let dashboard: DashboardWidgetEntry
}

struct BatteryWidgetEntry: TimelineEntry {
    let date: Date
    let level: Int
    let estimatedMinutesRemaining: Int?
    let isCharging: Bool
}

struct StepWidgetEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let distanceValue: Double
    let distanceUnitName: String
}

struct DashboardWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: Int
    let high: Int
    let low: Int
    let weatherSymbol: String
}

private let widgetTimelineRefreshInterval: TimeInterval = 1

struct SmallSolidWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = SmallSolidWidgetEntry
    typealias Intent = SmallSolidWidgetIntent

    func placeholder(in context: Context) -> SmallSolidWidgetEntry {
        SmallSolidWidgetEntry.current(selectedWidgetName: SolidWidgetSelection.choose)
    }

    func snapshot(for configuration: SmallSolidWidgetIntent, in context: Context) async -> SmallSolidWidgetEntry {
        SmallSolidWidgetEntry.current(selectedWidgetName: configuration.currentWidget ?? SolidWidgetSelection.choose)
    }

    func timeline(for configuration: SmallSolidWidgetIntent, in context: Context) async -> Timeline<SmallSolidWidgetEntry> {
        Timeline(
            entries: [SmallSolidWidgetEntry.current(selectedWidgetName: configuration.currentWidget ?? SolidWidgetSelection.choose)],
            policy: .after(nextWidgetRefreshDate())
        )
    }
}

struct MediumSolidWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = MediumSolidWidgetEntry
    typealias Intent = MediumSolidWidgetIntent

    func placeholder(in context: Context) -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry.current(selectedWidgetName: SolidWidgetSelection.choose)
    }

    func snapshot(for configuration: MediumSolidWidgetIntent, in context: Context) async -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry.current(selectedWidgetName: configuration.currentWidget ?? SolidWidgetSelection.choose)
    }

    func timeline(for configuration: MediumSolidWidgetIntent, in context: Context) async -> Timeline<MediumSolidWidgetEntry> {
        Timeline(
            entries: [MediumSolidWidgetEntry.current(selectedWidgetName: configuration.currentWidget ?? SolidWidgetSelection.choose)],
            policy: .after(nextWidgetRefreshDate())
        )
    }
}

struct LargeSolidWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = LargeSolidWidgetEntry
    typealias Intent = LargeSolidWidgetIntent

    func placeholder(in context: Context) -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry.current(selectedWidgetName: SolidWidgetSelection.choose)
    }

    func snapshot(for configuration: LargeSolidWidgetIntent, in context: Context) async -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry.current(selectedWidgetName: configuration.currentWidget ?? SolidWidgetSelection.choose)
    }

    func timeline(for configuration: LargeSolidWidgetIntent, in context: Context) async -> Timeline<LargeSolidWidgetEntry> {
        Timeline(
            entries: [LargeSolidWidgetEntry.current(selectedWidgetName: configuration.currentWidget ?? SolidWidgetSelection.choose)],
            policy: .after(nextWidgetRefreshDate())
        )
    }
}

private func nextWidgetRefreshDate() -> Date {
    .now.addingTimeInterval(widgetTimelineRefreshInterval)
}

struct SmallSolidWidget: Widget {
    let kind = "AbstraktSolidSmallWidget.v3"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SmallSolidWidgetIntent.self, provider: SmallSolidWidgetProvider()) { entry in
            SmallSolidWidgetView(entry: entry)
        }
        .configurationDisplayName("Solid Widget")
        .description("Small Widget")
        .supportedFamilies([.systemSmall])
        .contentMarginsDisabled()
    }
}

struct MediumSolidWidget: Widget {
    let kind = "AbstraktSolidMediumWidget.v3"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: MediumSolidWidgetIntent.self, provider: MediumSolidWidgetProvider()) { entry in
            MediumSolidWidgetView(entry: entry)
        }
        .configurationDisplayName("Solid Widget")
        .description("Medium Widget")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}

struct LargeSolidWidget: Widget {
    let kind = "AbstraktSolidLargeWidget.v3"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: LargeSolidWidgetIntent.self, provider: LargeSolidWidgetProvider()) { entry in
            LargeSolidWidgetView(entry: entry)
        }
        .configurationDisplayName("Solid Widget")
        .description("Large Widget")
        .supportedFamilies([.systemLarge])
        .contentMarginsDisabled()
    }
}

private let widgetBackground = Color(red: 0.02, green: 0.02, blue: 0.02)
private let widgetForeground = Color(red: 0.96, green: 0.96, blue: 0.96)

private extension SmallSolidWidgetEntry {
    static func current(selectedWidgetName: String) -> SmallSolidWidgetEntry {
        SmallSolidWidgetEntry(
            date: .now,
            selectedWidgetID: SolidWidgetSelection.widgetID(for: selectedWidgetName, size: "small"),
            battery: BatteryWidgetEntry(
                date: .now,
                level: WidgetSharedStore.batteryLevel,
                estimatedMinutesRemaining: WidgetSharedStore.batteryEstimatedMinutes,
                isCharging: WidgetSharedStore.batteryIsCharging
            ),
            health: StepWidgetEntry(
                date: .now,
                steps: WidgetSharedStore.healthSteps,
                distanceValue: WidgetSharedStore.healthDistanceValue,
                distanceUnitName: WidgetSharedStore.healthDistanceUnitName
            )
        )
    }
}

private extension MediumSolidWidgetEntry {
    static func current(selectedWidgetName: String) -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry(
            date: .now,
            selectedWidgetID: SolidWidgetSelection.widgetID(for: selectedWidgetName, size: "medium"),
            dashboard: DashboardWidgetEntry(
                date: .now,
                temperature: WidgetSharedStore.weatherTemperature,
                high: WidgetSharedStore.weatherHigh,
                low: WidgetSharedStore.weatherLow,
                weatherSymbol: WidgetSharedStore.weatherSymbol
            )
        )
    }
}

private extension LargeSolidWidgetEntry {
    static func current(selectedWidgetName: String) -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry(
            date: .now,
            selectedWidgetID: SolidWidgetSelection.widgetID(for: selectedWidgetName, size: "large"),
            battery: BatteryWidgetEntry(
                date: .now,
                level: WidgetSharedStore.batteryLevel,
                estimatedMinutesRemaining: WidgetSharedStore.batteryEstimatedMinutes,
                isCharging: WidgetSharedStore.batteryIsCharging
            ),
            health: StepWidgetEntry(
                date: .now,
                steps: WidgetSharedStore.healthSteps,
                distanceValue: WidgetSharedStore.healthDistanceValue,
                distanceUnitName: WidgetSharedStore.healthDistanceUnitName
            ),
            dashboard: DashboardWidgetEntry(
                date: .now,
                temperature: WidgetSharedStore.weatherTemperature,
                high: WidgetSharedStore.weatherHigh,
                low: WidgetSharedStore.weatherLow,
                weatherSymbol: WidgetSharedStore.weatherSymbol
            )
        )
    }
}

private struct SmallSolidWidgetView: View {
    let entry: SmallSolidWidgetEntry

    var body: some View {
        switch entry.selectedWidgetID {
        case "battery-bars-small":
            BatteryBarsWidgetView(entry: entry.battery)
        case "step-health-small":
            StepHealthWidgetView(entry: entry.health)
        default:
            InstructionSolidWidgetView()
        }
    }
}

private struct MediumSolidWidgetView: View {
    let entry: MediumSolidWidgetEntry

    var body: some View {
        switch entry.selectedWidgetID {
        case "daily-dashboard-medium":
            DailyDashboardWidgetView(entry: entry.dashboard)
        default:
            InstructionSolidWidgetView()
        }
    }
}

private struct LargeSolidWidgetView: View {
    let entry: LargeSolidWidgetEntry

    var body: some View {
        switch entry.selectedWidgetID {
        default:
            InstructionSolidWidgetView()
        }
    }
}

private struct InstructionSolidWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    private let fontTheme: WidgetFontTheme = .sfProRounded

    var body: some View {
        ZStack {
            widgetBackground

            VStack(alignment: .leading, spacing: rowSpacing) {
                instructionRow(number: 1, text: "Touch and hold", isActive: true)
                instructionRow(number: 2, text: "\"Edit Widget\"", isActive: false)
                instructionRow(number: 3, text: "Select a widget", isActive: true)
                instructionRow(number: 4, text: "Tap \"Done\"", isActive: false)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
            .padding(contentPadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(widgetBackground, for: .widget)
    }

    private func instructionRow(number: Int, text: String, isActive: Bool) -> some View {
        HStack(spacing: 8) {
            Text("\(number)")
                .font(WidgetFonts.font(.iconBadge, theme: fontTheme))
                .foregroundStyle(isActive ? widgetBackground : widgetForeground.opacity(0.42))
                .frame(width: numberBadgeSize, height: numberBadgeSize)
                .background(isActive ? widgetForeground : widgetForeground.opacity(0.18))
                .clipShape(Circle())

            Text(text)
                .font(WidgetFonts.font(instructionTextRole, theme: fontTheme))
                .foregroundStyle(isActive ? widgetForeground : widgetForeground.opacity(0.42))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

    private var instructionTextRole: WidgetFontRole {
        switch widgetFamily {
        case .systemSmall:
            .caption
        case .systemMedium:
            .body
        default:
            .heading
        }
    }

    private var numberBadgeSize: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            14
        case .systemMedium:
            16
        default:
            17
        }
    }

    private var rowSpacing: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            8
        case .systemMedium:
            10
        default:
            11
        }
    }

    private var contentPadding: CGFloat {
        switch widgetFamily {
        case .systemSmall:
            18
        case .systemMedium:
            20
        default:
            24
        }
    }
}

private struct BatteryBarsWidgetView: View {
    let entry: BatteryWidgetEntry
    private let fontTheme: WidgetFontTheme = .sfProRounded

    var body: some View {
        ZStack {
            widgetBackground

            VStack(spacing: 24) {
                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill")
                        .font(WidgetFonts.font(.caption, theme: fontTheme))
                        .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))

                    Text("\(entry.level)%")
                        .font(WidgetFonts.font(.heading, theme: fontTheme))
                        .foregroundStyle(widgetForeground)
                }

                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { index in
                        BatteryLevelBarView(
                            fillFraction: barFillFraction(at: index),
                            fillColor: Color(red: 1, green: 0.35, blue: 0.22),
                            backgroundColor: widgetForeground.opacity(0.08)
                        )
                    }
                }

                Text(timeRemainingLabel)
                    .font(WidgetFonts.font(.caption, theme: fontTheme))
                    .foregroundStyle(widgetForeground.opacity(0.32))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(widgetBackground, for: .widget)
    }

    private func barFillFraction(at index: Int) -> Double {
        min(max((Double(max(0, min(100, entry.level))) / 100.0 * 5.0) - Double(index), 0), 1)
    }

    private var timeRemainingLabel: String {
        if entry.isCharging {
            return "Charging"
        }

        guard let estimatedMinutesRemaining = entry.estimatedMinutesRemaining else {
            return "Estimating"
        }

        return "- \(Self.durationLabel(for: estimatedMinutesRemaining))"
    }

    private static func durationLabel(for minutes: Int) -> String {
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

private struct BatteryLevelBarView: View {
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

private struct StepHealthWidgetView: View {
    let entry: StepWidgetEntry
    private let fontTheme: WidgetFontTheme = .fusionPixel

    var body: some View {
        ZStack {
            widgetBackground

            VStack(alignment: .leading) {
                stairIcon
                    .frame(width: 27, height: 18)

                Spacer()

                Text("You've walked\n\(entry.steps.formatted(.number)) steps,\ndistance is\n\(entry.distanceValue.formatted(.number.precision(.fractionLength(2)))) \(entry.distanceUnitName).")
                    .font(WidgetFonts.font(.body, theme: fontTheme))
                    .lineSpacing(WidgetFonts.lineSpacing(.body, theme: fontTheme))
                    .foregroundStyle(widgetForeground.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(18)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(widgetBackground, for: .widget)
    }

    private var stairIcon: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().frame(width: 7, height: 3)
            Rectangle().frame(width: 14, height: 7)
            Rectangle().frame(width: 21, height: 12)
        }
        .foregroundStyle(widgetForeground)
    }
}

private struct DailyDashboardWidgetView: View {
    let entry: DashboardWidgetEntry
    private let fontTheme: WidgetFontTheme = .sfProRounded

    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 8) {
                timeCard
                    .frame(maxHeight: .infinity)
                weatherCard
            }
            .frame(width: 132)
            .frame(maxHeight: .infinity)

            calendarCard
                .frame(maxHeight: .infinity)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(Color.white, for: .widget)
    }

    private var timeCard: some View {
        RoundedRectangle(cornerRadius: 17, style: .continuous)
            .fill(Color(red: 0.95, green: 0.96, blue: 0.98))
            .overlay {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Spacer()
                        Text("\(entry.temperature)° \(entry.weatherSymbol)")
                            .font(WidgetFonts.font(.meta, theme: fontTheme))
                            .padding(.horizontal, 7)
                            .frame(height: 18)
                            .background(Color.black.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Text(entry.date.formatted(.dateTime.hour().minute()))
                        .font(WidgetFonts.font(.display, theme: fontTheme))
                        .foregroundStyle(Color.black)
                        .minimumScaleFactor(0.72)
                }
                .padding(10)
            }
    }

    private var weatherCard: some View {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(Color(red: 0.95, green: 0.96, blue: 0.98))
            .frame(height: 56)
            .overlay {
                HStack {
                    Text("\(entry.temperature)")
                        .font(WidgetFonts.font(.title, theme: fontTheme))
                    Text("°")
                        .font(WidgetFonts.font(.heading, theme: fontTheme))
                        .offset(x: -5, y: -5)
                    Spacer(minLength: 2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("▲ \(entry.high)°")
                        Text("▼ \(entry.low)°")
                    }
                    .font(WidgetFonts.font(.meta, theme: fontTheme))
                    .foregroundStyle(Color.black.opacity(0.5))
                }
                .padding(.horizontal, 10)
            }
    }

    private var calendarCard: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(red: 0.95, green: 0.96, blue: 0.98))
            .overlay {
                VStack(spacing: 9) {
                    HStack {
                        ForEach(Array(["S", "M", "T", "W", "T", "F", "S"].enumerated()), id: \.offset) { _, weekday in
                            Text(weekday)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .font(WidgetFonts.font(.caption, theme: fontTheme))
                    .foregroundStyle(Color(red: 1, green: 0.36, blue: 0.42))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 7) {
                        ForEach(calendarDays.indices, id: \.self) { index in
                            let value = calendarDays[index]
                            Text(value == 0 ? "" : "\(value)")
                                .font(WidgetFonts.font(.meta, theme: fontTheme))
                                .frame(width: 20, height: 18)
                                .background {
                                    if value == highlightedDay {
                                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                                            .fill(Color(red: 0.55, green: 0.63, blue: 1.0))
                                    }
                                }
                        }
                    }
                }
                .padding(14)
            }
    }

    private var highlightedDay: Int {
        Calendar.current.component(.day, from: entry.date)
    }

    private var calendarDays: [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: entry.date)
        let monthStart = calendar.date(from: components) ?? entry.date
        let range = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<31
        let leading = calendar.component(.weekday, from: monthStart) - 1
        return Array(repeating: 0, count: leading) + Array(range)
    }
}

private extension SmallSolidWidgetEntry {
    static func preview(selectedWidgetID: String?) -> SmallSolidWidgetEntry {
        SmallSolidWidgetEntry(
            date: .widgetPreviewDate,
            selectedWidgetID: selectedWidgetID,
            battery: BatteryWidgetEntry(
                date: .widgetPreviewDate,
                level: 76,
                estimatedMinutesRemaining: 456,
                isCharging: false
            ),
            health: StepWidgetEntry(
                date: .widgetPreviewDate,
                steps: 8_436,
                distanceValue: 5.72,
                distanceUnitName: "kilometers"
            )
        )
    }
}

private extension MediumSolidWidgetEntry {
    static func preview(selectedWidgetID: String?) -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry(
            date: .widgetPreviewDate,
            selectedWidgetID: selectedWidgetID,
            dashboard: DashboardWidgetEntry(
                date: .widgetPreviewDate,
                temperature: 25,
                high: 30,
                low: 24,
                weatherSymbol: "🌥️"
            )
        )
    }
}

private extension LargeSolidWidgetEntry {
    static func preview(selectedWidgetID: String?) -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry(
            date: .widgetPreviewDate,
            selectedWidgetID: selectedWidgetID,
            battery: BatteryWidgetEntry(
                date: .widgetPreviewDate,
                level: 76,
                estimatedMinutesRemaining: 456,
                isCharging: false
            ),
            health: StepWidgetEntry(
                date: .widgetPreviewDate,
                steps: 8_436,
                distanceValue: 5.72,
                distanceUnitName: "kilometers"
            ),
            dashboard: DashboardWidgetEntry(
                date: .widgetPreviewDate,
                temperature: 25,
                high: 30,
                low: 24,
                weatherSymbol: "🌥️"
            )
        )
    }
}

private extension Date {
    static let widgetPreviewDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 6, day: 29, hour: 9, minute: 41)
    ) ?? .now
}

#Preview("Small - Battery Bars", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "battery-bars-small")
}

#Preview("Small - Step Health", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "step-health-small")
}

#Preview("Medium - Daily Dashboard", as: .systemMedium) {
    MediumSolidWidget()
} timeline: {
    MediumSolidWidgetEntry.preview(selectedWidgetID: "daily-dashboard-medium")
}

#Preview("Large - Choose Widget", as: .systemLarge) {
    LargeSolidWidget()
} timeline: {
    LargeSolidWidgetEntry.preview(selectedWidgetID: nil)
}
