//
//  LocationProvider.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 01/07/26.
//

import CoreLocation
import MapKit

// MARK: - Protocol

@MainActor
protocol LocationProviding {
    func currentLocation() async throws -> CLLocation
    func currentCoordinates() async throws -> CLLocationCoordinate2D
    func cityName(for location: CLLocation) async throws -> String
}

// MARK: - Provider

@MainActor
final class LocationProvider: NSObject, LocationProviding {

    // MARK: - Error

    enum LocationError: LocalizedError {
        case authorizationDenied
        case authorizationRestricted
        case locationUnavailable

        var errorDescription: String? {
            switch self {
            case .authorizationDenied:
                return "Location access was denied."
            case .authorizationRestricted:
                return "Location access is restricted."
            case .locationUnavailable:
                return "Unable to get your current location."
            }
        }
    }

    // MARK: - Properties

    private let manager = CLLocationManager()
    private var authorizationContinuation: CheckedContinuation<CLAuthorizationStatus, Never>?
    private var locationContinuation: CheckedContinuation<CLLocation, Error>?

    /// Coalesces concurrent `currentLocation()` callers into one CLLocationManager
    /// request so we never overwrite a pending continuation.
    private var inFlightLocation: Task<CLLocation, Error>?

    // MARK: - Init

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    // MARK: - LocationProviding

    func currentLocation() async throws -> CLLocation {
        // Join an in-flight request if one is already running.
        if let existing = inFlightLocation {
            return try await existing.value
        }

        switch manager.authorizationStatus {
        case .notDetermined:
            let status = await requestAuthorization()
            try validateAuthorization(status)
        case .restricted:
            throw LocationError.authorizationRestricted
        case .denied:
            throw LocationError.authorizationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            break
        @unknown default:
            throw LocationError.authorizationDenied
        }

        let task = Task<CLLocation, Error> { [weak self] in
            guard let self else { throw LocationError.locationUnavailable }
            defer { self.inFlightLocation = nil }
            return try await withCheckedThrowingContinuation { continuation in
                self.locationContinuation = continuation
                self.manager.startUpdatingLocation()
            }
        }
        inFlightLocation = task
        return try await task.value
    }

    func currentCoordinates() async throws -> CLLocationCoordinate2D {
        try await currentLocation().coordinate
    }

    func cityName(for location: CLLocation) async throws -> String {
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw LocationError.locationUnavailable
        }

        let mapItems = try await request.mapItems
        let mapItem = mapItems.first

        return mapItem?.addressRepresentations?.cityName
            ?? mapItem?.addressRepresentations?.cityWithContext(.short)
            ?? mapItem?.addressRepresentations?.regionName
            ?? mapItem?.address?.shortAddress
            ?? mapItem?.name
            ?? "Unknown"
    }

    // MARK: - Private

    private func requestAuthorization() async -> CLAuthorizationStatus {
        await withCheckedContinuation { continuation in
            authorizationContinuation = continuation
            manager.requestWhenInUseAuthorization()
        }
    }

    private func validateAuthorization(_ status: CLAuthorizationStatus) throws {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return
        case .restricted:
            throw LocationError.authorizationRestricted
        case .denied, .notDetermined:
            throw LocationError.authorizationDenied
        @unknown default:
            throw LocationError.authorizationDenied
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationProvider: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationContinuation?.resume(returning: manager.authorizationStatus)
            authorizationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.last else {
                locationContinuation?.resume(throwing: LocationError.locationUnavailable)
                locationContinuation = nil
                manager.stopUpdatingLocation()
                return
            }

            guard location.horizontalAccuracy > 0 else {
                return
            }

            locationContinuation?.resume(returning: location)
            locationContinuation = nil
            manager.stopUpdatingLocation()
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: error)
            locationContinuation = nil
            manager.stopUpdatingLocation()
        }
    }
}
