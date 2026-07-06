import Foundation

enum SharedModelContainer {
    private static var defaults: UserDefaults? {
        AppGroupConstants.sharedDefaults
    }

    static func write(clock: ClockSnapshot, calendar: CalendarSnapshot) {
        defaults?.set(clock.timeText, forKey: AppGroupConstants.sharedClockTimeKey)
        defaults?.set(clock.dateText, forKey: AppGroupConstants.sharedClockDateKey)
        defaults?.set(calendar.headline, forKey: AppGroupConstants.sharedCalendarHeadlineKey)
        defaults?.set(calendar.detail, forKey: AppGroupConstants.sharedCalendarDetailKey)
        if let data = try? JSONEncoder().encode(calendar.eventSnapshot) {
            defaults?.set(data, forKey: AppGroupConstants.sharedEventsKey)
        }
    }

    static func write(clock: ClockSnapshot) {
        defaults?.set(clock.timeText, forKey: AppGroupConstants.sharedClockTimeKey)
        defaults?.set(clock.dateText, forKey: AppGroupConstants.sharedClockDateKey)
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
    }

    static func write(health: HealthSummarySnapshot) {
        defaults?.set(health.steps, forKey: AppGroupConstants.sharedHealthStepsKey)
        defaults?.set(health.distanceKilometers, forKey: AppGroupConstants.sharedHealthDistanceKilometersKey)
    }

    static func write(activity snapshots: [ActivityMode: ActivitySnapshot]) {
        writeActivity(snapshots[.today], prefix: "today")
        writeActivity(snapshots[.weekly], prefix: "weekly")
    }

    static func write(today: TodaySnapshot) {
        defaults?.set(today.temperature, forKey: AppGroupConstants.sharedWeatherTemperatureKey)
        defaults?.set(today.high, forKey: AppGroupConstants.sharedWeatherHighKey)
        defaults?.set(today.low, forKey: AppGroupConstants.sharedWeatherLowKey)
        defaults?.set(today.weatherSymbol, forKey: AppGroupConstants.sharedWeatherSymbolKey)
        defaults?.set(today.conditionLabel, forKey: AppGroupConstants.sharedWeatherConditionLabelKey)
    }

    static func write(portal: PortalSnapshot) {
        defaults?.set(portal.temperature, forKey: AppGroupConstants.sharedPortalWeatherTemperatureKey)
        defaults?.set(portal.placeName, forKey: AppGroupConstants.sharedPortalWeatherPlaceNameKey)
    }

    static func write(appFontThemeID: String) {
        defaults?.set(appFontThemeID, forKey: AppGroupConstants.settingsAppFontThemeKey)
    }

    static func write(widgetPresets: [WidgetPreset]) {
        guard let data = try? JSONEncoder().encode(widgetPresets) else {
            return
        }

        defaults?.set(data, forKey: AppGroupConstants.sharedWidgetPresetsKey)
    }

    static func removeWidgetPreset(id: UUID) {
        var presets = readWidgetPresets()
        guard let index = presets.firstIndex(where: { $0.id == id }) else {
            return
        }

        let presetID = presets[index].id.uuidString
        presets.remove(at: index)
        write(widgetPresets: presets)
        removeThumbnail(for: presetID)
    }
    
    static func readWidgetPresets() -> [WidgetPreset] {
        guard let data = defaults?.data(forKey: AppGroupConstants.sharedWidgetPresetsKey),
              let presets = try? JSONDecoder().decode([WidgetPreset].self, from: data) else {
            return []
        }
        return presets
    }
    
    static var sharedContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroupConstants.suiteName)
    }

    static func thumbnailURL(for presetID: String) -> URL? {
        sharedContainerURL?.appendingPathComponent("\(presetID).png")
    }

    static func saveThumbnail(_ data: Data, for presetID: String) {
        if let url = thumbnailURL(for: presetID) {
            try? data.write(to: url)
        }
    }
    
    static func removeThumbnail(for presetID: String) {
        if let url = thumbnailURL(for: presetID) {
            try? FileManager.default.removeItem(at: url)
        }
    }

    #if targetEnvironment(simulator)
    /// Writes the preset UUID that the simulator's widget extension should render
    /// for the given size. This bypasses the broken AppIntent system picker on iOS Simulator.
    static func setSimulatorActivePreset(id: UUID, size: WidgetSize) {
        defaults?.set(id.uuidString, forKey: simulatorActivePresetKey(for: size))
    }

    /// Reads back the currently active simulator preset UUID for the given size.
    static func simulatorActivePresetID(for size: WidgetSize) -> UUID? {
        guard let raw = defaults?.string(forKey: simulatorActivePresetKey(for: size)) else {
            return nil
        }
        return UUID(uuidString: raw)
    }

    private static func simulatorActivePresetKey(for size: WidgetSize) -> String {
        switch size {
        case .small:  return AppGroupConstants.simulatorActivePresetKeySmall
        case .medium: return AppGroupConstants.simulatorActivePresetKeyMedium
        case .large:  return AppGroupConstants.simulatorActivePresetKeyLarge
        }
    }
    #endif
    
    static func write(storage: StorageSnapshot) {
        defaults?.set(storage.totalBytes, forKey: AppGroupConstants.sharedStorageTotalBytesKey)
        defaults?.set(storage.availableBytes, forKey: AppGroupConstants.sharedStorageAvailableBytesKey)
    }
    
    static func write(weather: WeatherSnapshot) {
        guard let data = try? JSONEncoder().encode(weather) else { return }
        defaults?.set(data, forKey: AppGroupConstants.sharedWeatherKey)
    }

    static func write(daylight: DaylightSnapshot) {
        guard let data = try? JSONEncoder().encode(daylight) else { return }
        defaults?.set(data, forKey: AppGroupConstants.sharedDaylightKey)
    }
    
    static func write(heartRate: HeartRateSnapshot) {
        defaults?.set(heartRate.bpm, forKey: AppGroupConstants.sharedHeartRateBPMKey)
        defaults?.set(heartRate.timestamp.timeIntervalSince1970, forKey: AppGroupConstants.sharedHeartRateTimestampKey)
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
