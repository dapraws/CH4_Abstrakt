import Foundation

enum AppGroupConstants {
    static let suiteName: String = {
        guard let value = Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String,
              !value.isEmpty else {
            assertionFailure("Missing AppGroupID Info.plist value. Check APP_GROUP_ID in Signing.xcconfig.")
            return ""
        }

        return value
    }()

    static let sharedDefaults: UserDefaults? = {
        guard !suiteName.isEmpty,
              FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: suiteName) != nil else {
            return nil
        }

        return UserDefaults(suiteName: suiteName)
    }()
    static let sharedClockTimeKey = "shared.clock.time"
    static let sharedClockDateKey = "shared.clock.date"
    static let sharedCalendarHeadlineKey = "shared.calendar.headline"
    static let sharedCalendarDetailKey = "shared.calendar.detail"
    static let sharedEventsKey = "shared.calendar.events"
    static let sharedRemindersKey = "shared.calendar.reminders"
    static let eventModeKey = "calendar.event.mode"
    static let reminderSelectedIdentifierKey = "calendar.reminder.selectedIdentifier"
    static let reminderSelectedTitleKey = "calendar.reminder.selectedTitle"
    static let sharedBatteryLevelKey = "shared.battery.level"
    static let sharedBatteryEstimatedHoursKey = "shared.battery.estimatedHours"
    static let sharedBatteryEstimatedMinutesKey = "shared.battery.estimatedMinutes"
    static let sharedBatteryIsChargingKey = "shared.battery.isCharging"
    static let liveActivityBatteryEnabledKey = "liveActivity.battery.enabled"
    static let sharedHealthStepsKey = "shared.health.steps"
    static let sharedHealthDistanceKilometersKey = "shared.health.distanceKilometers"
    static let sharedSleepKey = "shared.health.sleep"
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
    static let settingsAppLanguageKey = "settings.appLanguage"
    static let sharedStorageTotalBytesKey = "shared.storage.totalBytes"
    static let sharedStorageAvailableBytesKey = "shared.storage.availableBytes"
    static let sharedHeartRateBPMKey = "shared.heartRate.bpm"
    static let sharedHeartRateTimestampKey = "shared.heartRate.timestamp"

    #if targetEnvironment(simulator)
    static let simulatorActivePresetKeySmall = "shared.widget.simulatorActivePreset.small"
    static let simulatorActivePresetKeyMedium = "shared.widget.simulatorActivePreset.medium"
    static let simulatorActivePresetKeyLarge = "shared.widget.simulatorActivePreset.large"
    #endif
}
