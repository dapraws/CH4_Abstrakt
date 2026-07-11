import Foundation

enum ReminderAccessState: String, Codable, Hashable {
    case available
    case empty
    case permissionNeeded
}

struct ReminderSummary: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let isCompleted: Bool

    init(id: String, title: String, isCompleted: Bool) {
        self.id = id
        self.title = title.isEmpty ? "Untitled Reminder" : title
        self.isCompleted = isCompleted
    }
}

struct ReminderListSummary: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String

    init(id: String, title: String, subtitle: String = "Apple Reminders") {
        self.id = id
        self.title = title.isEmpty ? "Untitled List" : title
        self.subtitle = subtitle.isEmpty ? "Apple Reminders" : subtitle
    }
}

struct ReminderSnapshot: Codable, Hashable {
    let date: Date
    let accessState: ReminderAccessState
    let selectedList: ReminderListSummary?
    let items: [ReminderSummary]
    let remainingItemCount: Int

    init(
        date: Date = .now,
        accessState: ReminderAccessState = .available,
        selectedList: ReminderListSummary? = nil,
        items: [ReminderSummary] = [],
        remainingItemCount: Int = 0
    ) {
        self.date = date
        self.accessState = accessState
        self.selectedList = selectedList
        self.items = items
        self.remainingItemCount = max(0, remainingItemCount)
    }
}

extension ReminderSnapshot {
    var deepLinkURL: URL? {
        guard let selectedList else {
            return nil
        }

        var components = URLComponents()
        components.scheme = "abstrakt"
        components.host = "reminder"
        components.queryItems = [
            URLQueryItem(name: "listId", value: selectedList.id),
            URLQueryItem(name: "title", value: selectedList.title),
        ]
        return components.url
    }
}

extension ReminderSnapshot {
    static let placeholder = ReminderSnapshot(
        date: .now,
        accessState: .available,
        selectedList: ReminderListSummary(id: "list-1", title: "Reminders", subtitle: "iCloud"),
        items: [
            ReminderSummary(id: "1", title: "Meeting at 2 PM", isCompleted: false),
            ReminderSummary(id: "2", title: "Pick up groceries at the store", isCompleted: false),
            ReminderSummary(id: "3", title: "Pay monthly installment for Park23", isCompleted: true),
        ],
        remainingItemCount: 2
    )
}
