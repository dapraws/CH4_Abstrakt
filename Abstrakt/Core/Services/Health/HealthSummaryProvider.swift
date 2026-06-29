import Foundation
import HealthKit

struct HealthSummarySnapshot: Codable, Hashable {
    let steps: Int
    let distanceKilometers: Double

    var stepsLabel: String {
        steps.formatted(.number)
    }

    var distanceLabel: String {
        let unit = DistanceUnitPreference.from(
            id: UserDefaults(suiteName: AppGroupConstants.suiteName)?.string(forKey: AppSettingsPreference.distanceUnitKey) ?? DistanceUnitPreference.kilometers.id
        )
        return unit.convertFromKilometers(distanceKilometers).formatted(.number.precision(.fractionLength(2)))
    }

    var distanceUnitName: String {
        DistanceUnitPreference.from(
            id: UserDefaults(suiteName: AppGroupConstants.suiteName)?.string(forKey: AppSettingsPreference.distanceUnitKey) ?? DistanceUnitPreference.kilometers.id
        ).noun
    }
}

final class HealthSummaryProvider {
    static let shared = HealthSummaryProvider()

    private let store = HKHealthStore()
    private var observerQueries: [HKObserverQuery] = []

    private init() {}

    func requestAuthorization() async {
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }

        let readTypes: Set<HKObjectType> = Set([
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
        ])

        try? await store.requestAuthorization(toShare: Set<HKSampleType>(), read: readTypes)
    }

    func todaySnapshot() async -> HealthSummarySnapshot {
        guard HKHealthStore.isHealthDataAvailable() else {
            return Self.placeholder
        }

        async let steps = quantitySum(for: HKQuantityType(.stepCount), unit: .count())
        async let distance = quantitySum(for: HKQuantityType(.distanceWalkingRunning), unit: .meter())

        let stepCount = Int(await steps.rounded())
        let kilometers = await distance / 1_000

        return HealthSummarySnapshot(steps: stepCount, distanceKilometers: kilometers)
    }

    func startObservingTodayMetrics(onChange: @escaping @Sendable () -> Void) {
        guard HKHealthStore.isHealthDataAvailable(), observerQueries.isEmpty else {
            return
        }

        let sampleTypes = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
        ]

        observerQueries = sampleTypes.map { sampleType in
            let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, error in
                if error == nil {
                    onChange()
                }

                completionHandler()
            }

            store.execute(query)
            store.enableBackgroundDelivery(for: sampleType, frequency: .immediate) { _, _ in }
            return query
        }
    }

    private func quantitySum(for quantityType: HKQuantityType, unit: HKUnit) async -> Double {
        await withCheckedContinuation { continuation in
            let startOfDay = Calendar.current.startOfDay(for: .now)
            let predicate = HKQuery.predicateForSamples(
                withStart: startOfDay,
                end: .now,
                options: .strictStartDate
            )

            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, statistics, _ in
                continuation.resume(returning: statistics?.sumQuantity()?.doubleValue(for: unit) ?? 0)
            }

            store.execute(query)
        }
    }

    static let placeholder = HealthSummarySnapshot(steps: 3_192, distanceKilometers: 2.14)
}
