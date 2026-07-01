import Foundation
import SwiftUI
import WidgetKit

// MARK: - Timeline Entries

struct SmallSolidWidgetEntry: TimelineEntry {
    let date: Date
    let selectedWidgetID: String?
    let battery: BatteryWidgetEntry
    let health: StepWidgetEntry
    let portal: PortalSmallWidgetEntry
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

struct PortalSmallWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: Int
    let placeName: String
}

private let widgetTimelineRefreshInterval: TimeInterval = 1

// MARK: - Timeline Providers

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

// MARK: - Widget Configurations

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

// MARK: - Current Entry Factories

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
            ),
            portal: PortalSmallWidgetEntry(
                date: .now,
                temperature: WidgetSharedStore.portalWeatherTemperatureCelsius,
                placeName: WidgetSharedStore.portalWeatherPlaceName
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
                temperature: WidgetSharedStore.weatherTemperatureCelsius,
                high: WidgetSharedStore.weatherHighCelsius,
                low: WidgetSharedStore.weatherLowCelsius,
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
                temperature: WidgetSharedStore.weatherTemperatureCelsius,
                high: WidgetSharedStore.weatherHighCelsius,
                low: WidgetSharedStore.weatherLowCelsius,
                weatherSymbol: WidgetSharedStore.weatherSymbol
            )
        )
    }
}

// MARK: - Render Snapshot Mapping

private extension BatteryWidgetEntry {
    var renderSnapshot: BatteryBarsRenderSnapshot {
        BatteryBarsRenderSnapshot(
            level: level,
            estimatedMinutesRemaining: estimatedMinutesRemaining,
            isCharging: isCharging
        )
    }
}

private extension StepWidgetEntry {
    var renderSnapshot: StepHealthRenderSnapshot {
        StepHealthRenderSnapshot(
            steps: steps,
            distanceValue: distanceValue,
            distanceUnitName: distanceUnitName
        )
    }
}

private extension DashboardWidgetEntry {
    var renderSnapshot: DailyDashboardSnapshot {
        DailyDashboardSnapshot(
            date: date,
            temperature: temperature,
            high: high,
            low: low,
            weatherSymbol: weatherSymbol
        )
    }
}

private extension PortalSmallWidgetEntry {
    var renderSnapshot: PortalWidgetSnapshot {
        PortalWidgetSnapshot(
            date: date,
            temperature: temperature,
            placeName: placeName
        )
    }
}

// MARK: - Widget Views

private struct SmallSolidWidgetView: View {
    let entry: SmallSolidWidgetEntry

    var body: some View {
        switch entry.selectedWidgetID {
        case "battery-bars-small":
            BatteryBarsWidget(
                snapshot: entry.battery.renderSnapshot,
                fontTheme: WidgetSharedStore.appFontTheme,
                clipsToWidgetShape: false
            )
        case "step-health-small":
            StepHealthWidget(
                snapshot: entry.health.renderSnapshot,
                fontTheme: WidgetSharedStore.appFontTheme,
                clipsToWidgetShape: false
            )
        case "portal-widget-small":
            PortalWidget(
                snapshot: entry.portal.renderSnapshot,
                fontTheme: WidgetSharedStore.appFontTheme,
                selectedApps: WidgetSharedStore.portalSelectedApps,
                iconClipStyle: WidgetSharedStore.portalIconClipStyle,
                usesInteractiveButtons: true,
                clipsToWidgetShape: false
            )
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
            DailyDashboardWidget(
                snapshot: entry.dashboard.renderSnapshot,
                fontTheme: WidgetSharedStore.appFontTheme,
                clipsToWidgetShape: false
            )
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

// MARK: - Instruction Placeholder

private struct InstructionSolidWidgetView: View {
    @Environment(\.widgetFamily) private var widgetFamily
    @Environment(\.colorScheme) private var colorScheme

    private var fontTheme: AbstraktWidgetFontTheme {
        WidgetSharedStore.appFontTheme
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }

    var body: some View {
        ZStack {
            palette.background

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
        .containerBackground(palette.background, for: .widget)
    }

    private func instructionRow(number: Int, text: String, isActive: Bool) -> some View {
        HStack(spacing: 8) {
            Text("\(number)")
                .font(AbstraktWidgetFonts.font(.iconBadge, theme: fontTheme))
                .foregroundStyle(isActive ? palette.background : palette.foreground.opacity(0.42))
                .frame(width: numberBadgeSize, height: numberBadgeSize)
                .background(isActive ? palette.foreground : palette.foreground.opacity(0.18))
                .clipShape(Circle())

            Text(text)
                .font(AbstraktWidgetFonts.font(instructionTextRole, theme: fontTheme))
                .foregroundStyle(isActive ? palette.foreground : palette.foreground.opacity(0.42))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

    private var instructionTextRole: AbstraktWidgetFontRole {
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

// MARK: - Previews

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
            ),
            portal: PortalSmallWidgetEntry(
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 26, hour: 9, minute: 41)) ?? .widgetPreviewDate,
                temperature: 16,
                placeName: "Denpasar"
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

#Preview("Small - Portal Widget", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "portal-widget-small")
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
