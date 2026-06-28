import Foundation
import UIKit

struct BatterySnapshot: Codable, Hashable {
    let level: Int
    let estimatedHoursRemaining: Int?
    let isCharging: Bool

    var filledSegments: Int {
        max(0, min(5, Int(ceil(Double(level) / 20.0))))
    }

    var timeRemainingLabel: String {
        if isCharging {
            return "Charging"
        }

        guard let estimatedHoursRemaining else {
            return "Estimating"
        }

        return "- \(estimatedHoursRemaining) hours"
    }
}

enum BatteryStatusProvider {
    static func currentSnapshot() -> BatterySnapshot {
        UIDevice.current.isBatteryMonitoringEnabled = true

        let rawLevel = UIDevice.current.batteryLevel
        let level = rawLevel >= 0 ? Int((rawLevel * 100).rounded()) : 52
        let state = UIDevice.current.batteryState

        return BatterySnapshot(
            level: level,
            estimatedHoursRemaining: estimatedHoursRemaining(for: level, state: state),
            isCharging: state == .charging || state == .full
        )
    }

    private static func estimatedHoursRemaining(for level: Int, state: UIDevice.BatteryState) -> Int? {
        guard state != .charging, state != .full else {
            return nil
        }

        // iOS does not expose exact runtime remaining, so this MVP estimates from level.
        return max(1, Int(round(Double(level) / 10.0)))
    }
}
