//
//  LiveActivityItemRenderer.swift
//  Abstrakt
//

import SwiftUI

struct LiveActivityItemRenderer: View {
    @Environment(\.colorScheme) private var colorScheme

    var item: LiveActivityWidget
    var isLiveActivity: Bool = false
    var showsActivityTitle: Bool = true
    var activityCornerRadius: CGFloat = LiveActivityWidgetMetrics.activityPreviewCornerRadius
    var activityBackgroundStyle: LiveActivityBackgroundStyle = .solid
    var drawsActivitySurface = true
    var adaptsContentColorForGlass = false
    var activityTitleColor: Color? = nil

    private var fontScale: CGFloat {
        if item.layout.usesFullActivityPreview {
            isLiveActivity ? 1.08 : 1.06
        } else {
            isLiveActivity ? 1 : 0.88
        }
    }

    private var usesGlassSurface: Bool {
        isLiveActivity && activityBackgroundStyle == .glass
    }

    private var usesLightGlassContent: Bool {
        usesGlassSurface && adaptsContentColorForGlass && colorScheme == .light
    }

    private var primaryContentColor: Color {
        usesLightGlassContent ? lightPrimaryTextColor : .white
    }

    private var secondaryContentColor: Color {
        usesLightGlassContent ? lightPrimaryTextColor.opacity(0.58) : .white.opacity(0.42)
    }

    private var tertiaryContentColor: Color {
        usesLightGlassContent ? lightPrimaryTextColor.opacity(0.46) : .white.opacity(0.46)
    }

