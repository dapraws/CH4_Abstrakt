import SwiftUI

struct DailyDashboardSnapshot: Codable, Hashable {
    let date: Date
    let temperature: Int
    let high: Int
    let low: Int
    let weatherSymbol: String

    private var usesFahrenheit: Bool {
        UserDefaults(suiteName: "group.msaf.abstrakt")?.string(forKey: "settings.temperatureUnit") == "fahrenheit"
    }

    var displayTemperature: Int {
        convertedFromCelsius(temperature)
    }

    var displayHigh: Int {
        convertedFromCelsius(high)
    }

    var displayLow: Int {
        convertedFromCelsius(low)
    }

    private func convertedFromCelsius(_ celsius: Int) -> Int {
        guard usesFahrenheit else {
            return celsius
        }

        return Int((Double(celsius) * 9.0 / 5.0 + 32.0).rounded())
    }
}

struct DailyDashboardWidget: View {
    private static let widgetCornerRadius: CGFloat = 30

    let snapshot: DailyDashboardSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: DailyDashboardSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    var body: some View {
        ZStack {
            palette.background
            GeometryReader { proxy in
                let metrics = DailyDashboardMetrics(size: proxy.size)
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
    }

    private func widgetContent(metrics: DailyDashboardMetrics) -> some View {
        HStack(spacing: metrics.spacing) {
            VStack(spacing: metrics.spacing) {
                timeCard(metrics: metrics)
                    .frame(maxHeight: .infinity)
                weatherCard(metrics: metrics)
            }
            .frame(width: metrics.leftColumnWidth)
            .frame(maxHeight: .infinity)

            calendarCard(metrics: metrics)
                .frame(maxHeight: .infinity)
        }
        .padding(metrics.outerPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func timeCard(metrics: DailyDashboardMetrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.cardCornerRadius, style: .continuous)
                .fill(palette.cardBackground)

            VStack(alignment: .leading, spacing: metrics.timeStackSpacing) {
                HStack {
                    Spacer()
                    HStack(spacing: 3) {
                        Text("\(snapshot.displayTemperature)°")
                        Text(snapshot.weatherSymbol)
                    }
                    .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
                    .foregroundStyle(palette.foreground)
                    .padding(.horizontal, 7)
                    .frame(height: metrics.badgeHeight)
                    .background(palette.badgeFill)
                    .clipShape(Capsule())
                }

                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(timeDisplay.prefix)
                        .foregroundStyle(palette.foreground)
                    Text(timeDisplay.minute)
                        .foregroundStyle(palette.foreground.opacity(0.42))
                }
                .font(AbstraktWidgetFonts.font(.displayCompact, theme: fontTheme))
                .lineLimit(1)
                .minimumScaleFactor(metrics.displayMinimumScale)
            }
            .padding(metrics.cardPadding)
        }
    }

    private func weatherCard(metrics: DailyDashboardMetrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.cardCornerRadius, style: .continuous)
                .fill(palette.cardBackground)

            HStack(alignment: .center) {
                Text("\(snapshot.displayTemperature)")
                    .font(AbstraktWidgetFonts.font(.title, theme: fontTheme))
                    .lineLimit(1)
                    .minimumScaleFactor(metrics.temperatureMinimumScale)
                    .foregroundStyle(palette.foreground)

                Text("°")
                    .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                    .foregroundStyle(palette.foreground)
                    .offset(x: -5, y: -5)

                Spacer(minLength: 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text("▲ \(snapshot.displayHigh)°")
                    Text("▼ \(snapshot.displayLow)°")
                }
                .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .foregroundStyle(palette.secondaryForeground)
            }
            .padding(.horizontal, metrics.cardPadding)
        }
        .frame(height: metrics.weatherHeight)
    }

    private func calendarCard(metrics: DailyDashboardMetrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.cardCornerRadius, style: .continuous)
                .fill(palette.cardBackground)

            VStack(spacing: metrics.calendarSectionSpacing) {
                HStack {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                    }
                }
                .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(Color(red: 1, green: 0.36, blue: 0.42))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: metrics.calendarRowSpacing) {
                    ForEach(calendarDays.indices, id: \.self) { index in
                        let value = calendarDays[index]
                        Text(value == 0 ? "" : "\(value)")
                            .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
                            .lineLimit(1)
                            .minimumScaleFactor(metrics.calendarMinimumScale)
                            .foregroundStyle(palette.foreground.opacity(value == highlightedDay ? 1 : 0.86))
                            .frame(width: metrics.dayCellWidth, height: metrics.dayCellHeight)
                            .background {
                                if value == highlightedDay {
                                    RoundedRectangle(cornerRadius: metrics.highlightCornerRadius, style: .continuous)
                                        .fill(Color(red: 0.55, green: 0.63, blue: 1.0))
                                }
                            }
                    }
                }
            }
            .padding(metrics.calendarPadding)
        }
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }

    private var weekdaySymbols: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }

    private var highlightedDay: Int {
        Calendar.current.component(.day, from: snapshot.date)
    }

    private var timeDisplay: (prefix: String, minute: String) {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: snapshot.date)
        let minute = calendar.component(.minute, from: snapshot.date)
        let separator = Locale.current.identifier.hasPrefix("id") ? "." : ":"

        return (
            prefix: String(format: "%02d%@", hour, separator),
            minute: String(format: "%02d", minute)
        )
    }

    private var calendarDays: [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: snapshot.date)
        let monthStart = calendar.date(from: components) ?? snapshot.date
        let range = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<31
        let leading = calendar.component(.weekday, from: monthStart) - 1
        return Array(repeating: 0, count: leading) + Array(range)
    }
}

