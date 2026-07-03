import EventKit
import Foundation

struct CalendarSnapshot {
    let headline: String
    let detail: String
}

enum EventKitProvider {
    private static let store = EKEventStore()

    static func currentSnapshot(date: Date = .now) async -> CalendarSnapshot {
        let headline = date.formatted(.dateTime.weekday(.wide))

        guard await hasCalendarAccess() else {
            return CalendarSnapshot(
                headline: headline,
                detail: "Calendar access needed"
            )
        }

        let calendar = Calendar.current
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date
        let predicate = store.predicateForEvents(
            withStart: date,
            end: endOfDay,
            calendars: store.calendars(for: .event)
        )

        let upcomingEvents = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .sorted { $0.startDate < $1.startDate }

        guard let nextEvent = upcomingEvents.first else {
            return CalendarSnapshot(
                headline: headline,
                detail: "No events today"
            )
        }

        let time = nextEvent.startDate.formatted(.dateTime.hour().minute())
        return CalendarSnapshot(
            headline: headline,
            detail: "\(time) \(nextEvent.title ?? "Untitled Event")"
        )
    }

    private static func hasCalendarAccess() async -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess:
                return true
            case .notDetermined:
                return await requestCalendarAccess()
            default:
                return false
            }
        } else {
            switch status {
            case .authorized:
                return true
            case .notDetermined:
                return await requestCalendarAccess()
            default:
                return false
            }
        }
    }

    private static func requestCalendarAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                store.requestFullAccessToEvents { granted, _ in
                    continuation.resume(returning: granted)
                }
            } else {
                store.requestAccess(to: .event) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
}
