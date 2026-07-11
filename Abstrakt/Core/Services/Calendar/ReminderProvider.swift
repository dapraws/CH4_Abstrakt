import EventKit
import Foundation

typealias ReminderPermissionState = CalendarPermissionState

enum ReminderProvider {
    private static let store = EKEventStore()

    static func currentSnapshot(date: Date = .now) async -> ReminderSnapshot {
        guard await hasReminderAccess() else {
            return ReminderSnapshot(
                date: date,
                accessState: .permissionNeeded
            )
        }

        let calendar = Calendar.autoupdatingCurrent
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        let selectedList = selectedReminderList()

        async let incomplete = fetchIncompleteReminders(
            calendarIdentifier: selectedList?.id
        )
        async let completed = fetchCompletedReminders(
            starting: startOfDay,
            ending: endOfDay,
            calendarIdentifier: selectedList?.id
        )

        let mergedItems = mergeDisplayItems(
            incomplete: await incomplete,
            completed: await completed
        )

        guard !mergedItems.items.isEmpty else {
            return ReminderSnapshot(
                date: date,
                accessState: .empty
            )
        }

        return ReminderSnapshot(
            date: date,
            accessState: .available,
            selectedList: selectedList,
            items: mergedItems.items,
            remainingItemCount: mergedItems.remainingItemCount
        )
    }

    static func availableReminderLists(limit: Int = 40) async -> [ReminderListSummary] {
        guard await hasReminderAccess() else {
            return []
        }

        return store.calendars(for: .reminder)
            .filter { calendar in
                calendar.allowsContentModifications || calendar.type == .local || calendar.type == .calDAV
            }
            .prefix(limit)
            .map {
                ReminderListSummary(
                    id: $0.calendarIdentifier,
                    title: $0.title,
                    subtitle: reminderListSubtitle(for: $0)
                )
            }
    }

    static func authorizationState() -> ReminderPermissionState {
        let status = EKEventStore.authorizationStatus(for: .reminder)

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

    static func requestReminderAccess() async -> Bool {
        await withCheckedContinuation { continuation in
            if #available(iOS 17.0, *) {
                store.requestFullAccessToReminders { granted, _ in
                    continuation.resume(returning: granted)
                }
            } else {
                store.requestAccess(to: .reminder) { granted, _ in
                    continuation.resume(returning: granted)
                }
            }
        }
    }

    private static func hasReminderAccess() async -> Bool {
        switch authorizationState() {
        case .authorized:
            return true
        case .notDetermined:
            return await requestReminderAccess()
        case .denied, .restricted, .limited:
            return false
        }
    }

    private static func fetchIncompleteReminders(
        calendarIdentifier: String? = nil
    ) async -> [ReminderSummary] {
        let calendars = calendarsMatching(identifier: calendarIdentifier)
        let predicate = store.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: calendars
        )

        let reminders = await fetchReminders(matching: predicate)
            .filter { !($0.title ?? "").isEmpty || !$0.isCompleted }
            .sorted(by: incompleteReminderSort)

        return reminders.map(reminderSummary)
    }

    private static func fetchCompletedReminders(
        starting: Date,
        ending: Date,
        calendarIdentifier: String? = nil
    ) async -> [ReminderSummary] {
        let calendars = calendarsMatching(identifier: calendarIdentifier)
        let predicate = store.predicateForCompletedReminders(
            withCompletionDateStarting: starting,
            ending: ending,
            calendars: calendars
        )

        let reminders = await fetchReminders(matching: predicate)
            .sorted(by: completedReminderSort)

        return reminders.map(reminderSummary)
    }

    private static func fetchReminders(matching predicate: NSPredicate) async -> [EKReminder] {
        await withCheckedContinuation { continuation in
            store.fetchReminders(matching: predicate) { reminders in
                continuation.resume(returning: reminders ?? [])
            }
        }
    }

    private static func mergeDisplayItems(
        incomplete: [ReminderSummary],
        completed: [ReminderSummary]
    ) -> (items: [ReminderSummary], remainingItemCount: Int) {
        let displayItems: [ReminderSummary]

        switch (incomplete.isEmpty, completed.isEmpty) {
        case (false, false):
            let incompleteSlots = min(2, incomplete.count)
            let completedSlots = min(3 - incompleteSlots, completed.count)
            let baseItems = Array(incomplete.prefix(incompleteSlots))
            let completedItems = Array(completed.prefix(completedSlots))
            let remainingSlots = max(0, 3 - baseItems.count - completedItems.count)
            displayItems = baseItems + completedItems + incomplete.dropFirst(incompleteSlots).prefix(remainingSlots)
        case (false, true):
            displayItems = Array(incomplete.prefix(3))
        case (true, false):
            displayItems = Array(completed.prefix(3))
        case (true, true):
            displayItems = []
        }

        let totalCount = incomplete.count + completed.count
        return (displayItems, max(0, totalCount - displayItems.count))
    }

    private static func selectedReminderList() -> ReminderListSummary? {
        guard let identifier = AppGroupConstants.sharedDefaults?.string(
            forKey: AppGroupConstants.reminderSelectedIdentifierKey
        ),
        let calendar = store.calendars(for: .reminder).first(where: {
            $0.calendarIdentifier == identifier
        }) else {
            return nil
        }

        return ReminderListSummary(
            id: calendar.calendarIdentifier,
            title: calendar.title,
            subtitle: reminderListSubtitle(for: calendar)
        )
    }

    private static func calendarsMatching(identifier: String?) -> [EKCalendar]? {
        guard let identifier, !identifier.isEmpty else {
            return nil
        }

        guard let calendar = store.calendars(for: .reminder).first(where: {
            $0.calendarIdentifier == identifier
        }) else {
            return nil
        }

        return [calendar]
    }

    private static func incompleteReminderSort(_ lhs: EKReminder, _ rhs: EKReminder) -> Bool {
        let lhsDate = dueDate(for: lhs) ?? .distantFuture
        let rhsDate = dueDate(for: rhs) ?? .distantFuture

        if lhsDate != rhsDate {
            return lhsDate < rhsDate
        }

        return (lhs.title ?? "") < (rhs.title ?? "")
    }

    private static func completedReminderSort(_ lhs: EKReminder, _ rhs: EKReminder) -> Bool {
        let lhsDate = lhs.completionDate ?? .distantPast
        let rhsDate = rhs.completionDate ?? .distantPast
        return lhsDate > rhsDate
    }

    private static func reminderSummary(from reminder: EKReminder) -> ReminderSummary {
        ReminderSummary(
            id: reminder.calendarItemIdentifier,
            title: reminder.title ?? "Untitled Reminder",
            isCompleted: reminder.isCompleted
        )
    }

    private static func dueDate(for reminder: EKReminder) -> Date? {
        reminder.dueDateComponents?.date
    }

    private static func reminderListSubtitle(for calendar: EKCalendar) -> String {
        let sourceTitle = calendar.source.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return sourceTitle.isEmpty ? "Apple Reminders" : sourceTitle
    }
}