    private var lightPrimaryTextColor: Color {
        Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255)
    }

    private var surfaceLayout: LiveActivitySurfaceLayout {
        item.layout.surfaceLayout(isLiveActivity: isLiveActivity)
    }
    
    @ViewBuilder
    private func iconView(size: CGFloat) -> some View {
        if item.isSystemImage {
            Image(systemName: item.iconName)
                .font(.system(size: size * fontScale))
        } else {
            Image(item.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: size, height: size)
        }
    }
    
    var body: some View {
        switch item.layout {
        case .iconTopTextBottom:
            VStack(spacing: 2) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let text = item.primaryText {
                    Text(text)
                        .font(LiveActivityTypography.numericValue(scale: fontScale))
                        .foregroundStyle(primaryContentColor)
                        .liveActivityTextFormatting()
                }
            }
        case .temperatureHighLow:
            HStack(spacing: 2) {
                VStack(alignment: .leading, spacing: 1) {
                    if let high = item.primaryText {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.up.circle.fill").foregroundStyle(.red)
                            Text(high).foregroundStyle(primaryContentColor)
                        }
                    }
                    if let low = item.secondaryText {
                        HStack(spacing: 2) {
                            Image(systemName: "arrow.down.circle.fill").foregroundStyle(.blue)
                            Text(low).foregroundStyle(primaryContentColor)
                        }
                    }
                }
                .font(LiveActivityTypography.detailLabel(scale: fontScale))
                .liveActivityTextFormatting()
            }
        case .caloriesStyle:
            VStack(spacing: 4) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let val = item.primaryText {
                    Text(val)
                        .font(LiveActivityTypography.numericValue(scale: fontScale))
                        .foregroundStyle(primaryContentColor)
                        .liveActivityTextFormatting()
                }
            }
        case .calendarSplit:
            VStack(spacing: 0) {
                if let p = item.primaryText {
                    Text(p)
                        .font(LiveActivityTypography.detailLabel(scale: fontScale))
                        .textCase(.uppercase)
                        .foregroundStyle(item.color)
                        .liveActivityTextFormatting()
                }
                if let s = item.secondaryText {
                    Text(s)
                        .font(LiveActivityTypography.numericValue(scale: fontScale))
                        .foregroundStyle(primaryContentColor)
                        .liveActivityTextFormatting()
                }
            }
        case .textTopTextBottom:
            VStack(spacing: 4) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let val = item.primaryText {
                    Text(val)
                        .font(LiveActivityTypography.numericValue(scale: fontScale))
                        .foregroundStyle(item.color)
                        .liveActivityTextFormatting()
                }
            }
        case .largeTextSplit:
            HStack(spacing: 4) {
                HStack(spacing: 0) {
                    if let p = item.primaryText {
                        Text(p).foregroundStyle(item.secondaryText == nil ? item.color : .red)
                    }
                    if let s = item.secondaryText {
                        Text(s).foregroundStyle(.blue)
                    }
                }
                .font(LiveActivityTypography.singleWord(scale: fontScale))
                .liveActivityTextFormatting()
            }
        case .storageStyle:
            VStack(spacing: 4) {
                iconView(size: 20)
                    .foregroundStyle(item.color)
                if let val = item.primaryText {
                    Text(val)
                        .font(LiveActivityTypography.numericValue(scale: fontScale))
                        .foregroundStyle(primaryContentColor)
                        .liveActivityTextFormatting()
                }
            }
        case .circularProgress:
            VStack(spacing: -2) {
                if let p = item.primaryText {
                    Text(p)
                        .font(LiveActivityTypography.detailLabel(scale: fontScale))
                        .liveActivityTextFormatting()
                }
                if let s = item.secondaryText {
                    Text(s)
                        .font(LiveActivityTypography.microSubtext(scale: fontScale))
                        .liveActivityTextFormatting()
                }
            }
            .foregroundStyle(primaryContentColor)
        case .largeIcon:
            iconView(size: 28)
                .font(LiveActivityTypography.iconOnly(scale: fontScale))
                .foregroundStyle(item.color)
        case .ringGauge:
            ringGauge
        case .temperatureGauge:
            temperatureGauge
        case .windCompass:
            windCompass
        case .analogClock:
            analogClock
        case .stopwatchDial:
            stopwatchDial
        case .secondsValue:
            Text(item.primaryText ?? "0")
                .font(.system(size: 22 * fontScale, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(item.color)
                .liveActivityTextFormatting()
        case .dateFraction:
            HStack(spacing: 0) {
                Text(item.primaryText ?? "7")
                    .foregroundStyle(primaryContentColor)
                Text("/")
                    .foregroundStyle(usesLightGlassContent ? lightPrimaryTextColor.opacity(0.74) : .white.opacity(0.74))
                Text(item.secondaryText ?? "13")
                    .foregroundStyle(.red)
            }
            .font(.system(size: 20 * fontScale, weight: .heavy, design: .rounded).monospacedDigit())
            .liveActivityTextFormatting()
        case .calendarStack:
            VStack(spacing: -1) {
                Text(item.primaryText ?? "Mon")
                    .foregroundStyle(item.color)
                Text(item.secondaryText ?? "13")
                    .foregroundStyle(primaryContentColor)
            }
            .font(.system(size: 19 * fontScale, weight: .heavy, design: .rounded).monospacedDigit())
            .liveActivityTextFormatting()
        case .todayInfo:
            todayInfo
        case .weatherInfo:
            weatherInfo
        case .calendarInfo:
            calendarInfo
        }
    }

    private var todayInfo: some View {
        VStack(spacing: surfaceLayout.titleSpacing) {
            VStack(spacing: 12) {
                HStack(spacing: 5) {
                    Text("It's")
                        .foregroundStyle(secondaryContentColor)
                    circularIcon(systemName: "gauge.with.needle", background: .white, foreground: .black)
                    Text(item.primaryText ?? "Monday")
                        .foregroundStyle(primaryContentColor)
                    Text("and")
                        .foregroundStyle(secondaryContentColor)
                    calendarBadge
                    Text(item.secondaryText ?? "Jul 13")
                        .foregroundStyle(primaryContentColor)
                }

                HStack(spacing: 6) {
                    circularIcon(systemName: "figure.walk", background: .green, foreground: .black)
                    Text(metadataValue("stepsLabel", fallback: "0"))
                        .foregroundStyle(primaryContentColor)
                    Text("steps,")
                        .foregroundStyle(secondaryContentColor)
                    Image(systemName: metadataValue("weatherIcon", fallback: "cloud.sun.fill"))
                        .font(.system(size: 22 * fontScale, weight: .bold))
                        .symbolRenderingMode(usesLightGlassContent ? .monochrome : .multicolor)
                        .foregroundStyle(primaryContentColor)
                    Text(metadataValue("temperatureRange", fallback: "--°"))
                        .foregroundStyle(primaryContentColor)
                    if let location = item.metadata["location"], !location.isEmpty {
                        Text("in")
                            .foregroundStyle(secondaryContentColor)
                        circularIcon(systemName: "location.north.fill", background: .blue, foreground: .black)
                        Text(location)
                            .foregroundStyle(primaryContentColor)
                    }
                }
            }
            .font(LiveActivityTypography.islandFont(.body, scale: fontScale))
            .minimumScaleFactor(0.72)
            .lineLimit(1)
            .liveActivityTextFormatting()
            .padding(.horizontal, surfaceLayout.horizontalPadding)
            .padding(.vertical, surfaceLayout.verticalPadding)
            .frame(height: surfaceLayout.height)
            .frame(maxWidth: .infinity)
            .background {
                activitySurfaceBackground(cornerRadius: activityCornerRadius)
            }
            .clipShape(RoundedRectangle(cornerRadius: activityCornerRadius, style: .continuous))

            activityTitle(item.name)
        }
    }

    private var weatherInfo: some View {
        VStack(spacing: surfaceLayout.titleSpacing) {
            VStack(spacing: 10) {
                HStack(spacing: 11) {
                    Image(systemName: metadataValue("weatherIcon", fallback: item.iconName))
                        .font(.system(size: 23 * fontScale, weight: .semibold))
                        .symbolRenderingMode(.multicolor)
                        .frame(width: 30, height: 30)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(metadataValue("conditionLabel", fallback: item.primaryText ?? "Weather"))
                            .font(LiveActivityTypography.islandFont(.body, scale: fontScale))
                            .foregroundStyle(primaryContentColor)
                            .liveActivityTextFormatting()

                        Text("feels like \(metadataValue("currentTemperature", fallback: "--°"))")
                            .font(LiveActivityTypography.islandFont(.label, scale: fontScale * 0.84))
                            .foregroundStyle(secondaryContentColor)
                            .liveActivityTextFormatting()
                    }

                    Spacer(minLength: 4)

                    Text(metadataValue("temperatureRange", fallback: item.secondaryText ?? "--°"))
                        .font(LiveActivityTypography.islandFont(.headline, scale: fontScale * 0.98).monospacedDigit())
                        .foregroundStyle(primaryContentColor)
                        .liveActivityTextFormatting()
                }

                HStack(spacing: 7) {
                    weatherMetricChip(
                        systemName: "arrow.up",
                        value: metadataValue("highTemperature", fallback: "--°"),
                        tint: .orange
                    )
                    weatherMetricChip(
                        systemName: "arrow.down",
                        value: metadataValue("lowTemperature", fallback: "--°"),
                        tint: .blue
                    )
                    weatherMetricChip(
                        systemName: "figure.walk",
                        value: metadataValue("stepsLabel", fallback: "0"),
                        tint: .green
                    )
                }
            }
            .padding(.horizontal, surfaceLayout.horizontalPadding)
            .padding(.vertical, surfaceLayout.verticalPadding)
            .frame(height: surfaceLayout.height)
            .frame(maxWidth: .infinity)
            .background {
                activitySurfaceBackground(cornerRadius: activityCornerRadius)
            }
            .clipShape(RoundedRectangle(cornerRadius: activityCornerRadius, style: .continuous))

            activityTitle(item.name)
        }
    }

    private var calendarInfo: some View {
        VStack(spacing: surfaceLayout.titleSpacing) {
            HStack(spacing: 8) {
                ForEach(calendarDays, id: \.date) { day in
                    calendarDayView(day)
                }
            }
            .padding(.horizontal, surfaceLayout.horizontalPadding)
            .padding(.vertical, surfaceLayout.verticalPadding)
            .frame(height: surfaceLayout.height)
            .frame(maxWidth: .infinity)
            .background {
                activitySurfaceBackground(cornerRadius: activityCornerRadius)
            }
            .clipShape(RoundedRectangle(cornerRadius: activityCornerRadius, style: .continuous))

            activityTitle("Calendar Info")
        }
    }

    @ViewBuilder
    private func calendarDayView(
        _ day: (weekday: String, date: String, isToday: Bool)
    ) -> some View {
        if day.isToday {
            let activeShape = RoundedRectangle(cornerRadius: 17, style: .continuous)

            ZStack(alignment: .bottom) {
                    LinearGradient(
                        colors: [
                            Color(red: 1, green: 0.28, blue: 0.36),
                            Color(red: 1, green: 0.55, blue: 0.18)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(activeShape)

                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                    Color.white
                        .frame(height: 17)
                }
                .clipShape(activeShape)

                VStack(spacing: 1) {
                    Text(day.weekday)
                        .font(LiveActivityTypography.islandFont(.label, scale: fontScale))
                        .foregroundStyle(.white.opacity(0.95))
                        .liveActivityTextFormatting()

                    Text(day.date)
                        .font(LiveActivityTypography.islandFont(.number, scale: fontScale).monospacedDigit())
                        .foregroundStyle(.white)
                        .liveActivityTextFormatting()

                    Text("today")
                        .font(LiveActivityTypography.islandFont(.badge, scale: fontScale * 0.72))
                        .textCase(.uppercase)
                        .foregroundStyle(Color.black.opacity(0.68))
                        .liveActivityTextFormatting()
                        .frame(height: 12)
                }
                .padding(.top, 6)
                .padding(.bottom, 3)
            }
            .frame(width: 46, height: 62)
            .overlay {
                activeShape
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            }
            .shadow(color: .orange.opacity(0.22), radius: 9, x: 0, y: 4)
        } else {
            VStack(spacing: 5) {
                Text(day.weekday)
                    .font(LiveActivityTypography.islandFont(.label, scale: fontScale))
                    .foregroundStyle(secondaryContentColor)
                Text(day.date)
                    .font(LiveActivityTypography.islandFont(.number, scale: fontScale).monospacedDigit())
                    .foregroundStyle(primaryContentColor)
            }
            .frame(width: 29, height: 56)
        }
    }

    @ViewBuilder
    private func activityTitle(_ title: String) -> some View {
        if showsActivityTitle {
            Text(title)
                .font(LiveActivityTypography.islandFont(.title, scale: fontScale))
                .foregroundStyle(activityTitleColor ?? primaryContentColor)
                .liveActivityTextFormatting()
        }
    }

    @ViewBuilder
    private func activitySurfaceBackground(cornerRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if !drawsActivitySurface || usesGlassSurface {
            shape.fill(.clear)
        } else {
            shape.fill(Color.black)
        }
    }

    private func circularIcon(
        systemName: String,
        background: Color,
        foreground: Color
    ) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 13 * fontScale, weight: .bold))
            .foregroundStyle(foreground)
            .frame(width: 24, height: 24)
            .background(background)
            .clipShape(Circle())
    }

    private func weatherMetricChip(
        systemName: String,
        value: String,
        tint: Color
    ) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemName)
                .font(.system(size: 9 * fontScale, weight: .heavy))
                .foregroundStyle(tint)

            Text(value)
                .font(LiveActivityTypography.islandFont(.label, scale: fontScale * 0.84).monospacedDigit())
                .foregroundStyle(primaryContentColor)
                .liveActivityTextFormatting()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule(style: .continuous)
                .fill(usesLightGlassContent ? .black.opacity(0.07) : .white.opacity(0.1))
        )
    }

    private var calendarBadge: some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(.white)
            .frame(width: 25, height: 25)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.pink)
                    .frame(height: 8)
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                    .overlay {
                        Image(systemName: "checkmark")
                            .font(.system(size: 5 * fontScale, weight: .bold))
                            .foregroundStyle(.white)
                    }
            }
            .overlay {
                VStack(spacing: 1) {
                    Spacer(minLength: 8)
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(.gray.opacity(0.55))
                                .frame(width: 2, height: 2)
                        }
                    }
                    Spacer(minLength: 4)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }

    private var calendarDays: [(weekday: String, date: String, isToday: Bool)] {
        let calendar = Calendar.current
        let today = metadataDate ?? Date.now
        let start = calendar.date(byAdding: .day, value: -3, to: today) ?? today
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return (0..<7).map { offset in
            let date = calendar.date(byAdding: .day, value: offset, to: start) ?? today
            return (
                formatter.string(from: date),
                String(calendar.component(.day, from: date)),
                calendar.isDateInToday(date)
            )
        }
    }

    private var metadataDate: Date? {
        guard let value = item.metadata["referenceDate"],
              let interval = TimeInterval(value)
        else {
            return nil
        }

        return Date(timeIntervalSince1970: interval)
    }

    private func metadataValue(_ key: String, fallback: String) -> String {
        item.metadata[key] ?? fallback
    }

    private var ringGauge: some View {
        ZStack {
            Circle()
                .trim(from: 0.12, to: 0.88)
                .stroke(.white.opacity(0.2), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(90))

            Circle()
                .trim(from: 0.12, to: 0.12 + (0.76 * clampedProgress))
                .stroke(
                    AngularGradient(
                        colors: [.blue, .cyan, .green, .yellow, .orange, .red, .purple],
                        center: .center,
                        startAngle: .degrees(110),
                        endAngle: .degrees(430)
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(90))

            VStack(spacing: -1) {
                Text(item.primaryText ?? "0")
                    .font(.system(size: 18 * fontScale, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .liveActivityTextFormatting()

                iconView(size: 9)
                    .foregroundStyle(item.color)
            }
        }
        .frame(width: 40, height: 40)
    }

    private var temperatureGauge: some View {
        ZStack {
            ringGaugeBase(
                progress: clampedProgress,
                width: 5,
                colors: [.blue, .cyan, .green]
            )

            VStack(spacing: -1) {
                Text(item.primaryText ?? "17")
                    .font(.system(size: 18 * fontScale, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .liveActivityTextFormatting()

                if let secondary = item.secondaryText {
                    HStack(spacing: 2) {
                        ForEach(secondary.split(separator: " ").map(String.init), id: \.self) { value in
                            Text(value)
                        }
                    }
                    .font(.system(size: 9 * fontScale, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.cyan)
                    .liveActivityTextFormatting()
                }
            }
        }
        .frame(width: 42, height: 42)
    }

    private var windCompass: some View {
        ZStack {
            ForEach(0..<36, id: \.self) { tick in
                Capsule()
                    .fill(tick % 9 == 0 ? .white.opacity(0.56) : .white.opacity(0.22))
                    .frame(width: 1, height: tick % 9 == 0 ? 5 : 3)
                    .offset(y: -18)
                    .rotationEffect(.degrees(Double(tick) * 10))
            }

            Circle()
                .fill(.white.opacity(0.16))
                .frame(width: 25, height: 25)

            Text(item.primaryText ?? "45")
                .font(.system(size: 12 * fontScale, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .liveActivityTextFormatting()

            Image(systemName: "location.north.fill")
                .font(.system(size: 10 * fontScale, weight: .bold))
                .foregroundStyle(.blue)
                .offset(x: 10, y: -12)
                .rotationEffect(.degrees((item.progress ?? 0) * 360))
        }
        .frame(width: 44, height: 44)
    }

    private var analogClock: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white)
                .frame(width: 34, height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(.black.opacity(0.55), lineWidth: 2)
                )

            ForEach(0..<12, id: \.self) { tick in
                Capsule()
                    .fill(.black.opacity(tick % 3 == 0 ? 0.8 : 0.35))
                    .frame(width: 1.2, height: tick % 3 == 0 ? 4 : 2.5)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(tick) * 30))
            }

            Capsule()
                .fill(.red)
                .frame(width: 2, height: 12)
                .offset(y: -5)
                .rotationEffect(.degrees(300))

            Capsule()
                .fill(.black)
                .frame(width: 2, height: 10)
                .offset(y: -4)
                .rotationEffect(.degrees(45))
        }
    }

    private var stopwatchDial: some View {
        ZStack {
            ringGaugeBase(
                progress: clampedProgress,
                width: 2,
                colors: [.orange, .yellow, .white]
            )

            if let primary = item.primaryText {
                VStack(spacing: -2) {
                    Text(primary)
                    Text(item.secondaryText ?? "")
                }
                .font(.system(size: 9 * fontScale, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(.white)
                .liveActivityTextFormatting()
            } else {
                ForEach(0..<8, id: \.self) { tick in
                    Capsule()
                        .fill(tick == 6 ? .red : .white.opacity(0.45))
                        .frame(width: 2, height: tick == 6 ? 12 : 6)
                        .offset(y: -13)
                        .rotationEffect(.degrees(Double(tick) * 45))
                }
            }
        }
        .frame(width: 40, height: 40)
    }

    private var clampedProgress: Double {
        min(max(item.progress ?? 0.5, 0), 1)
    }

    private func ringGaugeBase(
        progress: Double,
        width: CGFloat,
        colors: [Color]
    ) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.08, to: 0.92)
                .stroke(.white.opacity(0.16), style: StrokeStyle(lineWidth: width, lineCap: .round))
                .rotationEffect(.degrees(90))

            Circle()
                .trim(from: 0.08, to: 0.08 + (0.84 * min(max(progress, 0), 1)))
                .stroke(
                    AngularGradient(
                        colors: colors,
                        center: .center,
                        startAngle: .degrees(120),
                        endAngle: .degrees(420)
                    ),
                    style: StrokeStyle(lineWidth: width, lineCap: .round)
                )
                .rotationEffect(.degrees(90))
        }
    }
}

#Preview("All Widgets Grid") {
    ScrollView {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 16) {
            let items = [
                LiveActivityWidget(id: "weather", name: "Weather", iconName: "partlyCloudy-day", widgetColor: .white, layout: .largeIcon, isSystemImage: false),
                LiveActivityWidget(id: "temperature-current", name: "Temperature", iconName: "thermometer", widgetColor: .cyan, layout: .secondsValue, primaryText: "25°"),
                LiveActivityWidget(id: "steps", name: "Steps", iconName: "figure.walk", widgetColor: .blue, layout: .textTopTextBottom, primaryText: "2,561"),
                LiveActivityWidget(id: "sleep", name: "Sleep", iconName: "bed.double.fill", widgetColor: .indigo, layout: .circularProgress, primaryText: "7H", secondaryText: "42M")
            ]
            
            ForEach(items) { item in
                VStack(spacing: 8) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.black)
                            .frame(width: 64, height: 64)
                        
                        LiveActivityItemRenderer(item: item)
                            .fixedSize()
                            .scaleEffect(0.85)
                            .frame(width: 64, height: 64)
                    }
                    Text(item.name)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
            }
        }
        .padding()
    }
}

#Preview("Specific Widget") {
    let item = LiveActivityWidget(name: "Sun Event", iconName: "sun.max.fill", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: "18:00")
    
    ZStack {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(Color.black)
            .frame(width: 64, height: 64)
        
        LiveActivityItemRenderer(item: item)
            .fixedSize()
            .scaleEffect(0.85)
            .frame(width: 64, height: 64)
    }
    .padding()
}
