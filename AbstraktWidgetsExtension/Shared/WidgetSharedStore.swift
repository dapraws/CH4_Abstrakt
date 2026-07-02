import Foundation

enum WidgetSharedStore {
    private static let suiteName = "group.msaf.abstrakt"

    private static let defaults = UserDefaults(suiteName: suiteName)
    private static let sharedWidgetPresetsKey = "shared.widget.presets"
    private static let appFontThemeKey = "appFontTheme"
    private static let temperatureUnitKey = "settings.temperatureUnit"
    private static let distanceUnitKey = "settings.distanceUnit"

    static var appFontTheme: AbstraktWidgetFontTheme {
        AbstraktWidgetFontTheme.from(id: defaults?.string(forKey: appFontThemeKey) ?? AbstraktWidgetFontTheme.sfProRounded.id)
    }

    static var clockTime: String {
        defaults?.string(forKey: "shared.clock.time") ?? Date.now.formatted(.dateTime.hour().minute())
    }

    static var clockDate: String {
        defaults?.string(forKey: "shared.clock.date") ?? Date.now.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
    }

    static var calendarHeadline: String {
        defaults?.string(forKey: "shared.calendar.headline") ?? Date.now.formatted(.dateTime.weekday(.wide))
    }

    static var calendarDetail: String {
        defaults?.string(forKey: "shared.calendar.detail") ?? "No connected events yet"
    }

    static var batteryLevel: Int {
        defaults?.object(forKey: "shared.battery.level") as? Int ?? 0
    }

    static var batteryEstimatedHours: Int? {
        defaults?.object(forKey: "shared.battery.estimatedHours") as? Int
    }

    static var batteryEstimatedMinutes: Int? {
        if let minutes = defaults?.object(forKey: "shared.battery.estimatedMinutes") as? Int {
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
        defaults?.object(forKey: "shared.health.distanceKilometers") as? Double ?? 0
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
        convertedTemperature(defaults?.object(forKey: "shared.weather.temperature") as? Int ?? 25)
    }

    static var weatherTemperatureCelsius: Int {
        defaults?.object(forKey: "shared.weather.temperature") as? Int ?? 25
    }

    static var weatherHigh: Int {
        convertedTemperature(defaults?.object(forKey: "shared.weather.high") as? Int ?? 30)
    }

    static var weatherHighCelsius: Int {
        defaults?.object(forKey: "shared.weather.high") as? Int ?? 30
    }

    static var weatherLow: Int {
        convertedTemperature(defaults?.object(forKey: "shared.weather.low") as? Int ?? 24)
    }

    static var weatherLowCelsius: Int {
        defaults?.object(forKey: "shared.weather.low") as? Int ?? 24
    }

    static var weatherSymbol: String {
        defaults?.string(forKey: "shared.weather.symbol") ?? "🌥️"
    }

    static var portalWeatherTemperatureCelsius: Int {
        defaults?.object(forKey: "shared.portal.weather.temperature") as? Int ?? 16
    }

    static var portalWeatherPlaceName: String {
        defaults?.string(forKey: "shared.portal.weather.placeName") ?? "Denpasar"
    }

    static var portalSelectedApps: [PortalApp] {
        PortalApp.selection(from: defaults?.string(forKey: "portal.selectedApps"))
    }

    static var portalIconClipStyle: PortalIconClipStyle {
        PortalIconClipStyle.from(id: defaults?.string(forKey: "portal.iconClipStyle"))
    }

    static func savedPresets(size: String) -> [SavedWidgetPreset] {
        allSavedPresets.filter { $0.size == size }
    }

    static func savedPreset(id: UUID, size: String) -> SavedWidgetPreset? {
        savedPresets(size: size).first { $0.id == id }
    }

    static func savedPreset(widgetID: String, size: String) -> SavedWidgetPreset? {
        savedPresets(size: size).first { $0.widgetID == widgetID }
    }

    static func fallbackPreset(size: String) -> SavedWidgetPreset? {
        savedPresets(size: size).first
    }

    private static var allSavedPresets: [SavedWidgetPreset] {
        guard let data = defaults?.data(forKey: sharedWidgetPresetsKey),
              let presets = try? JSONDecoder().decode([SavedWidgetPreset].self, from: data) else {
            return fallbackSavedPresets
        }

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

    private static let fallbackSavedPresets = [
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0001") ?? UUID(),
            widgetID: "battery-bars-small",
            name: "Battery Bars | Classic",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0002") ?? UUID(),
            widgetID: "step-health-small",
            name: "Step Health | Minimalism",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0004") ?? UUID(),
            widgetID: "portal-widget-small",
            name: "Portal Widget | Apps",
            size: "small",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0003") ?? UUID(),
            widgetID: "daily-dashboard-medium",
            name: "Daily Dashboard | Portal",
            size: "medium",
            appearanceMode: "system"
        ),
        SavedWidgetPreset(
            id: UUID(uuidString: "2E0F6F8A-0EF8-4F0D-A63E-70F7EF7A0005") ?? UUID(),
            widgetID: "device-storage-small",
            name: "Device Storage | Utility",
            size: "small",
            appearanceMode: "system"
        ),
    ]
    
    static var storageTotalBytes: Int64 {
        defaults?.object(forKey: "shared.storage.totalBytes") as? Int64 ?? 0
    }

    static var storageAvailableBytes: Int64 {
        defaults?.object(forKey: "shared.storage.availableBytes") as? Int64 ?? 0
    }
}
