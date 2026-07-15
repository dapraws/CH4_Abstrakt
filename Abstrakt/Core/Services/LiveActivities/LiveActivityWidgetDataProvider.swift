import Foundation

struct LiveActivityWidgetSnapshot {
    let compactWidgets: [LiveActivityWidget]
    let expandedWidgets: [LiveActivityWidget]
    let lockScreenWidgets: [LiveActivityWidget]
}

enum LiveActivityWidgetCatalog {
    static let placeholderCompactWidgets: [LiveActivityWidget] = compactWidgets(
        weather: SmartPillWeatherSnapshot(
            temperature: WeatherSnapshot.placeholder.displayTemperature,
            high: WeatherSnapshot.placeholder.displayHigh,
            low: WeatherSnapshot.placeholder.displayLow,
            conditionIcon: WeatherSnapshot.placeholder.conditionIcon,
            uvIndex: 1,
            rainChance: 30,
            sunrise: nil,
            sunset: nil,
            windDirection: "NE"
        ),
        health: HealthSummaryProvider.empty,
        activity: .previewToday,
        sleep: .placeholder,
        heartRate: .placeholder,
        battery: BatterySnapshot(level: 75, estimatedMinutesRemaining: nil, isCharging: false),
        storage: StorageSnapshot(totalBytes: 128_000_000_000, availableBytes: 69_000_000_000),
        date: .now
    )

    static let placeholderExpandedWidgets: [LiveActivityWidget] = expandedWidgets(
        health: HealthSummaryProvider.empty,
        today: .placeholder,
        activity: .previewToday,
        sleep: .placeholder,
        date: .now
    )

    static let placeholderLockScreenWidgets: [LiveActivityWidget] = lockScreenWidgets(
        health: HealthSummaryProvider.empty,
        today: .placeholder,
        activity: .previewToday,
        sleep: .placeholder,
        date: .now
    )

