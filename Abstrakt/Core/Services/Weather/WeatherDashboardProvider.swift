import CoreLocation
import Foundation
import WeatherKit

@MainActor
final class WeatherDashboardProvider: NSObject, CLLocationManagerDelegate {
    static let shared = WeatherDashboardProvider()

    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService.shared
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    private let denpasarLocation = CLLocation(latitude: -8.6500, longitude: 115.2167)

    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func dashboardSnapshot() async -> DailyDashboardSnapshot {
        let status = await requestLocationAuthorization()
        guard status == .authorizedAlways || status == .authorizedWhenInUse else {
            return .placeholder
        }

        guard let location = await requestCurrentLocation() else {
            return .placeholder
        }

        do {
            let weather = try await weatherService.weather(for: location)
            let current = weather.currentWeather
            let today = weather.dailyForecast.forecast.first

            return DailyDashboardSnapshot(
                date: .now,
                temperature: Int(current.temperature.converted(to: .celsius).value.rounded()),
                high: Int((today?.highTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
                low: Int((today?.lowTemperature ?? current.temperature).converted(to: .celsius).value.rounded()),
                weatherSymbol: symbol(for: current.symbolName)
            )
        } catch {
            return .placeholder
        }
    }

    func denpasarPortalSnapshot() async -> PortalWidgetSnapshot {
        do {
            let weather = try await weatherService.weather(for: denpasarLocation)
            return PortalWidgetSnapshot(
                date: .now,
                temperature: Int(weather.currentWeather.temperature.converted(to: .celsius).value.rounded()),
                placeName: "Denpasar"
            )
        } catch {
            return .placeholder
        }
    }

    private func requestLocationAuthorization() async -> CLAuthorizationStatus {
        let status = locationManager.authorizationStatus
        guard status == .notDetermined else {
            return status
        }

        return await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func requestCurrentLocation() async -> CLLocation? {
        if let location = locationManager.location,
           abs(location.timestamp.timeIntervalSinceNow) < 15 * 60 {
            return location
        }

        return await withCheckedContinuation { continuation in
            locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationContinuation?.resume(returning: manager.authorizationStatus)
            authorizationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            locationContinuation?.resume(returning: locations.last)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
        }
    }

    private func symbol(for symbolName: String) -> String {
        switch symbolName {
        case let name where name.contains("thunder"):
            "⛈"
        case let name where name.contains("rain") || name.contains("drizzle"):
            "🌧"
        case let name where name.contains("snow") || name.contains("sleet"):
            "❄️"
        case let name where name.contains("fog") || name.contains("haze"):
            "🌫"
        case let name where name.contains("cloud.sun") || name.contains("sun.cloud"):
            "🌤"
        case let name where name.contains("cloud"):
            "☁️"
        case let name where name.contains("moon"):
            "🌙"
        default:
            "☀️"
        }
    }
}
