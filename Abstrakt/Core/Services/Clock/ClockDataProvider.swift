import Foundation

struct ClockSnapshot {
    let timeText: String
    let dateText: String
    let secondaryText: String
}

enum ClockDataProvider {
    static func currentSnapshot(date: Date = .now) -> ClockSnapshot {
        let time = date.formatted(.dateTime.hour().minute())
        let dateLabel = date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        let secondary = date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))

        return ClockSnapshot(
            timeText: time,
            dateText: dateLabel,
            secondaryText: secondary
        )
    }
}
