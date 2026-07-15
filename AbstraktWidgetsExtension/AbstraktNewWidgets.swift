import Foundation
import SwiftUI
import WidgetKit

// MARK: - Timeline Entries

struct SmallSolidWidgetEntry: TimelineEntry {
    let date: Date
    let selectedPreset: SavedWidgetPreset?
    let calendar: CalendarMonthSnapshot
    let reminders: ReminderSnapshot
    let sleep: SleepSnapshot
    let battery: BatteryWidgetEntry
    let health: StepWidgetEntry
    let activity: ActivitySnapshot
    let event: EventsSnapshot
    let portal: PortalEntry
    let storage: StorageWidgetEntry
    let weather: WeatherSnapshot
    let daylight: DaylightSnapshot
    let heartRate: HeartRateWidgetEntry
}

struct MediumSolidWidgetEntry: TimelineEntry {
    let date: Date
    let selectedPreset: SavedWidgetPreset?
    let today: TodayWidgetEntry
}

struct LargeSolidWidgetEntry: TimelineEntry {
    let date: Date
    let selectedPreset: SavedWidgetPreset?
    let battery: BatteryWidgetEntry
    let health: StepWidgetEntry
    let today: TodayWidgetEntry
    let storage: StorageWidgetEntry
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

struct TodayWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: Int
    let high: Int
    let low: Int
    let weatherSymbol: String
    let conditionLabel: String
}

struct PortalEntry: TimelineEntry {
    let date: Date
    let temperature: Int
    let placeName: String
}

struct StorageWidgetEntry: TimelineEntry {
    let date: Date
    let totalBytes: Int64
    let availableBytes: Int64
}

struct HeartRateWidgetEntry: TimelineEntry {
    let date: Date
    let bpm: Int
    let timestamp: Date
}

private let widgetTimelineEntryInterval: TimeInterval = 60
private let widgetTimelineEntryCount = 5

// MARK: - Timeline Providers

struct SmallSolidWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = SmallSolidWidgetEntry
    typealias Intent = SmallSolidWidgetIntent

    func placeholder(in context: Context) -> SmallSolidWidgetEntry {
        SmallSolidWidgetEntry.current(selectedWidget: nil)
    }

    func snapshot(for configuration: SmallSolidWidgetIntent, in context: Context) async -> SmallSolidWidgetEntry {
        SmallSolidWidgetEntry.current(selectedWidget: configuration.preset)
    }

    func timeline(for configuration: SmallSolidWidgetIntent, in context: Context) async -> Timeline<SmallSolidWidgetEntry> {
        Timeline(entries: widgetTimelineEntries { date in
            SmallSolidWidgetEntry.current(selectedWidget: configuration.preset, date: date)
        }, policy: .atEnd)
    }
}

struct MediumSolidWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = MediumSolidWidgetEntry
    typealias Intent = MediumSolidWidgetIntent

    func placeholder(in context: Context) -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry.current(selectedWidget: nil)
    }

    func snapshot(for configuration: MediumSolidWidgetIntent, in context: Context) async -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry.current(selectedWidget: configuration.preset)
    }

    func timeline(for configuration: MediumSolidWidgetIntent, in context: Context) async -> Timeline<MediumSolidWidgetEntry> {
        Timeline(entries: widgetTimelineEntries { date in
            MediumSolidWidgetEntry.current(selectedWidget: configuration.preset, date: date)
        }, policy: .atEnd)
    }
}

struct LargeSolidWidgetProvider: AppIntentTimelineProvider {
    typealias Entry = LargeSolidWidgetEntry
    typealias Intent = LargeSolidWidgetIntent

    func placeholder(in context: Context) -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry.current(selectedWidget: nil)
    }

    func snapshot(for configuration: LargeSolidWidgetIntent, in context: Context) async -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry.current(selectedWidget: configuration.preset)
    }

    func timeline(for configuration: LargeSolidWidgetIntent, in context: Context) async -> Timeline<LargeSolidWidgetEntry> {
        Timeline(entries: widgetTimelineEntries { date in
            LargeSolidWidgetEntry.current(selectedWidget: configuration.preset, date: date)
        }, policy: .atEnd)
    }
}

