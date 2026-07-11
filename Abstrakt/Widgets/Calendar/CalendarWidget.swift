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
    private static let activeFill = Color(red: 0.55, green: 0.63, blue: 1.0)
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

    var body: some View {
        GeometryReader { proxy in
            let metrics = CalendarWidgetMetrics(
                size: proxy.size,
                weekRowCount: weekRowCount
            )

            ZStack {
                palette.background
                widgetContent(metrics: metrics)
            }
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

    private func widgetContent(metrics: CalendarWidgetMetrics) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(monthTitle)
                .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                .foregroundStyle(palette.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .frame(height: metrics.monthTitleHeight, alignment: .topLeading)
                .padding(.horizontal, 5)
                .padding(.top, 2)

            Spacer()

            VStack(alignment: .leading, spacing: metrics.gridTopSpacing) {
                HStack(spacing: metrics.columnSpacing) {
                    ForEach(weekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                            .foregroundStyle(Self.weekdayTint)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                            .frame(width: metrics.dayCellWidth, height: metrics.weekdayHeight)
                    }
                }

                VStack(alignment: .leading, spacing: metrics.gridSpacing) {
                    ForEach(Array(weekRows.enumerated()), id: \.offset) { _, row in
                        HStack(spacing: metrics.columnSpacing) {
                            ForEach(row) { day in
                                dayCell(day, metrics: metrics)
                            }
                        }
                    }
                }
            }
            .frame(width: metrics.gridWidth, alignment: .leading)
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.top, metrics.topPadding)
        .padding(.bottom, metrics.bottomPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func dayCell(_ day: CalendarDay, metrics: CalendarWidgetMetrics) -> some View {
        ZStack {
            if day.isToday {
                RoundedRectangle(
                    cornerRadius: metrics.highlightCornerRadius,
                    style: .continuous
                )
                .fill(Self.activeFill)
                .frame(
                    width: metrics.highlightWidth,
                    height: metrics.highlightHeight
                )
            }

            Text("\(day.number)")
                .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(dayTextColor(day))
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .frame(width: metrics.dayCellWidth, height: metrics.dayCellHeight)
    }

    private var weekRows: [[CalendarDay]] {
        stride(from: 0, to: calendarDays.count, by: 7).map { start in
            Array(calendarDays[start..<min(start + 7, calendarDays.count)])
        }
    }

    private func dayTextColor(_ day: CalendarDay) -> Color {
        if day.isToday {
            return palette.background
        }

        if day.isInDisplayedMonth {
            return palette.foreground
        }

        return palette.tertiaryForeground
    }

    private var monthTitle: String {
        snapshot.date.formatted(.dateTime.month(.wide))
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

    private var weekRowCount: Int {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: snapshot.date),
            let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start)
        else {
            return 5
        }

        let firstVisibleDate = firstWeek.start
        let leadingDayCount = calendar.dateComponents([.day], from: firstVisibleDate, to: monthInterval.start).day ?? 0
        let daysInMonth = calendar.range(of: .day, in: .month, for: snapshot.date)?.count ?? 31
        return max(5, Int(ceil(Double(leadingDayCount + daysInMonth) / 7.0)))
    }

    private var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.locale = .autoupdatingCurrent
        return calendar
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
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

private struct CalendarWidgetMetrics {
    let size: CGSize
    let weekRowCount: Int

    var horizontalPadding: CGFloat { max(8, size.width * 0.042) }
    var topPadding: CGFloat { max(6, size.height * 0.034) }
    var bottomPadding: CGFloat { max(7.5, size.height * 0.028) }
    var gridTopSpacing: CGFloat { max(2, size.height * 0.012) }
    var columnSpacing: CGFloat { max(1, size.width * 0.006) }
    var gridSpacing: CGFloat { max(1, size.height * 0.008) }
    var gridWidth: CGFloat { max(0, size.width - (horizontalPadding * 2)) }
    var dayCellWidth: CGFloat {
        max(0, floor((gridWidth - (columnSpacing * 6)) / 7.0))
    }
    var monthTitleHeight: CGFloat { max(20, size.height * 0.115) }
    var titleGridSpacerHeight: CGFloat { max(8, size.height * 0.05) }
    var weekdayHeight: CGFloat { max(12, size.height * 0.056) }
    var dayCellHeight: CGFloat {
        let contentHeight = max(
            0,
            size.height - topPadding - bottomPadding - monthTitleHeight - titleGridSpacerHeight - gridTopSpacing - weekdayHeight
        )
        let totalGridSpacing = gridSpacing * CGFloat(max(0, weekRowCount - 1))
        let availableHeight = max(0, contentHeight - totalGridSpacing)
        let naturalHeight = floor(availableHeight / CGFloat(max(weekRowCount, 1)))
        return min(max(0, naturalHeight), maxDayCellHeight)
    }
    var maxDayCellHeight: CGFloat { weekRowCount > 5 ? 18 : 20 }
    var highlightWidth: CGFloat { max(0, min(dayCellWidth, dayCellHeight) - 1) }
    var highlightHeight: CGFloat { max(0, highlightWidth - 4) }
    var highlightCornerRadius: CGFloat { max(7, highlightHeight * 0.48) }
}

#Preview("Calendar — Light") {
    ZStack {
        Color.black.ignoresSafeArea()
        CalendarWidget(snapshot: .placeholder)
            .frame(width: 170, height: 170)
    }
}

#Preview("Calendar — Dark") {
    ZStack {
        Color.white.ignoresSafeArea()
        CalendarWidget(snapshot: .placeholder)
            .frame(width: 170, height: 170)
    }
    .preferredColorScheme(.dark)
}
