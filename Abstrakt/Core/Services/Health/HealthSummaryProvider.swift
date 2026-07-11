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
            id: AppGroupConstants.sharedDefaults?.string(forKey: AppSettingsPreference.distanceUnitKey) ?? DistanceUnitPreference.kilometers.id
        )
        return unit.convertFromKilometers(distanceKilometers).formatted(.number.precision(.fractionLength(2)))
    }

    var distanceUnitName: String {
        DistanceUnitPreference.from(
            id: AppGroupConstants.sharedDefaults?.string(forKey: AppSettingsPreference.distanceUnitKey) ?? DistanceUnitPreference.kilometers.id
        ).noun
    }
}

struct HeartRateSnapshot: Codable, Hashable {
    let bpm: Int
    let timestamp: Date

    static let placeholder = HeartRateSnapshot(bpm: 0, timestamp: .now)
}

private struct SleepSession {
    let anchorDate: Date
    let bedtime: Date
    let asleepDuration: TimeInterval
    let inBedDuration: TimeInterval
}

final class HealthSummaryProvider {
    static let shared = HealthSummaryProvider()

    private static let authorizationRequestedKey = "health.authorization.requested"

    private let store = HKHealthStore()
    private var observerQueries: [HKObserverQuery] = []
    private var hasRequestedAuthorization = false

    private init() {}

    func authorizationState() -> HealthPermissionState {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .unavailable
        }

        let requested = AppGroupConstants.sharedDefaults?
            .bool(forKey: Self.authorizationRequestedKey) ?? false
        return requested ? .requested : .notDetermined
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        guard HKHealthStore.isHealthDataAvailable() else {
            return false
        }

