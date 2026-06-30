import Foundation

enum SharedModelContainer {
    private static let defaults = UserDefaults(suiteName: AppGroupConstants.suiteName)

    static func write(clock: ClockSnapshot, calendar: CalendarSnapshot) {
        defaults?.set(clock.timeText, forKey: AppGroupConstants.sharedClockTimeKey)
        defaults?.set(clock.dateText, forKey: AppGroupConstants.sharedClockDateKey)
        defaults?.set(calendar.headline, forKey: AppGroupConstants.sharedCalendarHeadlineKey)
        defaults?.set(calendar.detail, forKey: AppGroupConstants.sharedCalendarDetailKey)
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

    static func write(dashboard: DailyDashboardSnapshot) {
        defaults?.set(dashboard.temperature, forKey: AppGroupConstants.sharedWeatherTemperatureKey)
        defaults?.set(dashboard.high, forKey: AppGroupConstants.sharedWeatherHighKey)
        defaults?.set(dashboard.low, forKey: AppGroupConstants.sharedWeatherLowKey)
        defaults?.set(dashboard.weatherSymbol, forKey: AppGroupConstants.sharedWeatherSymbolKey)
        defaults?.synchronize()
    }

    static func write(portal: PortalWidgetSnapshot) {
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
}
