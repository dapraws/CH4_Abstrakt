import Foundation

enum TemperatureUnitPreference: String, CaseIterable, Identifiable {
    case celsius
    case fahrenheit

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .celsius:
            "Celsius"
        case .fahrenheit:
            "Fahrenheit"
        }
    }

    var symbol: String {
        switch self {
        case .celsius:
            "C"
        case .fahrenheit:
            "F"
        }
    }

    static func from(id: String) -> TemperatureUnitPreference {
        Self(rawValue: id) ?? .celsius
    }

    func convertFromCelsius(_ value: Int) -> Int {
        switch self {
        case .celsius:
            value
        case .fahrenheit:
            Int((Double(value) * 9.0 / 5.0 + 32.0).rounded())
        }
    }
}

enum TemperatureDisplayPreference: String, CaseIterable, Identifiable {
    case actual
    case feelsLike

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .actual:
            "Actual"
        case .feelsLike:
            "Feels Like"
        }
    }

    static func from(id: String) -> TemperatureDisplayPreference {
        Self(rawValue: id) ?? .actual
    }
}

enum DistanceUnitPreference: String, CaseIterable, Identifiable {
    case kilometers
    case miles

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .kilometers:
            "Kilometers"
        case .miles:
            "Miles"
        }
    }

    var noun: String {
        switch self {
        case .kilometers:
            "kilometers"
        case .miles:
            "miles"
        }
    }

    static func from(id: String) -> DistanceUnitPreference {
        Self(rawValue: id) ?? .kilometers
    }

    func convertFromKilometers(_ value: Double) -> Double {
        switch self {
        case .kilometers:
            value
        case .miles:
            value * 0.621371
        }
    }
}

enum AppSettingsPreference {
    static let temperatureUnitKey = "settings.temperatureUnit"
    static let temperatureDisplayKey = "settings.temperatureDisplay"
    static let distanceUnitKey = "settings.distanceUnit"
}