        let readTypes: Set<HKObjectType> = Set([
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.activeEnergyBurned),
            HKCategoryType(.sleepAnalysis),
            HKQuantityType(.heartRate),
        ])

        do {
            try await store.requestAuthorization(toShare: Set<HKSampleType>(), read: readTypes)
            AppGroupConstants.sharedDefaults?
                .set(true, forKey: Self.authorizationRequestedKey)
            return true
        } catch {
            return false
        }
    }

    func todaySnapshot() async -> HealthSummarySnapshot {
        guard HKHealthStore.isHealthDataAvailable() else {
            return Self.empty
        }

        guard !Task.isCancelled else { return Self.empty }

        async let steps = quantitySum(for: HKQuantityType(.stepCount), unit: .count())
        async let distance = quantitySum(for: HKQuantityType(.distanceWalkingRunning), unit: .meter())

        guard !Task.isCancelled else { return Self.empty }

        let stepCount = Int(await steps.rounded())
        let kilometers = await distance / 1_000

        return HealthSummarySnapshot(steps: stepCount, distanceKilometers: kilometers)
    }

    func activitySnapshots() async -> [ActivityMode: ActivitySnapshot] {
        guard HKHealthStore.isHealthDataAvailable() else {
            return [
                .today: Self.emptyActivity(mode: .today),
                .weekly: Self.emptyActivity(mode: .weekly),
            ]
        }

        guard !Task.isCancelled else {
            return [
                .today: Self.emptyActivity(mode: .today),
                .weekly: Self.emptyActivity(mode: .weekly),
            ]
        }

        async let today = activitySnapshot(mode: .today)
        async let weekly = activitySnapshot(mode: .weekly)

        return [
            .today: await today,
            .weekly: await weekly,
        ]
    }

    func sleepSnapshot() async -> SleepSnapshot {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .permissionNeeded
        }

        let end = Date.now
        let start = Calendar.current.date(byAdding: .day, value: -21, to: end) ?? end
        let interval = DateInterval(start: start, end: end)
        let sessions = await sleepSessions(interval: interval)
            .sorted { $0.anchorDate > $1.anchorDate }
            .filter { $0.asleepDuration > 0 }

        guard !sessions.isEmpty else {
            return .empty
        }

        let samples = Array(sessions.prefix(7))
        let bedtimeValues = samples.map(\.bedtime).map(Self.bedtimeMinuteValue)
        let averageBedtime = Int((Double(bedtimeValues.reduce(0, +)) / Double(bedtimeValues.count)).rounded()) % (24 * 60)
        let averageSleepMinutes = Int(
            (
                samples.map(\.asleepDuration).reduce(0, +)
                / Double(max(samples.count, 1))
                / 60
            ).rounded()
        )
        let averageEfficiency = Int(
            (
                samples.map { session in
                    let denominator = max(max(session.inBedDuration, session.asleepDuration), 1)
                    return session.asleepDuration / denominator
                }
                .reduce(0, +)
                / Double(max(samples.count, 1))
                * 100
            ).rounded()
        )

        return SleepSnapshot(
            date: end,
            accessAuthorized: true,
            targetBedtimeMinutes: averageBedtime,
            recommendedSleepMinutes: averageSleepMinutes,
            efficiencyPercent: averageEfficiency
        )
    }

    func startObservingTodayMetrics(onChange: @escaping @Sendable () -> Void) {
        guard HKHealthStore.isHealthDataAvailable(), observerQueries.isEmpty else {
            return
        }

        let sampleTypes = [
            HKQuantityType(.stepCount),
            HKQuantityType(.distanceWalkingRunning),
            HKQuantityType(.appleExerciseTime),
            HKQuantityType(.activeEnergyBurned),
            HKCategoryType(.sleepAnalysis),
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
    
    func latestHeartRate() async -> HeartRateSnapshot {
        guard HKHealthStore.isHealthDataAvailable() else {
            return .placeholder
        }

        guard !Task.isCancelled else { return .placeholder }

        return await withCheckedContinuation { continuation in
            let heartRateType = HKQuantityType(.heartRate)
            let sortDescriptor = NSSortDescriptor(
                key: HKSampleSortIdentifierEndDate,
                ascending: false
            )

            let query = HKSampleQuery(
                sampleType: heartRateType,
                predicate: nil,
                limit: 1,
                sortDescriptors: [sortDescriptor]
            ) { _, samples, _ in
                guard let sample = samples?.first as? HKQuantitySample else {
                    continuation.resume(returning: .placeholder)
                    return
                }

                let bpm = Int(sample.quantity.doubleValue(
                    for: HKUnit.count().unitDivided(by: .minute())
                ).rounded())

                continuation.resume(returning: HeartRateSnapshot(
                    bpm: bpm,
                    timestamp: sample.endDate
                ))
            }

            store.execute(query)
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

    private func activitySnapshot(mode: ActivityMode) async -> ActivitySnapshot {
        let interval = dateInterval(for: mode)

        async let exerciseMinutes = quantitySum(
            for: HKQuantityType(.appleExerciseTime),
            unit: .minute(),
            interval: interval
        )
        async let activeEnergy = quantitySum(
            for: HKQuantityType(.activeEnergyBurned),
            unit: .kilocalorie(),
            interval: interval
        )
        async let sleepMinutes = sleepMinutes(interval: interval)

        return ActivitySnapshot(
            mode: mode,
            exerciseMinutes: Int(await exerciseMinutes.rounded()),
            activeEnergyCalories: Int(await activeEnergy.rounded()),
            sleepMinutes: await sleepMinutes
        )
    }

    private func dateInterval(for mode: ActivityMode) -> DateInterval {
        let calendar = Calendar.current
        let end = Date.now

        switch mode {
        case .today:
            return DateInterval(start: calendar.startOfDay(for: end), end: end)
        case .weekly:
            let todayStart = calendar.startOfDay(for: end)
            let start = calendar.date(byAdding: .day, value: -6, to: todayStart) ?? todayStart
            return DateInterval(start: start, end: end)
        }
    }

    private func quantitySum(for quantityType: HKQuantityType, unit: HKUnit, interval: DateInterval) async -> Double {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: interval.start,
                end: interval.end,
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

    private func averageQuantity(for quantityType: HKQuantityType, unit: HKUnit, interval: DateInterval) async -> Double {
        await withCheckedContinuation { continuation in
            let predicate = HKQuery.predicateForSamples(
                withStart: interval.start,
                end: interval.end,
                options: .strictStartDate
            )

            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, statistics, _ in
                continuation.resume(returning: statistics?.averageQuantity()?.doubleValue(for: unit) ?? 0)
            }

            store.execute(query)
        }
    }

    private func sleepMinutes(interval: DateInterval) async -> Int {
        await withCheckedContinuation { continuation in
            let sampleType = HKCategoryType(.sleepAnalysis)
            let predicate = HKQuery.predicateForSamples(
                withStart: interval.start,
                end: interval.end,
                options: []
            )

            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                let total = samples?
                    .compactMap { $0 as? HKCategorySample }
                    .filter { Self.isAsleepValue($0.value) }
                    .reduce(0.0) { partial, sample in
                        let overlapStart = max(sample.startDate, interval.start)
                        let overlapEnd = min(sample.endDate, interval.end)
                        return partial + max(0, overlapEnd.timeIntervalSince(overlapStart))
                    } ?? 0

                continuation.resume(returning: Int((total / 60).rounded()))
            }

            store.execute(query)
        }
    }

    private func sleepSessions(interval: DateInterval) async -> [SleepSession] {
        let samples = await sleepCategorySamples(interval: interval)
        let grouped = Dictionary(grouping: samples) { sample in
            Self.sleepAnchorDate(for: sample.startDate)
        }

        return grouped.compactMap { anchorDate, samples in
            let bedIntervals = samples.map {
                DateInterval(start: max($0.startDate, interval.start), end: min($0.endDate, interval.end))
            }
            let asleepIntervals = samples
                .filter { Self.isAsleepValue($0.value) }
                .map { DateInterval(start: max($0.startDate, interval.start), end: min($0.endDate, interval.end)) }

            let mergedBedIntervals = Self.mergedIntervals(from: bedIntervals)
            let mergedAsleepIntervals = Self.mergedIntervals(from: asleepIntervals)
            let asleepDuration = mergedAsleepIntervals.reduce(0.0) { $0 + $1.duration }
            let inBedDuration = mergedBedIntervals.reduce(0.0) { $0 + $1.duration }

            guard
                let bedtime = mergedBedIntervals.first?.start ?? mergedAsleepIntervals.first?.start,
                asleepDuration > 0
            else {
                return nil
            }

            return SleepSession(
                anchorDate: anchorDate,
                bedtime: bedtime,
                asleepDuration: asleepDuration,
                inBedDuration: max(inBedDuration, asleepDuration)
            )
        }
    }

    private func sleepCategorySamples(interval: DateInterval) async -> [HKCategorySample] {
        await withCheckedContinuation { continuation in
            let sampleType = HKCategoryType(.sleepAnalysis)
            let predicate = HKQuery.predicateForSamples(
                withStart: interval.start,
                end: interval.end,
                options: []
            )

            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
            ) { _, samples, _ in
                continuation.resume(
                    returning: samples?.compactMap { $0 as? HKCategorySample } ?? []
                )
            }

            store.execute(query)
        }
    }

    private static func isAsleepValue(_ value: Int) -> Bool {
        value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
            value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
            value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
            value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
    }

    private static func sleepAnchorDate(for date: Date) -> Date {
        let calendar = Calendar.current
        let shiftedDate = calendar.date(byAdding: .hour, value: -12, to: date) ?? date
        return calendar.startOfDay(for: shiftedDate)
    }

    private static func bedtimeMinuteValue(for date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        let total = hour * 60 + minute
        return hour < 12 ? total + (24 * 60) : total
    }

    private static func mergedIntervals(from intervals: [DateInterval]) -> [DateInterval] {
        let sortedIntervals = intervals
            .filter { $0.duration > 0 }
            .sorted { $0.start < $1.start }

        guard var current = sortedIntervals.first else {
            return []
        }

        var merged: [DateInterval] = []

        for interval in sortedIntervals.dropFirst() {
            if interval.start <= current.end {
                current = DateInterval(start: current.start, end: max(current.end, interval.end))
            } else {
                merged.append(current)
                current = interval
            }
        }

        merged.append(current)
        return merged
    }

    static let empty = HealthSummarySnapshot(steps: 0, distanceKilometers: 0)

    static func emptyActivity(mode: ActivityMode) -> ActivitySnapshot {
        ActivitySnapshot(mode: mode, exerciseMinutes: 0, activeEnergyCalories: 0, sleepMinutes: 0)
    }
}

enum HealthPermissionState {
    case requested
    case notDetermined
    case unavailable
}
