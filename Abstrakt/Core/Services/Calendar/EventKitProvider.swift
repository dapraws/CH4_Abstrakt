import Foundation

struct CalendarSnapshot {
    let headline: String
    let detail: String
}

enum EventKitProvider {
    static func placeholderSnapshot(date: Date = .now) -> CalendarSnapshot {
        CalendarSnapshot(
            headline: date.formatted(.dateTime.weekday(.wide)),
            detail: "No connected events yet"
        )
    }
}
