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
    private static let sharedWidgetPresetsKey = "shared.widget.presets"
    private static let appFontThemeKey = "appFontTheme"
    private static let temperatureUnitKey = "settings.temperatureUnit"
    private static let distanceUnitKey = "settings.distanceUnit"
    private static let weatherConditionLabelKey =
        "shared.weather.conditionLabel"

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

    static var classicWeather: ClassicWeatherSnapshot {
        guard let data = defaults?.data(forKey: "shared.classic.weather"),
            let snapshot = try? JSONDecoder().decode(
                ClassicWeatherSnapshot.self,
                from: data
            )
        else {
            return .placeholder
        }
        return snapshot
    }

    static var sunEventWeather: SunEventWeatherSnapshot {
        guard let data = defaults?.data(forKey: "shared.sunevent.weather"),
            let snapshot = try? JSONDecoder().decode(
                SunEventWeatherSnapshot.self,
                from: data
            )
        else {
            return .placeholder
        }
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

    private static var allSavedPresets: [SavedWidgetPreset] {
        guard let data = defaults?.data(forKey: sharedWidgetPresetsKey),
            let presets = try? JSONDecoder().decode(
                [SavedWidgetPreset].self,
                from: data
            )
        else {
            return fallbackSavedPresets
        }

        return presets.isEmpty ? fallbackSavedPresets : presets
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

    private static let fallbackSavedPresets = [
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0001")
                ?? UUID(),
            widgetID: "battery-bars-small",
            name: "Battery Bars | Classic",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0002")
                ?? UUID(),
            widgetID: "step-health-small",
            name: "Step Health | Minimalism",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0004")
                ?? UUID(),
            widgetID: "portal-widget-small",
            name: "Portal Widget | Apps",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0003")
                ?? UUID(),
            widgetID: "daily-dashboard-medium",
            name: "Daily Dashboard | Portal",
            size: "medium",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0005")
                ?? UUID(),
            widgetID: "device-storage-small",
            name: "Device Storage | Utility",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0006")
                ?? UUID(),
            widgetID: "classic-weather-small",
            name: "Classic Weather | Classic",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0007")
                ?? UUID(),
            widgetID: "sun-event-weather-small",
            name: "Sun Event Weather | Minimalism",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0008")
                ?? UUID(),
            widgetID: "heart-beat-small",
            name: "Heart Beat | Health",
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
        guard
            let attrs = try? FileManager.default.attributesOfFileSystem(
                forPath: NSHomeDirectory()
            ),
            let total = int64Value(attrs[.systemSize]),
            let free = int64Value(attrs[.systemFreeSize])
        else {
            return (0, 0)
        }

        let safeTotal = max(0, total)
        return (safeTotal, min(max(0, free), safeTotal))
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
