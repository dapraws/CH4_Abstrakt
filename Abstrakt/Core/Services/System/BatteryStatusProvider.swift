import Foundation
import UIKit

struct BatterySnapshot: Codable, Hashable {
    let level: Int
    let estimatedMinutesRemaining: Int?
    let isCharging: Bool

    var normalizedLevel: Double {
        Double(max(0, min(100, level))) / 100.0
    }

    func barFillFraction(at index: Int) -> Double {
        min(max((normalizedLevel * 5.0) - Double(index), 0), 1)
    }

    var timeRemainingLabel: String {
        if isCharging {
            return "Charging"
        }

        guard let estimatedMinutesRemaining else {
            return "Estimating"
        }

        return "\(Self.durationLabel(for: estimatedMinutesRemaining))"
    }

    static func durationLabel(for minutes: Int) -> String {
        let clampedMinutes = max(0, minutes)
        let hours = clampedMinutes / 60
        let remainingMinutes = clampedMinutes % 60

        switch (hours, remainingMinutes) {
        case (0, 0):
            return "< 1 min"
        case (0, _):
            return "\(remainingMinutes)m"
        case (_, 0):
            return "\(hours)h"
        default:
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}

enum BatteryStatusProvider {
    static func currentSnapshot() -> BatterySnapshot {
        UIDevice.current.isBatteryMonitoringEnabled = true

        let rawLevel = UIDevice.current.batteryLevel
        let level = rawLevel >= 0 ? Int((rawLevel * 100).rounded()) : 0
        let state = UIDevice.current.batteryState

        return BatterySnapshot(
            level: level,
            estimatedMinutesRemaining: estimatedMinutesRemaining(for: level, state: state),
            isCharging: state == .charging || state == .full
        )
    }

    private static func estimatedMinutesRemaining(for level: Int, state: UIDevice.BatteryState) -> Int? {
        guard state != .charging, state != .full else {
            return nil
        }

        // iOS does not expose exact runtime remaining, so this estimates from a 10-hour full charge.
        return max(0, Int(round(Double(max(0, min(100, level))) * 6.0)))
    }
}
