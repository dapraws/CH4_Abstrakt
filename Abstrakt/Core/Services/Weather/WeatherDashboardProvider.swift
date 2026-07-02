import CoreLocation
import Foundation
import OSLog
import WeatherKit

// MARK: - Provider

@MainActor
final class WeatherDashboardProvider {
    static let shared = WeatherDashboardProvider()

    private let weatherService = WeatherService.shared
    private let locationProvider: any LocationProviding

    init(locationProvider: (any LocationProviding)? = nil) {
        // Default value expressions are evaluated in a nonisolated context
        // even on a @MainActor type, so LocationProvider() can't live in the
        // parameter list. Constructing it here in the body is fine because
        // the initializer body itself runs on the main actor.
        self.locationProvider = locationProvider ?? LocationProvider()
    }

    // MARK: - Snapshots

    func dashboardSnapshot() async -> DailyDashboardSnapshot {
        guard let bundle = await fetchWeatherBundle(context: "dashboardSnapshot") else {
            return .placeholder
        }

        let current = bundle.weather.currentWeather
        let today = bundle.weather.dailyForecast.forecast.first

        return DailyDashboardSnapshot(
            date: .now,
            temperature: Int(current.temperature.converted(to: .celsius).value.rounded()),
            high: Int((today?.highTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
            low: Int((today?.lowTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
            weatherSymbol: conditionInfo(for: current.condition, isDaytime: current.isDaylight).icon
        )
    }

    func portalSnapshot() async -> PortalWidgetSnapshot {
        guard let bundle = await fetchWeatherBundle(context: "portalSnapshot") else {
            return .placeholder
        }

        let placeName = (try? await locationProvider.cityName(for: bundle.location)) ?? "Here"

        return PortalWidgetSnapshot(
            date: .now,
            temperature: Int(bundle.weather.currentWeather.temperature.converted(to: .celsius).value.rounded()),
            placeName: placeName
        )
    }

    func sunEventWeatherSnapshot() async -> SunEventWeatherSnapshot {
        guard let bundle = await fetchWeatherBundle(context: "sunEventWeatherSnapshot") else {
            return .placeholder
        }

        let current = bundle.weather.currentWeather
        let today = bundle.weather.dailyForecast.forecast.first

        let now = Date.now
        let timeFormatter: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f
        }()

        // Prefer showing upcoming sunset; if it has already passed (or is nil),
        // fall back to today's sunrise time.
        let sunEventLabel: String
        let sunEventTime: String

        if let sunset = today?.sun.sunset, sunset > now {
            sunEventLabel = "Sunset"
            sunEventTime = timeFormatter.string(from: sunset)
        } else if let sunrise = today?.sun.sunrise {
            sunEventLabel = "Sunrise"
            sunEventTime = timeFormatter.string(from: sunrise)
        } else {
            sunEventLabel = "Sunrise"
            sunEventTime = "--:--"
        }

        return SunEventWeatherSnapshot(
            temperature: Int(current.temperature.converted(to: .celsius).value.rounded()),
            high: Int((today?.highTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
            low: Int((today?.lowTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
            sunEventLabel: sunEventLabel,
            sunEventTime: sunEventTime,
            sunEventIcon: sunEventLabel == "Sunset" ? "sunset" : "sunrise"
        )
    }

    func classicWeatherSnapshot() async -> ClassicWeatherSnapshot {
        guard let bundle = await fetchWeatherBundle(context: "classicWeatherSnapshot") else {
            return .placeholder
        }

        let locationName = (try? await locationProvider.cityName(for: bundle.location)) ?? "Unknown"
        let current = bundle.weather.currentWeather
        let today = bundle.weather.dailyForecast.forecast.first
        let info = conditionInfo(for: current.condition, isDaytime: current.isDaylight)

        return ClassicWeatherSnapshot(
            temperature: Int(current.temperature.converted(to: .celsius).value.rounded()),
            high: Int((today?.highTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
            low: Int((today?.lowTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
            conditionIcon: info.icon,
            conditionLabel: info.label,
            locationName: locationName
        )
    }

    // MARK: - Private

    /// Single shared fetch used by every snapshot builder so we only hit
    /// CoreLocation + WeatherKit once per call, and log failures instead of
    /// silently swallowing them.
    private struct WeatherBundle {
        let location: CLLocation
        let weather: Weather
    }

    private func fetchWeatherBundle(context: String) async -> WeatherBundle? {
        do {
            let location = try await locationProvider.currentLocation()
            print("[\(context)] location acquired: \(location.coordinate.latitude), \(location.coordinate.longitude)")
            let weather = try await weatherService.weather(for: location)
            print("[\(context)] weather fetched OK")
            return WeatherBundle(location: location, weather: weather)
        } catch {
            print("[\(context)] fetch failed: \(error)")
            return nil
        }
    }

    private func conditionInfo(
        for condition: WeatherCondition,
        isDaytime: Bool
    ) -> (icon: String, label: String) {
        let dn = isDaytime ? "day" : "night"
        switch condition {
        case .blizzard:                 return ("blizzard",                         "Blizzard")
        case .blowingDust:              return ("blowingDust-\(dn)",               "Blowing Dust")
        case .blowingSnow:              return ("flurries",                         "Blowing Snow")
        case .breezy:                   return ("windy",                            "Breezy")
        case .clear:                    return ("clear-\(dn)",                      "Clear")
        case .cloudy:                   return ("cloudy",                           "Cloudy")
        case .drizzle:                  return ("drizzle",                          "Drizzle")
        case .flurries:                 return ("flurries",                         "Flurries")
        case .foggy:                    return ("foggy-\(dn)",                      "Foggy")
        case .freezingDrizzle:          return ("freezingDrizzle",                  "Freezing Drizzle")
        case .freezingRain:             return ("freezingRain",                     "Freezing Rain")
        case .frigid:                   return ("snow",                             "Frigid")
        case .hail:                     return ("hail",                             "Hail")
        case .haze:                     return ("haze-\(dn)",                       "Haze")
        case .heavyRain:                return ("heavyRain",                        "Heavy Rain")
        case .heavySnow:                return ("heavySnow",                        "Heavy Snow")
        case .hot:                      return ("clear-day",                        "Hot")
        case .hurricane:                return ("hurricane",                        "Hurricane")
        case .isolatedThunderstorms:    return ("isolatedThunderstorms-\(dn)",      "Isolated Thunderstorms")
        case .mostlyClear:              return ("mostlyClear-\(dn)",                "Mostly Clear")
        case .mostlyCloudy:             return ("mostlyCloudy-\(dn)",               "Mostly Cloudy")
        case .partlyCloudy:             return ("partlyCloudy-\(dn)",               "Partly Cloudy")
        case .rain:                     return ("rain",                             "Rain")
        case .scatteredThunderstorms:   return ("scatteredThunderstorms-\(dn)",     "Scattered Thunderstorms")
        case .sleet:                    return ("sleet",                            "Sleet")
        case .smoky:                    return ("smoky",                            "Smoky")
        case .snow:                     return ("snow",                             "Snow")
        case .strongStorms:             return ("thunderstorms-\(dn)",              "Strong Storms")
        case .sunFlurries:              return ("flurries",                         "Sun Flurries")
        case .sunShowers:               return ("sunShowers-\(dn)",                 "Sun Showers")
        case .thunderstorms:            return ("thunderstorms-\(dn)",              "Thunderstorms")
        case .tropicalStorm:            return ("tropicalStorm",                    "Tropical Storm")
        case .windy:                    return ("windy",                            "Windy")
        case .wintryMix:                return ("rainAndSnow",                      "Wintry Mix")
        @unknown default:               return ("clear-\(dn)",                      "Unknown")
        }
    }

}