private func widgetTimelineEntries<Entry: TimelineEntry>(
    makeEntry: (Date) -> Entry
) -> [Entry] {
    let now = Date()
    return (0..<widgetTimelineEntryCount).map { offset in
        makeEntry(now.addingTimeInterval(TimeInterval(offset) * widgetTimelineEntryInterval))
    }
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
    static func current(selectedWidget: SavedWidgetEntity?, date: Date = .now) -> SmallSolidWidgetEntry {
        SmallSolidWidgetEntry(
            date: date,
            selectedPreset: resolvedPreset(from: selectedWidget, size: "small"),
            calendar: CalendarMonthSnapshot(date: date),
            reminders: WidgetSharedStore.reminders,
            sleep: WidgetSharedStore.sleep,
            battery: BatteryWidgetEntry(
                date: date,
                level: WidgetSharedStore.batteryLevel,
                estimatedMinutesRemaining: WidgetSharedStore.batteryEstimatedMinutes,
                isCharging: WidgetSharedStore.batteryIsCharging
            ),
            health: StepWidgetEntry(
                date: date,
                steps: WidgetSharedStore.healthSteps,
                distanceValue: WidgetSharedStore.healthDistanceValue,
                distanceUnitName: WidgetSharedStore.healthDistanceUnitName
            ),
            activity: WidgetSharedStore.activity,
            event: WidgetSharedStore.eventSnapshot,
            portal: PortalEntry(
                date: date,
                temperature: WidgetSharedStore.portalWeatherTemperatureCelsius,
                placeName: WidgetSharedStore.portalWeatherPlaceName
            ),
            storage: StorageWidgetEntry(
                date: date,
                totalBytes: WidgetSharedStore.storageTotalBytes,
                availableBytes: WidgetSharedStore.storageAvailableBytes
            ),
            weather: WidgetSharedStore.weather,
            daylight: WidgetSharedStore.daylight,
            heartRate: HeartRateWidgetEntry(
                date: date,
                bpm: WidgetSharedStore.heartRateBPM,
                timestamp: WidgetSharedStore.heartRateTimestamp
            )
            
        )
    }

    /// Resolves which widget ID should render. On the simulator, if the
    /// AppIntent system picker fails to deliver the entity (a known
    /// Simulator-only bug), fall back to the preset the host app marked as
    /// the active render target via Library → "Render on Home Screen".
    private static func resolvedPreset(from preset: SavedWidgetEntity?, size: String) -> SavedWidgetPreset? {
        #if targetEnvironment(simulator)
        if let preset, let id = UUID(uuidString: preset.id),
           let saved = WidgetSharedStore.savedPreset(id: id, size: size) {
            return saved
        }
        if let uuid = WidgetSharedStore.simulatorActivePresetID(forSize: size),
           let saved = WidgetSharedStore.savedPreset(id: uuid, size: size) {
            return saved
        }
        return nil
        #else
        guard let preset, let id = UUID(uuidString: preset.id) else {
            return nil
        }
        return WidgetSharedStore.savedPreset(id: id, size: size)
        #endif
    }
}

private extension MediumSolidWidgetEntry {
    static func current(selectedWidget: SavedWidgetEntity?, date: Date = .now) -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry(
            date: date,
            selectedPreset: resolvedPreset(from: selectedWidget, size: "medium"),
            today: TodayWidgetEntry(
                date: date,
                temperature: WidgetSharedStore.weatherTemperatureCelsius,
                high: WidgetSharedStore.weatherHighCelsius,
                low: WidgetSharedStore.weatherLowCelsius,
                weatherSymbol: WidgetSharedStore.weatherSymbol,
                conditionLabel: WidgetSharedStore.weatherConditionLabel
            )
        )
    }

    /// See `SmallSolidWidgetEntry.resolvedWidgetID(from:size:)`.
    private static func resolvedPreset(from preset: SavedWidgetEntity?, size: String) -> SavedWidgetPreset? {
        #if targetEnvironment(simulator)
        if let preset, let id = UUID(uuidString: preset.id),
           let saved = WidgetSharedStore.savedPreset(id: id, size: size) {
            return saved
        }
        if let uuid = WidgetSharedStore.simulatorActivePresetID(forSize: size),
           let saved = WidgetSharedStore.savedPreset(id: uuid, size: size) {
            return saved
        }
        return nil
        #else
        guard let preset, let id = UUID(uuidString: preset.id) else {
            return nil
        }
        return WidgetSharedStore.savedPreset(id: id, size: size)
        #endif
    }
}

