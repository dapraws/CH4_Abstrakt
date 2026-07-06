import Foundation

enum AppGroupConstants {
    static let defaultSuiteName = "group.daffa.abstrakt"
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
    static let sharedEventsKey = "shared.calendar.events"
    static let eventModeKey = "calendar.event.mode"
    static let sharedBatteryLevelKey = "shared.battery.level"
    static let sharedBatteryEstimatedHoursKey = "shared.battery.estimatedHours"
    static let sharedBatteryEstimatedMinutesKey = "shared.battery.estimatedMinutes"
    static let sharedBatteryIsChargingKey = "shared.battery.isCharging"
    static let sharedHealthStepsKey = "shared.health.steps"
    static let sharedHealthDistanceKilometersKey = "shared.health.distanceKilometers"
    static let activityModeKey = "health.metrics.mode"
    static let sharedActivityTodayExerciseMinutesKey = "shared.activity.today.exerciseMinutes"
    static let sharedActivityTodayActiveEnergyKey = "shared.activity.today.activeEnergy"
    static let sharedActivityTodaySleepMinutesKey = "shared.activity.today.sleepMinutes"
    static let sharedActivityWeeklyExerciseMinutesKey = "shared.activity.weekly.exerciseMinutes"
    static let sharedActivityWeeklyActiveEnergyKey = "shared.activity.weekly.activeEnergy"
    static let sharedActivityWeeklySleepMinutesKey = "shared.activity.weekly.sleepMinutes"
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
    static let sharedWeatherKey = "shared.weather"
    static let sharedDaylightKey = "shared.daylight"
    static let settingsAppFontThemeKey = "appFontTheme"
    static let settingsTemperatureUnitKey = "settings.temperatureUnit"
    static let settingsTemperatureDisplayKey = "settings.temperatureDisplay"
    static let settingsDistanceUnitKey = "settings.distanceUnit"
    static let sharedStorageTotalBytesKey = "shared.storage.totalBytes"
    static let sharedStorageAvailableBytesKey = "shared.storage.availableBytes"
    static let sharedHeartRateBPMKey = "shared.heartRate.bpm"
    static let sharedHeartRateTimestampKey = "shared.heartRate.timestamp"

    #if targetEnvironment(simulator)
    static let simulatorActivePresetKeySmall = "shared.widget.simulatorActivePreset.small"
    static let simulatorActivePresetKeyMedium = "shared.widget.simulatorActivePreset.medium"
    static let simulatorActivePresetKeyLarge = "shared.widget.simulatorActivePreset.large"
    #endif
    
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

    }

    private static let sharedKeys = [
        sharedClockTimeKey,
        sharedClockDateKey,
        sharedCalendarHeadlineKey,
        sharedCalendarDetailKey,
        sharedEventsKey,
        eventModeKey,
        sharedBatteryLevelKey,
        sharedBatteryEstimatedHoursKey,
        sharedBatteryEstimatedMinutesKey,
        sharedBatteryIsChargingKey,
        sharedHealthStepsKey,
        sharedHealthDistanceKilometersKey,
        activityModeKey,
        sharedActivityTodayExerciseMinutesKey,
        sharedActivityTodayActiveEnergyKey,
        sharedActivityTodaySleepMinutesKey,
        sharedActivityWeeklyExerciseMinutesKey,
        sharedActivityWeeklyActiveEnergyKey,
        sharedActivityWeeklySleepMinutesKey,
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
        sharedWeatherKey,
        sharedDaylightKey,
        settingsAppFontThemeKey,
        settingsTemperatureUnitKey,
        settingsTemperatureDisplayKey,
        settingsDistanceUnitKey,
        sharedStorageTotalBytesKey,
        sharedStorageAvailableBytesKey,
        sharedHeartRateBPMKey,
        sharedHeartRateTimestampKey
    ]
}