private struct DailyDashboardMetrics {
    let size: CGSize

    var outerPadding: CGFloat {
        clamped(size.height * 0.064, minimum: 7, maximum: 7)
    }

    var spacing: CGFloat {
        clamped(size.height * 0.052, minimum: 7, maximum: 7)
    }

    var cardCornerRadius: CGFloat {
        max(18, 30 - outerPadding)
    }

    var leftColumnWidth: CGFloat {
        min(size.width * 0.365, 132)
    }

    var weatherHeight: CGFloat {
        clamped(size.height * 0.305, minimum: 47, maximum: 54)
    }

    var cardPadding: CGFloat {
        clamped(size.height * 0.052, minimum: 8, maximum: 10)
    }

    var badgeHeight: CGFloat {
        clamped(size.height * 0.106, minimum: 17, maximum: 19)
    }

    var timeStackSpacing: CGFloat {
        clamped(size.height * 0.035, minimum: 4, maximum: 6)
    }

    var calendarPadding: EdgeInsets {
        let vertical = clamped(size.height * 0.07, minimum: 10, maximum: 13)
        let horizontal = clamped(size.width * 0.038, minimum: 10, maximum: 14)

        return EdgeInsets(
            top: vertical,
            leading: horizontal,
            bottom: vertical,
            trailing: horizontal
        )
    }

    var calendarSectionSpacing: CGFloat {
        clamped(size.height * 0.041, minimum: 5, maximum: 7)
    }

    var calendarRowSpacing: CGFloat {
        clamped(size.height * 0.034, minimum: 4, maximum: 6)
    }

    var dayCellWidth: CGFloat {
        clamped(size.width * 0.055, minimum: 18, maximum: 21)
    }

    var dayCellHeight: CGFloat {
        clamped(size.height * 0.104, minimum: 16, maximum: 18)
    }

    var highlightCornerRadius: CGFloat {
        clamped(size.height * 0.035, minimum: 5, maximum: 6)
    }

    var displayMinimumScale: CGFloat {
        size.height < 165 ? 0.7 : 0.78
    }

    var temperatureMinimumScale: CGFloat {
        size.height < 165 ? 0.72 : 0.82
    }

    var calendarMinimumScale: CGFloat {
        size.height < 165 ? 0.72 : 0.86
    }

    private func clamped(_ value: CGFloat, minimum: CGFloat, maximum: CGFloat) -> CGFloat {
        min(max(value, minimum), maximum)
    }
}

extension DailyDashboardSnapshot {
    static let placeholder = DailyDashboardSnapshot(
        date: .now,
        temperature: 25,
        high: 30,
        low: 24,
        weatherSymbol: "🌥️"
    )
}

#Preview("Daily Dashboard") {
    DailyDashboardWidget(
        snapshot: DailyDashboardSnapshot(
            date: .dailyDashboardPreviewDate,
            temperature: 25,
            high: 30,
            low: 24,
            weatherSymbol: "🌥️"
        )
    )
    .frame(width: 364, height: 170)
}

private extension Date {
    static let dailyDashboardPreviewDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 6, day: 29, hour: 9, minute: 41)
    ) ?? .now
}
