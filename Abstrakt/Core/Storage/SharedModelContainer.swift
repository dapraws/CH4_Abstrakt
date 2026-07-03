import Foundation

enum SharedModelContainer {
    private static let defaults = UserDefaults(suiteName: AppGroupConstants.suiteName)

    static func write(clock: ClockSnapshot, calendar: CalendarSnapshot) {
        defaults?.set(clock.timeText, forKey: AppGroupConstants.sharedClockTimeKey)
        defaults?.set(clock.dateText, forKey: AppGroupConstants.sharedClockDateKey)
        defaults?.set(calendar.headline, forKey: AppGroupConstants.sharedCalendarHeadlineKey)
        defaults?.set(calendar.detail, forKey: AppGroupConstants.sharedCalendarDetailKey)
        if let data = try? JSONEncoder().encode(calendar.eventSnapshot) {
            defaults?.set(data, forKey: AppGroupConstants.sharedEventsKey)
        }
        defaults?.synchronize()
    }

    static func write(clock: ClockSnapshot) {
        defaults?.set(clock.timeText, forKey: AppGroupConstants.sharedClockTimeKey)
        defaults?.set(clock.dateText, forKey: AppGroupConstants.sharedClockDateKey)
        defaults?.synchronize()
    }

    static func write(battery: BatterySnapshot) {
        defaults?.set(battery.level, forKey: AppGroupConstants.sharedBatteryLevelKey)
        if let estimatedMinutesRemaining = battery.estimatedMinutesRemaining {
            defaults?.set(estimatedMinutesRemaining, forKey: AppGroupConstants.sharedBatteryEstimatedMinutesKey)
            defaults?.set(Int(round(Double(estimatedMinutesRemaining) / 60.0)), forKey: AppGroupConstants.sharedBatteryEstimatedHoursKey)
        } else {
            defaults?.removeObject(forKey: AppGroupConstants.sharedBatteryEstimatedMinutesKey)
            defaults?.removeObject(forKey: AppGroupConstants.sharedBatteryEstimatedHoursKey)
        }
        defaults?.set(battery.isCharging, forKey: AppGroupConstants.sharedBatteryIsChargingKey)
        defaults?.synchronize()
    }

    static func write(health: HealthSummarySnapshot) {
        defaults?.set(health.steps, forKey: AppGroupConstants.sharedHealthStepsKey)
        defaults?.set(health.distanceKilometers, forKey: AppGroupConstants.sharedHealthDistanceKilometersKey)
        defaults?.synchronize()
    }

    static func write(activity snapshots: [ActivityMode: ActivitySnapshot]) {
        writeActivity(snapshots[.today], prefix: "today")
        writeActivity(snapshots[.weekly], prefix: "weekly")
        defaults?.synchronize()
    }

    static func write(today: TodaySnapshot) {
        defaults?.set(today.temperature, forKey: AppGroupConstants.sharedWeatherTemperatureKey)
        defaults?.set(today.high, forKey: AppGroupConstants.sharedWeatherHighKey)
        defaults?.set(today.low, forKey: AppGroupConstants.sharedWeatherLowKey)
        defaults?.set(today.weatherSymbol, forKey: AppGroupConstants.sharedWeatherSymbolKey)
        defaults?.set(today.conditionLabel, forKey: AppGroupConstants.sharedWeatherConditionLabelKey)
        defaults?.synchronize()
    }

    static func write(portal: PortalSnapshot) {
        defaults?.set(portal.temperature, forKey: AppGroupConstants.sharedPortalWeatherTemperatureKey)
        defaults?.set(portal.placeName, forKey: AppGroupConstants.sharedPortalWeatherPlaceNameKey)
        defaults?.synchronize()
    }

    static func write(appFontThemeID: String) {
        defaults?.set(appFontThemeID, forKey: AppGroupConstants.settingsAppFontThemeKey)
        defaults?.synchronize()
    }

    static func write(widgetPresets: [WidgetPreset]) {
        guard let data = try? JSONEncoder().encode(widgetPresets) else {
            return
        }

        defaults?.set(data, forKey: AppGroupConstants.sharedWidgetPresetsKey)
        defaults?.synchronize()
    }
    
    static func write(storage: StorageSnapshot) {
        defaults?.set(storage.totalBytes, forKey: AppGroupConstants.sharedStorageTotalBytesKey)
        defaults?.set(storage.availableBytes, forKey: AppGroupConstants.sharedStorageAvailableBytesKey)
        defaults?.synchronize()
    }
    
    static func write(weather: WeatherSnapshot) {
        guard let data = try? JSONEncoder().encode(weather) else { return }
        defaults?.set(data, forKey: AppGroupConstants.sharedWeatherKey)
        defaults?.synchronize()
    }

    static func write(daylight: DaylightSnapshot) {
        guard let data = try? JSONEncoder().encode(daylight) else { return }
        defaults?.set(data, forKey: AppGroupConstants.sharedDaylightKey)
        defaults?.synchronize()
    }
    
    static func write(heartRate: HeartRateSnapshot) {
        defaults?.set(heartRate.bpm, forKey: AppGroupConstants.sharedHeartRateBPMKey)
        defaults?.set(heartRate.timestamp.timeIntervalSince1970, forKey: AppGroupConstants.sharedHeartRateTimestampKey)
        defaults?.synchronize()
    }

    private static func writeActivity(_ snapshot: ActivitySnapshot?, prefix: String) {
        guard let snapshot else { return }

        switch prefix {
        case "today":
            defaults?.set(snapshot.exerciseMinutes, forKey: AppGroupConstants.sharedActivityTodayExerciseMinutesKey)
            defaults?.set(snapshot.activeEnergyCalories, forKey: AppGroupConstants.sharedActivityTodayActiveEnergyKey)
            defaults?.set(snapshot.sleepMinutes, forKey: AppGroupConstants.sharedActivityTodaySleepMinutesKey)
        case "weekly":
            defaults?.set(snapshot.exerciseMinutes, forKey: AppGroupConstants.sharedActivityWeeklyExerciseMinutesKey)
            defaults?.set(snapshot.activeEnergyCalories, forKey: AppGroupConstants.sharedActivityWeeklyActiveEnergyKey)
            defaults?.set(snapshot.sleepMinutes, forKey: AppGroupConstants.sharedActivityWeeklySleepMinutesKey)
        default:
            break
        }
    }
}
