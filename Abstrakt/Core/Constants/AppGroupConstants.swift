import Foundation

enum AppGroupConstants {
    static let defaultSuiteName = "group.msaf.abstrakt"
    static let legacyFallbackSuiteName = "group.default.abstrakt"

    static let suiteName: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String,
              !value.isEmpty else {
            return defaultSuiteName
        }

        return value
    }()

    static let sharedDefaults = UserDefaults(suiteName: suiteName)
    static let sharedClockTimeKey = "shared.clock.time"
    static let sharedClockDateKey = "shared.clock.date"
    static let sharedCalendarHeadlineKey = "shared.calendar.headline"
    static let sharedCalendarDetailKey = "shared.calendar.detail"
    static let sharedBatteryLevelKey = "shared.battery.level"
    static let sharedBatteryEstimatedHoursKey = "shared.battery.estimatedHours"
    static let sharedBatteryEstimatedMinutesKey = "shared.battery.estimatedMinutes"
    static let sharedBatteryIsChargingKey = "shared.battery.isCharging"
    static let sharedHealthStepsKey = "shared.health.steps"
    static let sharedHealthDistanceKilometersKey = "shared.health.distanceKilometers"
    static let sharedWeatherTemperatureKey = "shared.weather.temperature"
    static let sharedWeatherHighKey = "shared.weather.high"
    static let sharedWeatherLowKey = "shared.weather.low"
    static let sharedWeatherSymbolKey = "shared.weather.symbol"
    static let sharedWeatherConditionLabelKey = "shared.weather.conditionLabel"
    static let sharedPortalWeatherTemperatureKey = "shared.portal.weather.temperature"
    static let sharedPortalWeatherPlaceNameKey = "shared.portal.weather.placeName"
    static let portalSelectedAppsKey = "portal.selectedApps"
    static let portalIconClipStyleKey = "portal.iconClipStyle"
    static let sharedWidgetPresetsKey = "shared.widget.presets"
    static let sharedClassicWeatherKey = "shared.classic.weather"
    static let sharedSunEventWeatherKey = "shared.sunevent.weather"
    static let settingsAppFontThemeKey = "appFontTheme"
    static let settingsTemperatureUnitKey = "settings.temperatureUnit"
    static let settingsTemperatureDisplayKey = "settings.temperatureDisplay"
    static let settingsDistanceUnitKey = "settings.distanceUnit"
    static let sharedStorageTotalBytesKey = "shared.storage.totalBytes"
    static let sharedStorageAvailableBytesKey = "shared.storage.availableBytes"

    static func migrateLegacyFallbackDefaultsIfNeeded() {
        guard suiteName != legacyFallbackSuiteName,
              let legacyDefaults = UserDefaults(suiteName: legacyFallbackSuiteName),
              let currentDefaults = sharedDefaults else {
            return
        }

        for key in sharedKeys where currentDefaults.object(forKey: key) == nil {
            if let value = legacyDefaults.object(forKey: key) {
                currentDefaults.set(value, forKey: key)
            }
        }

        currentDefaults.synchronize()
    }

    private static let sharedKeys = [
        sharedClockTimeKey,
        sharedClockDateKey,
        sharedCalendarHeadlineKey,
        sharedCalendarDetailKey,
        sharedBatteryLevelKey,
        sharedBatteryEstimatedHoursKey,
        sharedBatteryEstimatedMinutesKey,
        sharedBatteryIsChargingKey,
        sharedHealthStepsKey,
        sharedHealthDistanceKilometersKey,
        sharedWeatherTemperatureKey,
        sharedWeatherHighKey,
        sharedWeatherLowKey,
        sharedWeatherSymbolKey,
        sharedWeatherConditionLabelKey,
        sharedPortalWeatherTemperatureKey,
        sharedPortalWeatherPlaceNameKey,
        portalSelectedAppsKey,
        portalIconClipStyleKey,
        sharedWidgetPresetsKey,
        sharedClassicWeatherKey,
        sharedSunEventWeatherKey,
        settingsAppFontThemeKey,
        settingsTemperatureUnitKey,
        settingsTemperatureDisplayKey,
        settingsDistanceUnitKey,
        sharedStorageTotalBytesKey,
        sharedStorageAvailableBytesKey,
    ]
}