    static func compactWidgets(
        weather: SmartPillWeatherSnapshot,
        health: HealthSummarySnapshot,
        activity: ActivitySnapshot,
        sleep: SleepSnapshot,
        heartRate: HeartRateSnapshot,
        battery: BatterySnapshot,
        storage: StorageSnapshot,
        date: Date
    ) -> [LiveActivityWidget] {
        let calendar = Calendar.autoupdatingCurrent
        let dayText = formatted(date, format: "EEE")
        let monthText = formatted(date, format: "MMM")
        let dateText = formatted(date, format: "d")
        let monthNumberText = formatted(date, format: "M")
        let secondsText = formatted(date, format: "ss")
        let sunriseText = timeLabel(weather.sunrise, fallback: "06:00")
        let sunsetText = timeLabel(weather.sunset, fallback: "18:00")
        let windDegrees = windDegrees(for: weather.windDirection)
        let storageViewData = StorageUsageSnapshot(snapshot: storage)
        let sleepDurationParts = sleep.durationLabel.split(separator: " ", maxSplits: 1).map(String.init)

        return [
            LiveActivityWidget(id: "weather", name: "Weather", iconName: weatherSystemIcon(for: weather.conditionIcon), widgetColor: .white, layout: .largeIcon),
            LiveActivityWidget(id: "temperature-range", name: "Temperature", iconName: "thermometer", widgetColor: .red, layout: .largeTextSplit, primaryText: "\(weather.high)", secondaryText: "\(weather.low)"),
            LiveActivityWidget(id: "temperature-current", name: "Temperature", iconName: "thermometer", widgetColor: .cyan, layout: .secondsValue, primaryText: "\(weather.temperature)°"),
            LiveActivityWidget(id: "uv-index", name: "UV Index", iconName: "sun.max.fill", widgetColor: .orange, layout: .ringGauge, primaryText: "\(weather.uvIndex)", progress: min(max(Double(weather.uvIndex) / 11, 0), 1)),
            LiveActivityWidget(id: "rain-chance", name: "Rain Chance", iconName: "umbrella.fill", widgetColor: .blue, layout: .ringGauge, primaryText: "\(weather.rainChance)%", progress: min(max(Double(weather.rainChance) / 100, 0), 1)),
            LiveActivityWidget(id: "sunset", name: "Sun Event", iconName: "sunset.fill", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: sunsetText),
            LiveActivityWidget(id: "sunrise", name: "Sun Event", iconName: "sunrise.fill", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: sunriseText),
            LiveActivityWidget(id: "temp-gauge", name: "Temp Gauge", iconName: "thermometer.medium", widgetColor: .green, layout: .temperatureGauge, primaryText: "\(weather.temperature)", secondaryText: "\(weather.low) \(weather.high)", progress: normalizedTemperatureProgress(temperature: weather.temperature, low: weather.low, high: weather.high)),
            LiveActivityWidget(id: "wind-direction", name: "Wind", iconName: "wind", widgetColor: .cyan, layout: .storageStyle, primaryText: weather.windDirection),
            LiveActivityWidget(id: "wind-compass", name: "Wind", iconName: "location.north.fill", widgetColor: .blue, layout: .windCompass, primaryText: "\(Int(windDegrees.rounded()))", secondaryText: weather.windDirection, progress: windDegrees / 360),
            LiveActivityWidget(id: "battery", name: "Battery", iconName: "battery.75percent", widgetColor: .white, layout: .storageStyle, primaryText: "\(battery.level)%"),
            LiveActivityWidget(id: "storage", name: "Storage", iconName: "externaldrive.fill", widgetColor: .cyan, layout: .storageStyle, primaryText: "\(Int(storageViewData.availableFraction * 100))%"),
            LiveActivityWidget(id: "steps", name: "Steps", iconName: "figure.walk", widgetColor: .blue, layout: .textTopTextBottom, primaryText: health.stepsLabel),
            LiveActivityWidget(id: "activity", name: "Activity", iconName: "flame.fill", widgetColor: .red, layout: .caloriesStyle, primaryText: activity.activeEnergyLabel),
            LiveActivityWidget(id: "heart-rate", name: "Heart Rate", iconName: "heart.fill", widgetColor: .pink, layout: .caloriesStyle, primaryText: heartRate.bpm > 0 ? "\(heartRate.bpm)" : "--"),
            LiveActivityWidget(id: "sleep", name: "Sleep", iconName: "bed.double.fill", widgetColor: .indigo, layout: .circularProgress, primaryText: sleepDurationParts.first ?? "0H", secondaryText: sleepDurationParts.dropFirst().first ?? "", progress: Double(sleep.efficiencyPercent) / 100),
            LiveActivityWidget(id: "weekday", name: "Weekday", iconName: "calendar", widgetColor: .orange, layout: .largeTextSplit, primaryText: dayText),
            LiveActivityWidget(id: "month", name: "Month", iconName: "calendar", widgetColor: .blue, layout: .largeTextSplit, primaryText: monthText),
            LiveActivityWidget(id: "day", name: "Day", iconName: "calendar", widgetColor: .white, layout: .secondsValue, primaryText: dateText),
            LiveActivityWidget(id: "calendar-fraction", name: "Calendar", iconName: "calendar", widgetColor: .red, layout: .dateFraction, primaryText: monthNumberText, secondaryText: dateText),
            LiveActivityWidget(id: "calendar-stack", name: "Calendar", iconName: "calendar", widgetColor: .orange, layout: .calendarStack, primaryText: dayText, secondaryText: dateText),
            LiveActivityWidget(id: "second", name: "Second", iconName: "timer", widgetColor: .white, layout: .secondsValue, primaryText: secondsText),
            LiveActivityWidget(id: "clock", name: "Clock", iconName: "clock", widgetColor: .white, layout: .analogClock),
            LiveActivityWidget(id: "clock-minimal", name: "Clock", iconName: "clock", widgetColor: .orange, layout: .stopwatchDial, progress: Double(calendar.component(.second, from: date)) / 60),
            LiveActivityWidget(id: "stopwatch", name: "Stopwatch", iconName: "stopwatch", widgetColor: .orange, layout: .stopwatchDial, primaryText: formatted(date, format: "mm"), secondaryText: formatted(date, format: "ss"), progress: Double(calendar.component(.second, from: date)) / 60)
        ].map { $0.available(on: .smartPills) }
    }

