import Foundation

enum WidgetSharedStore {
    private static let suiteName = "group.msaf.abstrakt"

    private static let defaults = UserDefaults(suiteName: suiteName)

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

    static var batteryEntry: BatteryWidgetEntry {
        let level = defaults?.integer(forKey: "shared.battery.level") ?? 52
        let estimated = defaults?.object(forKey: "shared.battery.estimatedHours") as? Int
        let isCharging = defaults?.bool(forKey: "shared.battery.isCharging") ?? false

        return BatteryWidgetEntry(
            date: .now,
            level: level == 0 ? 52 : level,
            estimatedHoursRemaining: estimated ?? 5,
            isCharging: isCharging
        )
    }

    static var healthEntry: StepWidgetEntry {
        StepWidgetEntry(
            date: .now,
            steps: defaults?.object(forKey: "shared.health.steps") as? Int ?? 3_192,
            distanceKilometers: defaults?.object(forKey: "shared.health.distanceKilometers") as? Double ?? 2.14
        )
    }

    static var dashboardEntry: DashboardWidgetEntry {
        DashboardWidgetEntry(
            date: .now,
            temperature: defaults?.object(forKey: "shared.weather.temperature") as? Int ?? 25,
            high: defaults?.object(forKey: "shared.weather.high") as? Int ?? 30,
            low: defaults?.object(forKey: "shared.weather.low") as? Int ?? 24,
            weatherSymbol: defaults?.string(forKey: "shared.weather.symbol") ?? "🌥️"
        )
    }
}
