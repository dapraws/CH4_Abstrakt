import SwiftUI
import WidgetKit

// MARK: - Render Snapshot

struct TodaySnapshot: Codable, Hashable {
    let date: Date
    let temperature: Int
    let high: Int
    let low: Int
    let weatherSymbol: String
    let conditionLabel: String

    private var usesFahrenheit: Bool {
        AbstraktAppGroup.defaults?.string(forKey: "settings.temperatureUnit") == "fahrenheit"
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

    var shortConditionLabel: String {
        let words = conditionLabel
            .split(separator: " ")
            .prefix(2)
            .map(String.init)
        return words.isEmpty ? "Weather" : words.joined(separator: " ")
    }

    var conditionSystemImageName: String {
        if weatherSymbol.hasPrefix("clear") {
            return weatherSymbol.contains("night") ? "moon.stars.fill" : "sun.max.fill"
        }

        if weatherSymbol.contains("partlyCloudy") || weatherSymbol.contains("mostlyClear") {
            return weatherSymbol.contains("night") ? "cloud.moon.fill" : "cloud.sun.fill"
        }

        if weatherSymbol.contains("mostlyCloudy") || weatherSymbol == "cloudy" {
            return "cloud.fill"
        }

        if weatherSymbol.contains("thunderstorms") || weatherSymbol.contains("strongStorms") {
            return "cloud.bolt.rain.fill"
        }

        if weatherSymbol.contains("rain") || weatherSymbol.contains("drizzle") || weatherSymbol.contains("sunShowers") {
            return "cloud.rain.fill"
        }

        if weatherSymbol.contains("snow") || weatherSymbol.contains("flurries") || weatherSymbol.contains("sleet") || weatherSymbol.contains("rainAndSnow") {
            return "cloud.snow.fill"
        }

        if weatherSymbol.contains("foggy") || weatherSymbol.contains("haze") || weatherSymbol.contains("smoky") || weatherSymbol.contains("blowingDust") {
            return "cloud.fog.fill"
        }

        if weatherSymbol.contains("windy") {
            return "wind"
        }

        return "cloud.sun.fill"
    }

    private func convertedFromCelsius(_ celsius: Int) -> Int {
        guard usesFahrenheit else {
            return celsius
        }

        return Int((Double(celsius) * 9.0 / 5.0 + 32.0).rounded())
    }
}

// MARK: - Widget

struct TodayWidget: View {
    private static let widgetCornerRadius: CGFloat = 30
    private static let activeCalendarFill = Color(red: 1, green: 0.35, blue: 0.22)

    let snapshot: TodaySnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: TodaySnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    // MARK: Body

    var body: some View {
        #if WIDGET_EXTENSION
        GeometryReader { proxy in
            let metrics = TodayMetrics(size: proxy.size)
            widgetContent(metrics: metrics)
        }
        .containerBackground(palette.background, for: .widget)
        #else
        ZStack {
            palette.background
            GeometryReader { proxy in
                let metrics = TodayMetrics(size: proxy.size)
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
        #endif
    }

    // MARK: Content

    private func widgetContent(metrics: TodayMetrics) -> some View {
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

    private func timeCard(metrics: TodayMetrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: metrics.cardCornerRadius, style: .continuous)
                .fill(palette.cardBackground)

            VStack(alignment: .leading, spacing: metrics.timeStackSpacing) {
                HStack {
                    conditionHeader(metrics: metrics)
                    Spacer(minLength: 0)
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

    private func conditionHeader(metrics: TodayMetrics) -> some View {
        HStack(spacing: 5) {
            Image(systemName: snapshot.conditionSystemImageName)
                .font(.system(size: metrics.conditionIconSize, weight: .semibold))
                .foregroundStyle(palette.foreground.opacity(0.32))
                .symbolRenderingMode(.hierarchical)
                .frame(width: metrics.conditionIconSize, height: metrics.conditionIconSize)

            Text(snapshot.shortConditionLabel)
                .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme).weight(.medium))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 5)
        .foregroundStyle(palette.foreground)
        .frame(height: metrics.conditionHeaderHeight)
    }

    private func weatherCard(metrics: TodayMetrics) -> some View {
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

    private func calendarCard(metrics: TodayMetrics) -> some View {
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
                    ForEach(Array(calendarDays.enumerated()), id: \.offset) { _, value in
                        Text(value == 0 ? "" : "\(value)")
                            .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
                            .lineLimit(1)
                            .minimumScaleFactor(metrics.calendarMinimumScale)
                            .foregroundStyle(palette.foreground.opacity(value == highlightedDay ? 1 : 0.86))
                            .frame(width: metrics.dayCellWidth, height: metrics.dayCellHeight)
                            .background {
                                if value == highlightedDay {
                                    RoundedRectangle(cornerRadius: metrics.highlightCornerRadius, style: .continuous)
                                        .fill(Self.activeCalendarFill)
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

// MARK: - Layout Metrics

private struct TodayMetrics {
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

    var conditionHeaderHeight: CGFloat {
        clamped(size.height * 0.16, minimum: 24, maximum: 27)
    }

    var conditionIconSize: CGFloat {
        conditionHeaderHeight * 0.32
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

// MARK: - Preview Data

extension TodaySnapshot {
    static let placeholder = TodaySnapshot(
        date: .now,
        temperature: 25,
        high: 30,
        low: 24,
        weatherSymbol: "partlyCloudy-day",
        conditionLabel: "Partly Cloudy"
    )
}

#Preview("Today") {
    TodayWidget(
        snapshot: TodaySnapshot(
            date: .todayPreviewDate,
            temperature: 25,
            high: 30,
            low: 24,
            weatherSymbol: "partlyCloudy-day",
            conditionLabel: "Partly Cloudy"
        )
    )
    .frame(width: 364, height: 170)
}

private extension Date {
    static let todayPreviewDate = Calendar.current.date(
        from: DateComponents(year: 2026, month: 6, day: 29, hour: 9, minute: 41)
    ) ?? .now
}
