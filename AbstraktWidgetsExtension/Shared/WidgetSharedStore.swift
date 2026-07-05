import Foundation

enum WidgetSharedStore {
    private static let suiteName: String = {
        guard
            let value = Bundle.main.object(forInfoDictionaryKey: "AppGroupID")
                as? String,
            !value.isEmpty
        else {
            return "group.daffa.abstrakt"
        }

        return value
    }()

    private static let defaults = UserDefaults(suiteName: suiteName)
    
    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName)
    }

    static func thumbnailURL(for presetID: String) -> URL? {
        sharedContainerURL?.appendingPathComponent("\(presetID).png")
    }
    private static let sharedWidgetPresetsKey = "shared.widget.presets"
    private static let appFontThemeKey = "appFontTheme"
    private static let temperatureUnitKey = "settings.temperatureUnit"
    private static let distanceUnitKey = "settings.distanceUnit"
    private static let weatherConditionLabelKey =
        "shared.weather.conditionLabel"
    private static let activityModeKey = "health.metrics.mode"
    private static let eventModeKey = "calendar.event.mode"

    #if targetEnvironment(simulator)
    private static let simulatorActivePresetKeySmall = "shared.widget.simulatorActivePreset.small"
    private static let simulatorActivePresetKeyMedium = "shared.widget.simulatorActivePreset.medium"
    private static let simulatorActivePresetKeyLarge = "shared.widget.simulatorActivePreset.large"

    /// Simulator-only: reads the preset UUID that the host app marked as the
    /// active render target for this widget size. Returns nil on real devices.
    static func simulatorActivePresetID(forSize size: String) -> UUID? {
        let key: String
        switch size {
        case "small":  key = simulatorActivePresetKeySmall
        case "medium": key = simulatorActivePresetKeyMedium
        default:       key = simulatorActivePresetKeyLarge
        }
        guard let raw = defaults?.string(forKey: key) else { return nil }
        return UUID(uuidString: raw)
    }
    #endif

    // MARK: - JSON Decode Caches

    private static let jsonCacheTTL: TimeInterval = 5
    private static var cachedEventSnapshot: (snapshot: EventsSnapshot, timestamp: Date)?
    private static var cachedWeather: (snapshot: WeatherSnapshot, timestamp: Date)?
    private static var cachedDaylight: (snapshot: DaylightSnapshot, timestamp: Date)?
    private static var cachedPresets: (presets: [SavedWidgetPreset], timestamp: Date)?
    private static var cachedFallbackStorage: (totalBytes: Int64, availableBytes: Int64, timestamp: Date)?

    private static var now: TimeInterval { Date().timeIntervalSince1970 }

    static var appFontTheme: AbstraktWidgetFontTheme {
        AbstraktWidgetFontTheme.from(
            id: defaults?.string(forKey: appFontThemeKey)
                ?? AbstraktWidgetFontTheme.sfProRounded.id
        )
    }

    static var clockTime: String {
        defaults?.string(forKey: "shared.clock.time")
            ?? Date.now.formatted(.dateTime.hour().minute())
    }

    static var clockDate: String {
        defaults?.string(forKey: "shared.clock.date")
            ?? Date.now.formatted(
                .dateTime.weekday(.wide).month(.abbreviated).day()
            )
    }

    static var calendarHeadline: String {
        defaults?.string(forKey: "shared.calendar.headline")
            ?? Date.now.formatted(.dateTime.weekday(.wide))
    }

    static var calendarDetail: String {
        defaults?.string(forKey: "shared.calendar.detail") ?? "No events today"
    }

    static var eventMode: EventDisplayMode {
        EventDisplayMode.from(id: defaults?.string(forKey: eventModeKey))
    }

    static var eventSnapshot: EventsSnapshot {
        if let cached = cachedEventSnapshot,
           now - cached.timestamp.timeIntervalSince1970 < jsonCacheTTL {
            return cached.snapshot
        }

        let snapshot: EventsSnapshot
        if let data = defaults?.data(forKey: "shared.calendar.events"),
           let decoded = try? JSONDecoder().decode(EventsSnapshot.self, from: data) {
            snapshot = decoded
        } else {
            snapshot = EventsSnapshot(date: .now, accessState: .empty)
        }

        cachedEventSnapshot = (snapshot, Date())
        return snapshot
    }

    static var batteryLevel: Int {
        defaults?.object(forKey: "shared.battery.level") as? Int ?? 0
    }

    static var batteryEstimatedHours: Int? {
        defaults?.object(forKey: "shared.battery.estimatedHours") as? Int
    }

    static var batteryEstimatedMinutes: Int? {
        if let minutes = defaults?.object(
            forKey: "shared.battery.estimatedMinutes"
        ) as? Int {
            return minutes
        }

        return batteryEstimatedHours.map { $0 * 60 }
    }

    static var batteryIsCharging: Bool {
        defaults?.bool(forKey: "shared.battery.isCharging") ?? false
    }

    static var healthSteps: Int {
        defaults?.object(forKey: "shared.health.steps") as? Int ?? 0
    }

    static var healthDistanceKilometers: Double {
        defaults?.object(forKey: "shared.health.distanceKilometers") as? Double
            ?? 0
    }

    static var healthDistanceValue: Double {
        switch distanceUnitID {
        case "miles":
            healthDistanceKilometers * 0.621371
        default:
            healthDistanceKilometers
        }
    }

    static var healthDistanceUnitName: String {
        switch distanceUnitID {
        case "miles":
            "miles"
        default:
            "kilometers"
        }
    }

    static var activity: ActivitySnapshot {
        let mode = ActivityMode.from(id: defaults?.string(forKey: activityModeKey))
        return activity(mode: mode)
    }

    static var weatherTemperature: Int {
        convertedTemperature(
            defaults?.object(forKey: "shared.weather.temperature") as? Int ?? 25
        )
    }

    static var weatherTemperatureCelsius: Int {
        defaults?.object(forKey: "shared.weather.temperature") as? Int ?? 25
    }

    static var weatherHigh: Int {
        convertedTemperature(
            defaults?.object(forKey: "shared.weather.high") as? Int ?? 30
        )
    }

    static var weatherHighCelsius: Int {
        defaults?.object(forKey: "shared.weather.high") as? Int ?? 30
    }

    static var weatherLow: Int {
        convertedTemperature(
            defaults?.object(forKey: "shared.weather.low") as? Int ?? 24
        )
    }

    static var weatherLowCelsius: Int {
        defaults?.object(forKey: "shared.weather.low") as? Int ?? 24
    }

    static var weatherSymbol: String {
        defaults?.string(forKey: "shared.weather.symbol") ?? "🌥️"
    }

    static var weatherConditionLabel: String {
        defaults?.string(forKey: weatherConditionLabelKey) ?? "Partly Cloudy"
    }

    static var portalWeatherTemperatureCelsius: Int {
        defaults?.object(forKey: "shared.portal.weather.temperature") as? Int
            ?? 16
    }

    static var portalWeatherPlaceName: String {
        defaults?.string(forKey: "shared.portal.weather.placeName") ?? "Kuta"
    }

    static var portalSelectedApps: [PortalApp] {
        PortalApp.selection(
            from: defaults?.string(forKey: "portal.selectedApps")
        )
    }

    static var portalIconClipStyle: PortalIconClipStyle {
        PortalIconClipStyle.from(
            id: defaults?.string(forKey: "portal.iconClipStyle")
        )
    }

    static var weather: WeatherSnapshot {
        if let cached = cachedWeather,
           now - cached.timestamp.timeIntervalSince1970 < jsonCacheTTL {
            return cached.snapshot
        }

        let snapshot: WeatherSnapshot
        if let data = defaults?.data(forKey: "shared.weather"),
           let decoded = try? JSONDecoder().decode(WeatherSnapshot.self, from: data) {
            snapshot = decoded
        } else {
            snapshot = .placeholder
        }

        cachedWeather = (snapshot, Date())
        return snapshot
    }

    static var daylight: DaylightSnapshot {
        if let cached = cachedDaylight,
           now - cached.timestamp.timeIntervalSince1970 < jsonCacheTTL {
            return cached.snapshot
        }

        let snapshot: DaylightSnapshot
        if let data = defaults?.data(forKey: "shared.daylight"),
           let decoded = try? JSONDecoder().decode(DaylightSnapshot.self, from: data) {
            snapshot = decoded
        } else {
            snapshot = .placeholder
        }

        cachedDaylight = (snapshot, Date())
        return snapshot
    }

    static func savedPresets(size: String) -> [SavedWidgetPreset] {
        allSavedPresets.filter { $0.size == size }
    }

    static func savedPreset(id: UUID, size: String) -> SavedWidgetPreset? {
        savedPresets(size: size).first { $0.id == id }
    }

    static func savedPreset(widgetID: String, size: String)
        -> SavedWidgetPreset?
    {
        savedPresets(size: size).first { $0.widgetID == widgetID }
    }

    static func fallbackPreset(size: String) -> SavedWidgetPreset? {
        savedPresets(size: size).first
    }

    static var allSavedPresets: [SavedWidgetPreset] {
        if let cached = cachedPresets,
           now - cached.timestamp.timeIntervalSince1970 < jsonCacheTTL {
            return cached.presets
        }

        let presets: [SavedWidgetPreset]
        if let data = defaults?.data(forKey: sharedWidgetPresetsKey),
           let decoded = try? JSONDecoder().decode([SavedWidgetPreset].self, from: data),
           !decoded.isEmpty {
            presets = decoded
        } else {
            presets = []
        }

        cachedPresets = (presets, Date())
        return presets
    }

    private static var temperatureUnitID: String {
        defaults?.string(forKey: temperatureUnitKey) ?? "celsius"
    }

    private static var distanceUnitID: String {
        defaults?.string(forKey: distanceUnitKey) ?? "kilometers"
    }

    private static func convertedTemperature(_ celsius: Int) -> Int {
        switch temperatureUnitID {
        case "fahrenheit":
            Int((Double(celsius) * 9.0 / 5.0 + 32.0).rounded())
        default:
            celsius
        }
    }

    private static func activity(mode: ActivityMode) -> ActivitySnapshot {
        switch mode {
        case .today:
            ActivitySnapshot(
                mode: .today,
                exerciseMinutes: intValue(forKey: "shared.activity.today.exerciseMinutes"),
                activeEnergyCalories: intValue(forKey: "shared.activity.today.activeEnergy"),
                sleepMinutes: intValue(forKey: "shared.activity.today.sleepMinutes")
            )
        case .weekly:
            ActivitySnapshot(
                mode: .weekly,
                exerciseMinutes: intValue(forKey: "shared.activity.weekly.exerciseMinutes"),
                activeEnergyCalories: intValue(forKey: "shared.activity.weekly.activeEnergy"),
                sleepMinutes: intValue(forKey: "shared.activity.weekly.sleepMinutes")
            )
        }
    }

    private static func intValue(forKey key: String, fallback: Int = 0) -> Int {
        switch defaults?.object(forKey: key) {
        case let value as Int:
            value
        case let value as NSNumber:
            value.intValue
        default:
            fallback
        }
    }

    private static let fallbackSavedPresets = [
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0001")
                ?? UUID(),
            widgetID: "battery",
            name: "Battery",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0002")
                ?? UUID(),
            widgetID: "steps",
            name: "Steps",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0009") ?? UUID(),
            widgetID: "activity",
            name: "Activity",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0010") ?? UUID(),
            widgetID: "events",
            name: "Events",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0004") ?? UUID(),
            widgetID: "portal",
            name: "Portal",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0003")
                ?? UUID(),
            widgetID: "today",
            name: "Today",
            size: "medium",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0005")
                ?? UUID(),
            widgetID: "storage",
            name: "Storage",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0006")
                ?? UUID(),
            widgetID: "weather",
            name: "Weather",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0007")
                ?? UUID(),
            widgetID: "daylight",
            name: "Daylight",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0008")
                ?? UUID(),
            widgetID: "heart-rate",
            name: "Heart Rate",
            size: "small",
            appearanceMode: "system"
        ),
    ]

    static var storageTotalBytes: Int64 {
        int64Value(
            forKey: "shared.storage.totalBytes",
            fallback: fallbackStorageSnapshot.totalBytes
        )
    }

    static var storageAvailableBytes: Int64 {
        int64Value(
            forKey: "shared.storage.availableBytes",
            fallback: fallbackStorageSnapshot.availableBytes
        )
    }

    private static func int64Value(forKey key: String, fallback: Int64) -> Int64
    {
        switch defaults?.object(forKey: key) {
        case let value as Int64:
            value
        case let value as Int:
            Int64(value)
        case let value as UInt64:
            value > UInt64(Int64.max) ? Int64.max : Int64(value)
        case let value as UInt:
            value > UInt(Int64.max) ? Int64.max : Int64(value)
        case let value as NSNumber:
            value.int64Value
        default:
            fallback
        }
    }

    private static var fallbackStorageSnapshot:
        (totalBytes: Int64, availableBytes: Int64)
    {
        if let cached = cachedFallbackStorage,
           now - cached.timestamp.timeIntervalSince1970 < jsonCacheTTL {
            return (cached.totalBytes, cached.availableBytes)
        }

        let result: (totalBytes: Int64, availableBytes: Int64)
        if let attrs = try? FileManager.default.attributesOfFileSystem(
                forPath: NSHomeDirectory()
            ),
            let total = int64Value(attrs[.systemSize]),
            let free = int64Value(attrs[.systemFreeSize]) {
            let safeTotal = max(0, total)
            result = (safeTotal, min(max(0, free), safeTotal))
        } else {
            result = (0, 0)
        }

        cachedFallbackStorage = (result.totalBytes, result.availableBytes, Date())
        return result
    }

    private static func int64Value(_ value: Any?) -> Int64? {
        switch value {
        case let value as Int64:
            value
        case let value as Int:
            Int64(value)
        case let value as UInt64:
            value > UInt64(Int64.max) ? Int64.max : Int64(value)
        case let value as UInt:
            value > UInt(Int64.max) ? Int64.max : Int64(value)
        case let value as NSNumber:
            value.int64Value
        default:
            nil
        }
    }

    static var heartRateBPM: Int {
        defaults?.object(forKey: "shared.heartRate.bpm") as? Int ?? 0
    }

    static var heartRateTimestamp: Date {
        guard
            let interval = defaults?.object(
                forKey: "shared.heartRate.timestamp"
            ) as? TimeInterval
        else {
            return .now
        }
        return Date(timeIntervalSince1970: interval)
    }
}
