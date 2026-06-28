import Foundation

enum SharedModelContainer {
    private static let defaults = UserDefaults(suiteName: AppGroupConstants.suiteName)

    static func write(clock: ClockSnapshot, calendar: CalendarSnapshot) {
        defaults?.set(clock.timeText, forKey: AppGroupConstants.sharedClockTimeKey)
        defaults?.set(clock.dateText, forKey: AppGroupConstants.sharedClockDateKey)
        defaults?.set(calendar.headline, forKey: AppGroupConstants.sharedCalendarHeadlineKey)
        defaults?.set(calendar.detail, forKey: AppGroupConstants.sharedCalendarDetailKey)
    }

    static func write(battery: BatterySnapshot) {
        defaults?.set(battery.level, forKey: AppGroupConstants.sharedBatteryLevelKey)
        if let estimatedHoursRemaining = battery.estimatedHoursRemaining {
            defaults?.set(estimatedHoursRemaining, forKey: AppGroupConstants.sharedBatteryEstimatedHoursKey)
        } else {
            defaults?.removeObject(forKey: AppGroupConstants.sharedBatteryEstimatedHoursKey)
        }
        defaults?.set(battery.isCharging, forKey: AppGroupConstants.sharedBatteryIsChargingKey)
    }

    static func write(health: HealthSummarySnapshot) {
        defaults?.set(health.steps, forKey: AppGroupConstants.sharedHealthStepsKey)
        defaults?.set(health.distanceKilometers, forKey: AppGroupConstants.sharedHealthDistanceKilometersKey)
    }

    static func write(dashboard: DailyDashboardSnapshot) {
        defaults?.set(dashboard.temperature, forKey: AppGroupConstants.sharedWeatherTemperatureKey)
        defaults?.set(dashboard.high, forKey: AppGroupConstants.sharedWeatherHighKey)
        defaults?.set(dashboard.low, forKey: AppGroupConstants.sharedWeatherLowKey)
        defaults?.set(dashboard.weatherSymbol, forKey: AppGroupConstants.sharedWeatherSymbolKey)
    }
}
