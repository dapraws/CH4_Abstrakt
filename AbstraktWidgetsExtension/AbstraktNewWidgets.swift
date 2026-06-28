import SwiftUI
import WidgetKit

struct BatteryWidgetEntry: TimelineEntry {
    let date: Date
    let level: Int
    let estimatedHoursRemaining: Int?
    let isCharging: Bool
}

struct StepWidgetEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let distanceKilometers: Double
}

struct DashboardWidgetEntry: TimelineEntry {
    let date: Date
    let temperature: Int
    let high: Int
    let low: Int
    let weatherSymbol: String
}

struct BatteryBarsProvider: TimelineProvider {
    func placeholder(in context: Context) -> BatteryWidgetEntry {
        BatteryWidgetEntry(date: .now, level: 52, estimatedHoursRemaining: 5, isCharging: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (BatteryWidgetEntry) -> Void) {
        completion(WidgetSharedStore.batteryEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BatteryWidgetEntry>) -> Void) {
        completion(Timeline(entries: [WidgetSharedStore.batteryEntry], policy: .after(nextMinute())))
    }
}

struct StepHealthProvider: TimelineProvider {
    func placeholder(in context: Context) -> StepWidgetEntry {
        StepWidgetEntry(date: .now, steps: 3_192, distanceKilometers: 2.14)
    }

    func getSnapshot(in context: Context, completion: @escaping (StepWidgetEntry) -> Void) {
        completion(WidgetSharedStore.healthEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StepWidgetEntry>) -> Void) {
        completion(Timeline(entries: [WidgetSharedStore.healthEntry], policy: .after(nextMinute())))
    }
}

struct DailyDashboardProvider: TimelineProvider {
    func placeholder(in context: Context) -> DashboardWidgetEntry {
        DashboardWidgetEntry(date: .now, temperature: 25, high: 30, low: 24, weatherSymbol: "🌥️")
    }

    func getSnapshot(in context: Context, completion: @escaping (DashboardWidgetEntry) -> Void) {
        completion(WidgetSharedStore.dashboardEntry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DashboardWidgetEntry>) -> Void) {
        completion(Timeline(entries: [WidgetSharedStore.dashboardEntry], policy: .after(nextMinute())))
    }
}

struct BatteryBarsHomeWidget: Widget {
    let kind = "BatteryBarsHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BatteryBarsProvider()) { entry in
            BatteryBarsWidgetView(entry: entry)
        }
        .configurationDisplayName("Battery Bars")
        .description("Battery percentage and estimated remaining runtime.")
        .supportedFamilies([.systemSmall])
    }
}

struct StepHealthHomeWidget: Widget {
    let kind = "StepHealthHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepHealthProvider()) { entry in
            StepHealthWidgetView(entry: entry)
        }
        .configurationDisplayName("Step Health")
        .description("Today's steps and walking distance.")
        .supportedFamilies([.systemSmall])
    }
}

struct DailyDashboardHomeWidget: Widget {
    let kind = "DailyDashboardHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DailyDashboardProvider()) { entry in
            DailyDashboardWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Dashboard")
        .description("Time, weather, and calendar overview.")
        .supportedFamilies([.systemMedium])
    }
}

private func nextMinute() -> Date {
    Calendar.current.date(byAdding: .minute, value: 1, to: .now) ?? .now.addingTimeInterval(60)
}

private let widgetBackground = Color(red: 0.02, green: 0.02, blue: 0.02)
private let widgetForeground = Color(red: 0.96, green: 0.96, blue: 0.96)

private struct BatteryBarsWidgetView: View {
    let entry: BatteryWidgetEntry

    var body: some View {
        ZStack {
            widgetBackground

            VStack(spacing: 24) {
                HStack(spacing: 5) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))

                    Text("\(entry.level)%")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(widgetForeground)
                }

                HStack(spacing: 6) {
                    ForEach(0..<5, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(index < filledSegments ? Color(red: 1, green: 0.35, blue: 0.22) : widgetForeground.opacity(0.08))
                            .frame(width: 21, height: 44)
                    }
                }

                Text(entry.isCharging ? "Charging" : "- \(entry.estimatedHoursRemaining ?? 5) hours")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(widgetForeground.opacity(0.32))
            }
        }
        .containerBackground(widgetBackground, for: .widget)
    }

    private var filledSegments: Int {
        max(0, min(5, Int(ceil(Double(entry.level) / 20.0))))
    }
}

private struct StepHealthWidgetView: View {
    let entry: StepWidgetEntry

    var body: some View {
        ZStack {
            widgetBackground

            VStack(alignment: .leading) {
                stairIcon
                    .frame(width: 27, height: 18)

                Spacer()

                Text("You've walked\n\(entry.steps.formatted(.number)) steps,\ndistance is\n\(entry.distanceKilometers.formatted(.number.precision(.fractionLength(2)))) kilometers.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .lineSpacing(2)
                    .foregroundStyle(widgetForeground.opacity(0.7))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(18)
        }
        .containerBackground(widgetBackground, for: .widget)
    }

    private var stairIcon: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle().frame(width: 7, height: 3)
            Rectangle().frame(width: 14, height: 7)
            Rectangle().frame(width: 21, height: 12)
        }
        .foregroundStyle(widgetForeground)
    }
}

private struct DailyDashboardWidgetView: View {
    let entry: DashboardWidgetEntry

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
        .containerBackground(Color.white, for: .widget)
    }

    private var timeCard: some View {
        RoundedRectangle(cornerRadius: 17, style: .continuous)
            .fill(Color(red: 0.95, green: 0.96, blue: 0.98))
            .overlay {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Spacer()
                        Text("\(entry.temperature)° \(entry.weatherSymbol)")
                            .font(.system(size: 9, weight: .bold, design: .rounded))
                            .padding(.horizontal, 7)
                            .frame(height: 18)
                            .background(Color.black.opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Text(entry.date.formatted(.dateTime.hour().minute()))
                        .font(.system(size: 41, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black)
                        .minimumScaleFactor(0.72)
                }
                .padding(10)
            }
    }

    private var weatherCard: some View {
        RoundedRectangle(cornerRadius: 15, style: .continuous)
            .fill(Color(red: 0.95, green: 0.96, blue: 0.98))
            .frame(height: 56)
            .overlay {
                HStack {
                    Text("\(entry.temperature)")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    Text("°")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .offset(x: -5, y: -5)
                    Spacer(minLength: 2)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("▲ \(entry.high)°")
                        Text("▼ \(entry.low)°")
                    }
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.5))
                }
                .padding(.horizontal, 10)
            }
    }

    private var calendarCard: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(Color(red: 0.95, green: 0.96, blue: 0.98))
            .overlay {
                VStack(spacing: 9) {
                    HStack {
                        ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { weekday in
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

    private var highlightedDay: Int {
        Calendar.current.component(.day, from: entry.date)
    }

    private var calendarDays: [Int] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: entry.date)
        let monthStart = calendar.date(from: components) ?? entry.date
        let range = calendar.range(of: .day, in: .month, for: monthStart) ?? 1..<31
        let leading = calendar.component(.weekday, from: monthStart) - 1
        return Array(repeating: 0, count: leading) + Array(range)
    }
}