private extension LargeSolidWidgetEntry {
    static func current(selectedWidget: SavedWidgetEntity?, date: Date = .now) -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry(
            date: date,
            selectedPreset: resolvedPreset(from: selectedWidget, size: "large"),
            battery: BatteryWidgetEntry(
                date: date,
                level: WidgetSharedStore.batteryLevel,
                estimatedMinutesRemaining: WidgetSharedStore.batteryEstimatedMinutes,
                isCharging: WidgetSharedStore.batteryIsCharging
            ),
            health: StepWidgetEntry(
                date: date,
                steps: WidgetSharedStore.healthSteps,
                distanceValue: WidgetSharedStore.healthDistanceValue,
                distanceUnitName: WidgetSharedStore.healthDistanceUnitName
            ),
            today: TodayWidgetEntry(
                date: date,
                temperature: WidgetSharedStore.weatherTemperatureCelsius,
                high: WidgetSharedStore.weatherHighCelsius,
                low: WidgetSharedStore.weatherLowCelsius,
                weatherSymbol: WidgetSharedStore.weatherSymbol,
                conditionLabel: WidgetSharedStore.weatherConditionLabel
            ),
            storage: StorageWidgetEntry(
                date: date,
                totalBytes: WidgetSharedStore.storageTotalBytes,
                availableBytes: WidgetSharedStore.storageAvailableBytes
            )
        )
    }

    /// See `SmallSolidWidgetEntry.resolvedWidgetID(from:size:)`. Helpers are
    /// duplicated per entry type because each entry extension is private.
    private static func resolvedPreset(from preset: SavedWidgetEntity?, size: String) -> SavedWidgetPreset? {
        #if targetEnvironment(simulator)
        if let preset, let id = UUID(uuidString: preset.id),
           let saved = WidgetSharedStore.savedPreset(id: id, size: size) {
            return saved
        }
        if let uuid = WidgetSharedStore.simulatorActivePresetID(forSize: size),
           let saved = WidgetSharedStore.savedPreset(id: uuid, size: size) {
            return saved
        }
        return nil
        #else
        guard let preset, let id = UUID(uuidString: preset.id) else {
            return nil
        }
        return WidgetSharedStore.savedPreset(id: id, size: size)
        #endif
    }
}

// MARK: - Render Snapshot Mapping

private extension BatteryWidgetEntry {
    var renderSnapshot: BatterySnapshotViewData {
        BatterySnapshotViewData(
            level: level,
            estimatedMinutesRemaining: estimatedMinutesRemaining,
            isCharging: isCharging
        )
    }
}

private extension StepWidgetEntry {
    var renderSnapshot: StepsSnapshot {
        StepsSnapshot(
            steps: steps,
            distanceValue: distanceValue,
            distanceUnitName: distanceUnitName
        )
    }
}

private extension TodayWidgetEntry {
    var renderSnapshot: TodaySnapshot {
        TodaySnapshot(
            date: date,
            temperature: temperature,
            high: high,
            low: low,
            weatherSymbol: weatherSymbol,
            conditionLabel: conditionLabel
        )
    }
}

private extension PortalEntry {
    var renderSnapshot: PortalSnapshot {
        PortalSnapshot(
            date: date,
            temperature: temperature,
            placeName: placeName
        )
    }
}

