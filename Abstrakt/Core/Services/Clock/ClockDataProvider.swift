import Foundation

enum ClockDataProvider {
    static func currentSnapshot(date: Date = .now) -> ClockSnapshot {
        ClockSnapshot(date: date)
    }
}
