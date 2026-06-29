import SwiftUI

struct DailyDashboardSnapshot: Codable, Hashable {
    let date: Date
    let temperature: Int
    let high: Int
    let low: Int
    let weatherSymbol: String

    private var temperatureUnit: TemperatureUnitPreference {
        TemperatureUnitPreference.from(
            id: UserDefaults(suiteName: AppGroupConstants.suiteName)?.string(forKey: AppSettingsPreference.temperatureUnitKey) ?? TemperatureUnitPreference.celsius.id
        )
    }

    var displayTemperature: Int {
        temperatureUnit.convertFromCelsius(temperature)
    }

    var displayHigh: Int {
        temperatureUnit.convertFromCelsius(high)
    }

    var displayLow: Int {
        temperatureUnit.convertFromCelsius(low)
    }
}

struct DailyDashboardWidget: View {
    let snapshot: DailyDashboardSnapshot
    private let fontTheme: AppFontTheme = .sfProRounded

    init(snapshot: DailyDashboardSnapshot = .placeholder) {
        self.snapshot = snapshot
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 8) {
                timeCard
                    .frame(maxHeight: .infinity)
                weatherCard
            }
            .frame(width: 132)
            .frame(maxHeight: .infinity)

            calendarCard
                .frame(maxHeight: .infinity)
        }
        .padding(8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.widgetBackground)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var timeCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(AppColors.appBackground.opacity(0.82))

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Spacer()
                    HStack(spacing: 3) {
                        Text("\(snapshot.displayTemperature)")
                        Text(snapshot.weatherSymbol)
                    }
                    .font(AppFonts.widgetFont(.widgetMeta, theme: fontTheme))
                    .foregroundStyle(AppColors.widgetPrimaryText)
                    .padding(.horizontal, 7)
                    .frame(height: 18)
                    .background(AppColors.widgetPrimaryText.opacity(0.12))
                    .clipShape(Capsule())
                }

                Text(snapshot.date.formatted(.dateTime.hour().minute()))
                    .font(AppFonts.widgetFont(.widgetDisplay, theme: fontTheme))
                    .minimumScaleFactor(0.72)
                    .foregroundStyle(AppColors.widgetPrimaryText)
            }
            .padding(10)
        }
    }

    private var weatherCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(AppColors.appBackground.opacity(0.82))

            HStack(alignment: .center) {
                Text("\(snapshot.displayTemperature)")
                    .font(AppFonts.widgetFont(.widgetTitle, theme: fontTheme))
                    .foregroundStyle(AppColors.widgetPrimaryText)

                Text("°")
                    .font(AppFonts.widgetFont(.heading2, theme: fontTheme))
                    .foregroundStyle(AppColors.widgetPrimaryText)
                    .offset(x: -5, y: -5)

                Spacer(minLength: 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text("▲ \(snapshot.displayHigh)°")
                    Text("▼ \(snapshot.displayLow)°")
                }
                .font(AppFonts.widgetFont(.widgetMeta, theme: fontTheme))
                .foregroundStyle(AppColors.widgetSecondaryText)
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 56)
    }

    private var calendarCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(AppColors.appBackground.opacity(0.82))

            VStack(spacing: 9) {
                HStack {
                    ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                    }
                }
                .font(AppFonts.widgetFont(.widgetCaption, theme: fontTheme))
                .foregroundStyle(Color(red: 1, green: 0.36, blue: 0.42))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 7) {
                    ForEach(calendarDays.indices, id: \.self) { index in
                        let value = calendarDays[index]
                        Text(value == 0 ? "" : "\(value)")
                            .font(AppFonts.widgetFont(.widgetMeta, theme: fontTheme))
                            .foregroundStyle(AppColors.widgetPrimaryText.opacity(value == highlightedDay ? 1 : 0.86))
                            .frame(width: 20, height: 18)
                            .background {
                                if value == highlightedDay {
                                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                                        .fill(Color(red: 0.55, green: 0.63, blue: 1.0))
                                }
                            }
                    }
                }
            }
            .padding(14)
        }
    }

    private var weekdaySymbols: [String] {
        ["S", "M", "T", "W", "T", "F", "S"]
    }

    private var highlightedDay: Int {
        Calendar.current.component(.day, from: snapshot.date)
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