private extension StorageWidgetEntry {
    var renderSnapshot: StorageUsageSnapshot {
        StorageUsageSnapshot(
            totalBytes: totalBytes,
            availableBytes: availableBytes
        )
    }
}

private extension HeartRateWidgetEntry {
    var renderSnapshot: HeartRateRenderSnapshot {
        HeartRateRenderSnapshot(
            bpm: bpm,
            timestamp: timestamp
        )
    }
}

private extension SmallSolidWidgetEntry {
    var fontTheme: AbstraktWidgetFontTheme {
        selectedPreset?.fontTheme ?? WidgetSharedStore.appFontTheme
    }
}

private extension MediumSolidWidgetEntry {
    var fontTheme: AbstraktWidgetFontTheme {
        selectedPreset?.fontTheme ?? WidgetSharedStore.appFontTheme
    }
}

private extension LargeSolidWidgetEntry {
    var fontTheme: AbstraktWidgetFontTheme {
        selectedPreset?.fontTheme ?? WidgetSharedStore.appFontTheme
    }
}

private extension SavedWidgetPreset {
    var fontTheme: AbstraktWidgetFontTheme? {
        fontThemeID.map(AbstraktWidgetFontTheme.from)
    }

    var colorSchemeOverride: ColorScheme? {
        switch appearanceMode {
        case "light":
            .light
        case "dark":
            .dark
        default:
            nil
        }
    }
}

private extension Optional where Wrapped == SavedWidgetPreset {
    func resolvedColorScheme(fallback colorScheme: ColorScheme) -> ColorScheme {
        self?.colorSchemeOverride
            ?? AbstraktAppearancePreference.sharedAppPreference.colorSchemeOverride
            ?? colorScheme
    }
}

// MARK: - Widget Views

