import SwiftUI

struct DailyDashboardSnapshot: Codable, Hashable {
    let date: Date
    let temperature: Int
    let high: Int
    let low: Int
    let weatherSymbol: String
}

struct DailyDashboardWidget: View {
    let snapshot: DailyDashboardSnapshot

    init(snapshot: DailyDashboardSnapshot = .placeholder) {
        self.snapshot = snapshot
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(spacing: 8) {
                timeCard
                weatherCard
            }
            .frame(width: 132)

            calendarCard
        }
        .padding(8)
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
                        Text("\(snapshot.temperature)")
                        Text(snapshot.weatherSymbol)
                    }
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.widgetPrimaryText)
                    .padding(.horizontal, 7)
                    .frame(height: 18)
                    .background(AppColors.widgetPrimaryText.opacity(0.12))
                    .clipShape(Capsule())
                }

                Text(snapshot.date.formatted(.dateTime.hour().minute()))
                    .font(.system(size: 41, weight: .bold, design: .rounded))
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
                Text("\(snapshot.temperature)")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.widgetPrimaryText)

                Text("°")
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.widgetPrimaryText)
                    .offset(x: -5, y: -5)

                Spacer(minLength: 2)

                VStack(alignment: .leading, spacing: 3) {
                    Text("▲ \(snapshot.high)°")
                    Text("▼ \(snapshot.low)°")
                }
                .font(.system(size: 9, weight: .bold, design: .rounded))
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
                    ForEach(weekdaySymbols, id: \.self) { weekday in
                        Text(weekday)
                            .frame(maxWidth: .infinity)
                    }
                }
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Color(red: 1, green: 0.36, blue: 0.42))

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 7) {
                    ForEach(calendarDays.indices, id: \.self) { index in
                        let value = calendarDays[index]
                        Text(value == 0 ? "" : "\(value)")
                            .font(.system(size: 9, weight: .semibold, design: .rounded))
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

#Preview {
    DailyDashboardWidget()
        .frame(width: 364, height: 170)
}