    static func expandedWidgets(
        health: HealthSummarySnapshot,
        today: TodaySnapshot,
        activity: ActivitySnapshot,
        sleep: SleepSnapshot,
        date: Date
    ) -> [LiveActivityWidget] {
        let metadata = expandedMetadata(
            health: health,
            today: today,
            activity: activity,
            sleep: sleep,
            date: date
        )

        return [
            LiveActivityWidget(id: "today-info", name: "Today Info", iconName: "figure.walk", widgetColor: .white, layout: .todayInfo, primaryText: formatted(date, format: "EEEE"), secondaryText: formatted(date, format: "MMM d"), metadata: metadata),
            LiveActivityWidget(id: "calendar-info", name: "Calendar Info", iconName: "calendar", widgetColor: .white, layout: .calendarInfo, metadata: metadata),
            LiveActivityWidget(id: "weather-summary", name: "Weather Info", iconName: today.conditionSystemImageName, widgetColor: .white, layout: .weatherInfo, primaryText: today.shortConditionLabel, secondaryText: "\(today.displayLow)-\(today.displayHigh)°", metadata: metadata)
        ].map { $0.available(on: .expanded) }
    }

    static func lockScreenWidgets(
        health: HealthSummarySnapshot,
        today: TodaySnapshot,
        activity: ActivitySnapshot,
        sleep: SleepSnapshot,
        date: Date
    ) -> [LiveActivityWidget] {
        let metadata = expandedMetadata(
            health: health,
            today: today,
            activity: activity,
            sleep: sleep,
            date: date
        )

        return [
            LiveActivityWidget(id: "today-info", name: "Today Info", iconName: "figure.walk", widgetColor: .white, layout: .todayInfo, primaryText: formatted(date, format: "EEEE"), secondaryText: formatted(date, format: "MMM d"), metadata: metadata),
            LiveActivityWidget(id: "calendar-info", name: "Calendar Info", iconName: "calendar", widgetColor: .white, layout: .calendarInfo, metadata: metadata),
            LiveActivityWidget(id: "weather-summary", name: "Weather Info", iconName: today.conditionSystemImageName, widgetColor: .white, layout: .weatherInfo, primaryText: today.shortConditionLabel, secondaryText: "\(today.displayLow)-\(today.displayHigh)°", metadata: metadata)
        ].map { $0.available(on: .liveActivity) }
    }

    private static func expandedMetadata(
        health: HealthSummarySnapshot,
        today: TodaySnapshot,
        activity: ActivitySnapshot,
        sleep: SleepSnapshot,
        date: Date
    ) -> [String: String] {
        let todayPercent = percent(health.steps, target: 10_000)
        let weekPercent = percent(activity.exerciseMinutes, target: 150)
        let sleepPercent = min(max(sleep.efficiencyPercent, 0), 100)
        let movePercent = percent(activity.activeEnergyCalories, target: 600)

        return [
            "todayPercent": "\(todayPercent)%",
            "weekPercent": "\(weekPercent)%",
            "sleepPercent": "\(sleepPercent)%",
            "movePercent": "\(movePercent)%",
            "weatherIcon": today.conditionSystemImageName,
            "conditionLabel": today.shortConditionLabel,
            "currentTemperature": "\(today.displayTemperature)°",
            "highTemperature": "\(today.displayHigh)°",
            "lowTemperature": "\(today.displayLow)°",
            "temperatureRange": "\(today.displayLow)-\(today.displayHigh)°",
            "stepsLabel": health.stepsLabel,
            "referenceDate": "\(date.timeIntervalSince1970)",
        ]
    }

