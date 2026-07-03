import EventKit
import Foundation

struct CalendarSnapshot {
    let headline: String
    let detail: String
    let eventSnapshot: EventsSnapshot
}

enum EventKitProvider {
    private static let store = EKEventStore()

    static func currentSnapshot(date: Date = .now) async -> CalendarSnapshot {
        let headline = date.formatted(.dateTime.weekday(.wide))

        guard await hasCalendarAccess() else {
            return CalendarSnapshot(
                headline: headline,
                detail: "Calendar access needed",
                eventSnapshot: EventsSnapshot(
                    date: date,
                    accessState: .permissionNeeded
                )
            )
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        let predicate = store.predicateForEvents(
            withStart: startOfDay,
            end: endOfDay,
            calendars: store.calendars(for: .event)
        )

        let upcomingEvents = store.events(matching: predicate)
            .filter { !$0.isAllDay }
            .filter { $0.endDate > date }
            .sorted { $0.startDate < $1.startDate }
        let eventSummaries = upcomingEvents.map { event in
            EventSummary(
                id: event.eventIdentifier ?? "\(event.calendarItemIdentifier)-\(event.startDate.timeIntervalSince1970)",
                title: event.title ?? "Untitled Event",
                startDate: event.startDate,
                endDate: event.endDate
            )
        }

        guard let event = upcomingEvents.first else {
            return CalendarSnapshot(
                headline: headline,
                detail: "No events today",
                eventSnapshot: EventsSnapshot(
                    date: date,
                    accessState: .empty
                )
            )
        }

        let time = event.startDate.formatted(.dateTime.hour().minute())
        return CalendarSnapshot(
            headline: headline,
            detail: "\(time) \(event.title ?? "Untitled Event")",
            eventSnapshot: EventsSnapshot(
                date: date,
                accessState: .available,
                events: eventSummaries
            )
        )
    }

    static func authorizationState() -> CalendarPermissionState {
        let status = EKEventStore.authorizationStatus(for: .event)

        if #available(iOS 17.0, *) {
            switch status {
            case .fullAccess:
                return .authorized
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .denied
            case .writeOnly:
                return .limited
            default:
                return .denied
            }
        } else {
            switch status {
            case .authorized:
                return .authorized
            case .notDetermined:
                return .notDetermined
            case .restricted:
                return .restricted
            case .denied:
                return .denied
            default:
                return .denied
            }
        }
    }

    static func requestCalendarAccess() async -> Bool {
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

    private static func hasCalendarAccess() async -> Bool {
        switch authorizationState() {
        case .authorized:
            return true
        case .notDetermined:
            return await requestCalendarAccess()
        case .denied, .restricted, .limited:
            return false
        }
    }
}

enum CalendarPermissionState {
    case authorized
    case notDetermined
    case denied
    case restricted
    case limited
}
