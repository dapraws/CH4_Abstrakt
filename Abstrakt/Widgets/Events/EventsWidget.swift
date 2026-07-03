import SwiftUI
import WidgetKit

enum EventDisplayMode: String, CaseIterable, Codable, Hashable, Identifiable {
    case upcoming
    case current

    var id: String { rawValue }

    var title: String {
        switch self {
        case .upcoming:
            "Upcoming"
        case .current:
            "Current"
        }
    }

    static func from(id: String?) -> EventDisplayMode {
        EventDisplayMode(rawValue: id ?? "") ?? .upcoming
    }
}

enum EventAccessState: String, Codable, Hashable {
    case available
    case empty
    case permissionNeeded
}

struct EventSummary: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date

    init(id: String, title: String, startDate: Date, endDate: Date) {
        self.id = id
        self.title = title.isEmpty ? "Untitled Event" : title
        self.startDate = startDate
        self.endDate = endDate
    }

    func isCurrent(at date: Date) -> Bool {
        startDate <= date && endDate > date
    }

    func startsAfter(_ date: Date) -> Bool {
        startDate >= date
    }
}

struct EventsSnapshot: Codable, Hashable {
    let date: Date
    let accessState: EventAccessState
    let events: [EventSummary]

    init(
        date: Date = .now,
        accessState: EventAccessState = .available,
        events: [EventSummary] = []
    ) {
        self.date = date
        self.accessState = accessState
        self.events = events
    }

    func displayData(mode: EventDisplayMode, now: Date = .now) -> EventsDisplayData {
        guard accessState != .permissionNeeded else {
            return EventsDisplayData(
                status: "Calendar access",
                countText: "Permission needed",
                primaryText: "Open Abstrakt",
                secondaryText: "Allow calendar access",
                isEmpty: true
            )
        }

        let currentEvents = events.filter { $0.isCurrent(at: now) }
        let upcomingEvents = events.filter { $0.startsAfter(now) }

        let selectedEvents: [EventSummary]
        let status: String

        switch mode {
        case .upcoming:
            selectedEvents = upcomingEvents
            status = "Upcoming"
        case .current:
            if currentEvents.isEmpty {
                selectedEvents = upcomingEvents
                status = "Upcoming"
            } else {
                selectedEvents = currentEvents
                status = "Current"
            }
        }

        guard let firstEvent = selectedEvents.first else {
            return EventsDisplayData(
                status: status,
                countText: "No events",
                primaryText: accessState == .empty ? "Free today" : "Nothing scheduled",
                secondaryText: mode == .current ? "No current events" : "No upcoming events",
                isEmpty: true
            )
        }

        return EventsDisplayData(
            status: status,
            countText: "\(selectedEvents.count) \(selectedEvents.count == 1 ? "event" : "events")",
            primaryText: firstEvent.title,
            secondaryText: Self.timeLabel(for: firstEvent, now: now),
            isEmpty: false
        )
    }

    private static func timeLabel(for event: EventSummary, now: Date) -> String {
        if event.isCurrent(at: now) {
            return "Until \(event.endDate.formatted(.dateTime.hour().minute()))"
        }

        return event.startDate.formatted(.dateTime.hour().minute())
    }
}

struct EventsDisplayData: Hashable {
    let status: String
    let countText: String
    let primaryText: String
    let secondaryText: String
    let isEmpty: Bool
}

struct EventsWidget: View {
    let snapshot: EventsSnapshot
    let mode: EventDisplayMode
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: EventsSnapshot = .previewUpcoming,
        mode: EventDisplayMode = .upcoming,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.mode = mode
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    var body: some View {
        ZStack {
            palette.background
            widgetContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? 22 : 0,
                style: .continuous
            )
        )
        .containerBackground(for: .widget) {
            palette.background
        }
    }

    private var widgetContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Spacer(minLength: 8)

            eventBlock
        }
        .padding(.top, 15)
        .padding(.horizontal, 17)
        .padding(.bottom, 17)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text(snapshot.date.formatted(.dateTime.weekday(.abbreviated).day()))
                .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                .foregroundStyle(palette.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 8)

            Image("event-calendar-color")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
        }
    }

    private var eventBlock: some View {
        let data = snapshot.displayData(mode: mode)

        return VStack(alignment: .leading, spacing: 7) {
            Text(data.status)
                .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(palette.foreground.opacity(0.82))
                .lineLimit(1)
                .padding(.horizontal, 8)
                .frame(height: 22)
                .background(palette.badgeFill)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

            HStack(alignment: .top, spacing: 9) {
                accentBars
                    .opacity(data.isEmpty ? 0.36 : 1)

                VStack(alignment: .leading, spacing: 2) {
                    Text(data.countText)
                        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                        .foregroundStyle(palette.foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(data.primaryText)
                        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                        .foregroundStyle(palette.secondaryForeground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)

                    Text(data.secondaryText)
                        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                        .foregroundStyle(palette.tertiaryForeground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var accentBars: some View {
        HStack(spacing: 3) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color(red: 1, green: 0.64, blue: 0.29))
                .frame(width: 4)

        }
        .frame(height: 50)
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

extension EventsSnapshot {
    static let previewUpcoming = EventsSnapshot(
        date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 9, minute: 30)) ?? .now,
        events: [
            EventSummary(
                id: "design-workshop",
                title: "Design workshop",
                startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 10, minute: 0)) ?? .now,
                endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 11, minute: 0)) ?? .now
            ),
            EventSummary(
                id: "reminder",
                title: "Reminder to make slides",
                startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 12, minute: 0)) ?? .now,
                endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 12, minute: 30)) ?? .now
            ),
        ]
    )

    static let previewCurrent = EventsSnapshot(
        date: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 10, minute: 15)) ?? .now,
        events: [
            EventSummary(
                id: "standup",
                title: "Product standup",
                startDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 10, minute: 0)) ?? .now,
                endDate: Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 17, hour: 10, minute: 45)) ?? .now
            ),
        ]
    )
}

#Preview("Events - Upcoming") {
    EventsWidget(snapshot: .previewUpcoming, mode: .upcoming)
        .frame(width: 170, height: 170)
}

#Preview("Events - Current") {
    EventsWidget(snapshot: .previewCurrent, mode: .current)
        .frame(width: 170, height: 170)
}