    private static func weatherSystemIcon(for weatherIcon: String) -> String {
        if weatherIcon.hasPrefix("clear") {
            return weatherIcon.contains("night") ? "moon.stars.fill" : "sun.max.fill"
        }

        if weatherIcon.contains("partlyCloudy") || weatherIcon.contains("mostlyClear") {
            return weatherIcon.contains("night") ? "cloud.moon.fill" : "cloud.sun.fill"
        }

        if weatherIcon.contains("mostlyCloudy") || weatherIcon == "cloudy" {
            return "cloud.fill"
        }

        if weatherIcon.contains("thunderstorms") || weatherIcon.contains("strongStorms") {
            return "cloud.bolt.rain.fill"
        }

        if weatherIcon.contains("rain") || weatherIcon.contains("drizzle") || weatherIcon.contains("sunShowers") {
            return "cloud.rain.fill"
        }

        if weatherIcon.contains("snow") || weatherIcon.contains("flurries") || weatherIcon.contains("sleet") || weatherIcon.contains("rainAndSnow") {
            return "cloud.snow.fill"
        }

        if weatherIcon.contains("foggy") || weatherIcon.contains("haze") || weatherIcon.contains("smoky") || weatherIcon.contains("blowingDust") {
            return "cloud.fog.fill"
        }

        if weatherIcon.contains("windy") {
            return "wind"
        }

        return "cloud.sun.fill"
    }

    private static func percent(_ value: Int, target: Int) -> Int {
        guard target > 0 else { return 0 }
        return min(max(Int((Double(value) / Double(target) * 100).rounded()), 0), 100)
    }

    private static func formatted(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }

    private static func timeLabel(_ date: Date?, fallback: String) -> String {
        guard let date else { return fallback }
        return formatted(date, format: "HH:mm")
    }

    private static func normalizedTemperatureProgress(temperature: Int, low: Int, high: Int) -> Double {
        guard high > low else { return 0.5 }
        return min(max(Double(temperature - low) / Double(high - low), 0), 1)
    }

    private static func windDegrees(for direction: String) -> Double {
        switch direction.uppercased() {
        case "N": return 0
        case "NNE": return 22.5
        case "NE": return 45
        case "ENE": return 67.5
        case "E": return 90
        case "ESE": return 112.5
        case "SE": return 135
        case "SSE": return 157.5
        case "S": return 180
        case "SSW": return 202.5
        case "SW": return 225
        case "WSW": return 247.5
        case "W": return 270
        case "WNW": return 292.5
        case "NW": return 315
        case "NNW": return 337.5
        default: return 45
        }
    }
}

@MainActor
enum LiveActivityWidgetDataProvider {
    static func currentSnapshot(date: Date = .now) async -> LiveActivityWidgetSnapshot {
        async let weather = WeatherProvider.shared.smartPillSnapshot()
        async let today = WeatherProvider.shared.todaySnapshot()
        async let health = HealthSummaryProvider.shared.todaySnapshot()
        async let activities = HealthSummaryProvider.shared.activitySnapshots()
        async let sleep = HealthSummaryProvider.shared.sleepSnapshot()
        async let heartRate = HealthSummaryProvider.shared.latestHeartRate()

        let battery = BatteryStatusProvider.currentSnapshot()
        let storage = StorageProvider.currentSnapshot()
        let resolvedWeather = await weather
        let resolvedToday = await today
        let resolvedHealth = await health
        let resolvedActivities = await activities
        let resolvedSleep = await sleep
        let resolvedHeartRate = await heartRate
        let activity = resolvedActivities[.today] ?? HealthSummaryProvider.emptyActivity(mode: .today)

        return LiveActivityWidgetSnapshot(
            compactWidgets: LiveActivityWidgetCatalog.compactWidgets(
                weather: resolvedWeather,
                health: resolvedHealth,
                activity: activity,
                sleep: resolvedSleep,
                heartRate: resolvedHeartRate,
                battery: battery,
                storage: storage,
                date: date
            ),
            expandedWidgets: LiveActivityWidgetCatalog.expandedWidgets(
                health: resolvedHealth,
                today: resolvedToday,
                activity: activity,
                sleep: resolvedSleep,
                date: date
            ),
            lockScreenWidgets: LiveActivityWidgetCatalog.lockScreenWidgets(
                health: resolvedHealth,
                today: resolvedToday,
                activity: activity,
                sleep: resolvedSleep,
                date: date
            )
        )
    }
}