private struct SmallSolidWidgetView: View {
    let entry: SmallSolidWidgetEntry
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content
            .environment(\.colorScheme, entry.selectedPreset.resolvedColorScheme(fallback: colorScheme))
    }

    @ViewBuilder
    private var content: some View {
        switch entry.selectedPreset?.widgetID {
        case "calendar":
            CalendarWidget(
                snapshot: entry.calendar,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "reminder":
            ReminderWidget(
                snapshot: entry.reminders,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
            .widgetURL(entry.reminders.deepLinkURL)
        case "battery":
            BatteryWidget(
                snapshot: entry.battery.renderSnapshot,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "sleep":
            SleepWidget(
                snapshot: entry.sleep,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "steps":
            StepsWidget(
                snapshot: entry.health.renderSnapshot,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "activity":
            ActivityWidget(
                snapshot: entry.activity,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "events":
            EventsWidget(
                snapshot: entry.event,
                mode: WidgetSharedStore.eventMode,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "portal":
            Portal(
                snapshot: entry.portal.renderSnapshot,
                fontTheme: entry.fontTheme,
                selectedApps: WidgetSharedStore.portalSelectedApps,
                iconClipStyle: WidgetSharedStore.portalIconClipStyle,
                usesInteractiveButtons: true,
                clipsToWidgetShape: false
            )
        case "storage":
            StorageWidget(
                snapshot: entry.storage.renderSnapshot,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "weather":
            WeatherWidget(
                snapshot: entry.weather,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "daylight":
            DaylightWidget(
                snapshot: entry.daylight,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        case "heart-rate":
            HeartRateWidget(
                snapshot: entry.heartRate.renderSnapshot,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        default:
            InstructionSolidWidgetView()
        }
    }
}

private struct MediumSolidWidgetView: View {
    let entry: MediumSolidWidgetEntry
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content
            .environment(\.colorScheme, entry.selectedPreset.resolvedColorScheme(fallback: colorScheme))
    }

    @ViewBuilder
    private var content: some View {
        switch entry.selectedPreset?.widgetID {
        case "today":
            TodayWidget(
                snapshot: entry.today.renderSnapshot,
                fontTheme: entry.fontTheme,
                clipsToWidgetShape: false
            )
        default:
            InstructionSolidWidgetView()
        }
    }
}

private struct LargeSolidWidgetView: View {
    let entry: LargeSolidWidgetEntry
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        content
            .environment(\.colorScheme, entry.selectedPreset.resolvedColorScheme(fallback: colorScheme))
    }

    @ViewBuilder
    private var content: some View {
        switch entry.selectedPreset?.widgetID {
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
            selectedPreset: previewPreset(widgetID: selectedWidgetID, size: "small"),
            calendar: CalendarMonthSnapshot(date: .widgetPreviewDate),
            reminders: .placeholder,
            sleep: .placeholder,
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
            activity: .previewWeekly,
            event: .previewUpcoming,
            portal: PortalEntry(
                date: Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 26, hour: 9, minute: 41)) ?? .widgetPreviewDate,
                temperature: 16,
                placeName: "Kuta"
            ),
            storage: StorageWidgetEntry(
                date: .now,
                totalBytes: WidgetSharedStore.storageTotalBytes,
                availableBytes: WidgetSharedStore.storageAvailableBytes
            ),
            weather: .placeholder,
            daylight: .placeholder,
            heartRate: HeartRateWidgetEntry(
                date: .now,
                bpm: WidgetSharedStore.heartRateBPM,
                timestamp: WidgetSharedStore.heartRateTimestamp
            )
        )
    }
}

private extension MediumSolidWidgetEntry {
    static func preview(selectedWidgetID: String?) -> MediumSolidWidgetEntry {
        MediumSolidWidgetEntry(
            date: .widgetPreviewDate,
            selectedPreset: previewPreset(widgetID: selectedWidgetID, size: "medium"),
            today: TodayWidgetEntry(
                date: .widgetPreviewDate,
                temperature: 25,
                high: 30,
                low: 24,
                weatherSymbol: "🌥️",
                conditionLabel: "Partly Cloudy"
            )
        )
    }
}

private extension LargeSolidWidgetEntry {
    static func preview(selectedWidgetID: String?) -> LargeSolidWidgetEntry {
        LargeSolidWidgetEntry(
            date: .widgetPreviewDate,
            selectedPreset: previewPreset(widgetID: selectedWidgetID, size: "large"),
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
            today: TodayWidgetEntry(
                date: .widgetPreviewDate,
                temperature: 25,
                high: 30,
                low: 24,
                weatherSymbol: "🌥️",
                conditionLabel: "Partly Cloudy"
            ),
            storage: StorageWidgetEntry(
                date: .now,
                totalBytes: WidgetSharedStore.storageTotalBytes,
                availableBytes: WidgetSharedStore.storageAvailableBytes
            )
        )
    }
}

private func previewPreset(widgetID: String?, size: String) -> SavedWidgetPreset? {
    guard let widgetID else {
        return nil
    }

    return SavedWidgetPreset(
        id: UUID(),
        widgetID: widgetID,
        name: widgetID,
        size: size,
        appearanceMode: "system"
    )
}

private extension Date {
    static let widgetPreviewDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 6, day: 29, hour: 9, minute: 41)
    ) ?? .now
}

#Preview("Small - Battery", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "battery")
}

#Preview("Small - Calendar", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "calendar")
}

#Preview("Small - Reminder", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "reminder")
}

#Preview("Small - Sleep", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "sleep")
}

#Preview("Small - Steps", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "steps")
}

#Preview("Small - Activity", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "activity")
}

#Preview("Small - Events", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "events")
}

#Preview("Small - Portal", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "portal")
}

#Preview("Small - Storage", as: .systemSmall) {
    SmallSolidWidget()
} timeline: {
    SmallSolidWidgetEntry.preview(selectedWidgetID: "storage")
}

#Preview("Medium - Today", as: .systemMedium) {
    MediumSolidWidget()
} timeline: {
    MediumSolidWidgetEntry.preview(selectedWidgetID: "today")
}

#Preview("Large - Choose Widget", as: .systemLarge) {
    LargeSolidWidget()
} timeline: {
    LargeSolidWidgetEntry.preview(selectedWidgetID: nil)
}
