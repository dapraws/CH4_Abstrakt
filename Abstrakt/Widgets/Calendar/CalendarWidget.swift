import SwiftUI
import WidgetKit

struct CalendarMonthSnapshot: Codable, Hashable {
    let date: Date

    init(date: Date = .now) {
        self.date = date
    }
}

struct CalendarWidget: View {
    private static let widgetCornerRadius: CGFloat = 22
    private static let activeFill = Color(red: 1, green: 0.35, blue: 0.22)
    private static let weekdayTint = Color(red: 1, green: 0.36, blue: 0.42)

    let snapshot: CalendarMonthSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: CalendarMonthSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }

    var body: some View {
        ZStack {
            palette.background

            VStack(spacing: 0) {
                // Weekday Row
                HStack(spacing: 0) {
                    ForEach(weekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                            .foregroundStyle(Self.weekdayTint)
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(maxHeight: .infinity)

                // Calendar Week Rows
                ForEach(Array(weekRows.enumerated()), id: \.offset) { _, row in
                    HStack(spacing: 0) {
                        ForEach(row) { day in
                            dayCell(day)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .padding(16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? Self.widgetCornerRadius : 0,
                style: .continuous
            )
        )
        .containerBackground(for: .widget) {
            palette.background
        }
    }

    private func dayCell(_ day: CalendarDay) -> some View {
        ZStack {
            if day.isToday {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Self.activeFill)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(2)
            }

            Text("\(day.number)")
                .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(dayTextColor(day))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private var weekRows: [[CalendarDay]] {
        stride(from: 0, to: calendarDays.count, by: 7).map { start in
            Array(calendarDays[start..<min(start + 7, calendarDays.count)])
        }
    }

    private func dayTextColor(_ day: CalendarDay) -> Color {
        if day.isToday {
            return Color.white
        }

        if day.isInDisplayedMonth {
            return palette.foreground
        }

        return palette.tertiaryForeground.opacity(0.35)
    }

    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let firstWeekdayIndex = max(0, min(calendar.firstWeekday - 1, symbols.count - 1))
        return Array(symbols[firstWeekdayIndex...] + symbols[..<firstWeekdayIndex]).map {
            $0.uppercased()
        }
    }

    private var calendarDays: [CalendarDay] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: snapshot.date),
            let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else {
            return []
        }

        let firstVisibleDate = firstWeek.start
        let leadingDayCount = calendar.dateComponents([.day], from: firstVisibleDate, to: monthInterval.start).day ?? 0
        let daysInMonth = calendar.range(of: .day, in: .month, for: snapshot.date)?.count ?? 31
        let visibleWeekCount = max(5, Int(ceil(Double(leadingDayCount + daysInMonth) / 7.0)))
        let totalVisibleDays = visibleWeekCount * 7
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: snapshot.date)

        return (0..<totalVisibleDays).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: firstVisibleDate) else {
                return nil
            }

            let components = calendar.dateComponents([.year, .month, .day], from: date)
            return CalendarDay(
                date: date,
                number: components.day ?? 1,
                isInDisplayedMonth: calendar.isDate(date, equalTo: snapshot.date, toGranularity: .month),
                isToday: components.year == todayComponents.year
                    && components.month == todayComponents.month
                    && components.day == todayComponents.day
            )
        }
    }

    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        return calendar
    }
}

extension CalendarMonthSnapshot {
    static let placeholder = CalendarMonthSnapshot(
        date: Calendar.autoupdatingCurrent.date(
            from: DateComponents(year: 2026, month: 6, day: 26)
        ) ?? .now
    )
}

private struct CalendarDay: Identifiable {
    let date: Date
    let number: Int
    let isInDisplayedMonth: Bool
    let isToday: Bool

    var id: Date { date }
}

#Preview("Calendar — Light") {
    CalendarWidget(snapshot: .placeholder)
        .frame(width: 170, height: 170)
        .environment(\.colorScheme, ColorScheme.light)
}

#Preview("Calendar — Dark") {
    CalendarWidget(snapshot: .placeholder)
        .frame(width: 170, height: 170)
        .environment(\.colorScheme, ColorScheme.dark)
}
