import Foundation
import HealthKit

struct HealthSummarySnapshot: Codable, Hashable {
    let steps: Int
    let distanceKilometers: Double

    var stepsLabel: String {
        steps.formatted(.number)
    }

    var distanceLabel: String {
        distanceKilometers.formatted(.number.precision(.fractionLength(2)))
    }
}

final class HealthSummaryProvider {
    static let shared = HealthSummaryProvider()

    private let store = HKHealthStore()

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

        if stepCount == 0, kilometers == 0 {
            return Self.placeholder
        }

        return HealthSummarySnapshot(steps: stepCount, distanceKilometers: kilometers)
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
