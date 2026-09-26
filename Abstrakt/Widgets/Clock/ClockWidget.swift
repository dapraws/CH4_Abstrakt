import SwiftUI
import WidgetKit

struct ClockSnapshot: Codable, Hashable {
    let date: Date
    let timeText: String
    let dateText: String
    let secondaryText: String

    init(
        date: Date = .now,
        timeText: String? = nil,
        dateText: String? = nil,
        secondaryText: String? = nil
    ) {
        self.date = date
        self.timeText = timeText ?? date.formatted(.dateTime.hour().minute())
        self.dateText = dateText ?? date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day())
        self.secondaryText = secondaryText ?? date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
    }

    static let placeholder = ClockSnapshot(
        date: Calendar.current.date(
            from: DateComponents(year: 2026, month: 6, day: 29, hour: 7, minute: 0, second: 50)
        ) ?? .now
    )
}

struct ClockWidget: View {
    private static let widgetCornerRadius: CGFloat = 22

    let snapshot: ClockSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: ClockSnapshot = .placeholder,
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

    private var isDark: Bool {
        colorScheme == .dark
    }

    var body: some View {
        ZStack {
            palette.background

            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height

                if w.isFinite && h.isFinite && w > 20 && h > 20 {
                    let size = min(w, h)
                    let dialDiameter = max(0, size - 16)
                    let radius = dialDiameter / 2
                    let center = CGPoint(x: w / 2, y: h / 2)

                    if dialDiameter > 0 && dialDiameter.isFinite {
                        // Dial Face Background
                        Circle()
                            .fill(dialBackgroundColor)
                            .frame(width: dialDiameter, height: dialDiameter)
                            .position(center)

                        // Background Hour Watermark (e.g. "02", "07")
                        let hour12 = Calendar.current.component(.hour, from: snapshot.date) % 12
                        let displayHour = hour12 == 0 ? 12 : hour12
                        Text(String(format: "%02d", displayHour))
                            .font(AbstraktWidgetFonts.font(.display, theme: fontTheme))
                            .foregroundStyle(watermarkColor)
                            .position(center)

                        // Roman Numerals (XII, III, VI, IX)
                        romanNumeral("XII", angle: 0, radius: radius * 0.74, center: center)
                        romanNumeral("III", angle: 90, radius: radius * 0.74, center: center)
                        romanNumeral("VI", angle: 180, radius: radius * 0.74, center: center)
                        romanNumeral("IX", angle: 270, radius: radius * 0.74, center: center)

                        // Minute / Hour Ticks (1, 2, 4, 5, 7, 8, 10, 11)
                        ForEach([1, 2, 4, 5, 7, 8, 10, 11], id: \.self) { hour in
                            tickMark(hour: hour, radius: radius * 0.80, center: center)
                        }

                        // Clock Hands
                        clockHands(radius: radius, center: center)
                    }
                }
            }
            .padding(8)
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

    // MARK: - Dial Styling

    private var dialBackgroundColor: Color {
        isDark
            ? Color(red: 0.11, green: 0.11, blue: 0.13)
            : Color(red: 0.965, green: 0.965, blue: 0.975)
    }

    private var watermarkColor: Color {
        isDark
            ? Color.white.opacity(0.06)
            : Color.white.opacity(0.85)
    }

    private var numeralColor: Color {
        isDark ? Color.white : Color(red: 0.10, green: 0.10, blue: 0.10)
    }

    private var tickColor: Color {
        isDark ? Color.white.opacity(0.25) : Color.black.opacity(0.18)
    }

    private var handColor: Color {
        isDark ? Color.white : Color(red: 0.12, green: 0.12, blue: 0.12)
    }

    private var secondHandColor: Color {
        isDark ? Color(red: 1.0, green: 0.28, blue: 0.28) : Color(red: 0.92, green: 0.20, blue: 0.20)
    }

    // MARK: - Numerals & Ticks

    @ViewBuilder
    private func romanNumeral(_ text: String, angle: Double, radius: CGFloat, center: CGPoint) -> some View {
        let radians = angle * .pi / 180.0
        let x = center.x + radius * CGFloat(sin(radians))
        let y = center.y - radius * CGFloat(cos(radians))

        if x.isFinite && y.isFinite {
            Text(text)
                .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(numeralColor)
                .position(x: x, y: y)
        }
    }

    @ViewBuilder
    private func tickMark(hour: Int, radius: CGFloat, center: CGPoint) -> some View {
        let angle = Double(hour) * 30.0
        let radians = angle * .pi / 180.0
        let x = center.x + radius * CGFloat(sin(radians))
        let y = center.y - radius * CGFloat(cos(radians))

        if x.isFinite && y.isFinite {
            Capsule()
                .fill(tickColor)
                .frame(width: 1.5, height: 6)
                .rotationEffect(.degrees(angle))
                .position(x: x, y: y)
        }
    }

    // MARK: - Clock Hands

    @ViewBuilder
    private func clockHands(radius: CGFloat, center: CGPoint) -> some View {
        if radius > 5 && radius.isFinite && center.x.isFinite && center.y.isFinite {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: snapshot.date)
            let minute = calendar.component(.minute, from: snapshot.date)
            let second = calendar.component(.second, from: snapshot.date)

            let hourAngle = (Double(hour % 12) + Double(minute) / 60.0 + Double(second) / 3600.0) * 30.0
            let minuteAngle = (Double(minute) + Double(second) / 60.0) * 6.0
            let secondAngle = Double(second) * 6.0

            let hourHandLength = max(1, radius * 0.46)
            let hourHandTail: CGFloat = 4.0
            let minuteHandLength = max(1, radius * 0.72)
            let minuteHandTail: CGFloat = 4.0
            let secondHandLength = max(1, radius * 0.82)
            let secondHandTail = max(1, radius * 0.26)

            let hourTotalHeight = max(1, hourHandLength + hourHandTail)
            let minuteTotalHeight = max(1, minuteHandLength + minuteHandTail)
            let secondTotalHeight = max(1, secondHandLength + secondHandTail)

            // Hour Hand with Center Anchoring
            RoundedRectangle(cornerRadius: 2.6, style: .continuous)
                .fill(handColor)
                .frame(width: 5.0, height: hourTotalHeight)
                .offset(y: -(hourHandLength - hourHandTail) / 2)
                .rotationEffect(.degrees(hourAngle))
                .shadow(color: Color.black.opacity(isDark ? 0.40 : 0.16), radius: 2, x: 0, y: 1)
                .position(center)

            // Minute Hand with Center Anchoring
            RoundedRectangle(cornerRadius: 1.6, style: .continuous)
                .fill(handColor)
                .frame(width: 3.2, height: minuteTotalHeight)
                .offset(y: -(minuteHandLength - minuteHandTail) / 2)
                .rotationEffect(.degrees(minuteAngle))
                .shadow(color: Color.black.opacity(isDark ? 0.35 : 0.14), radius: 2, x: 0, y: 1)
                .position(center)

            // Second Hand with Tail
            Capsule()
                .fill(secondHandColor)
                .frame(width: 1.5, height: secondTotalHeight)
                .offset(y: -(secondHandLength - secondHandTail) / 2)
                .rotationEffect(.degrees(secondAngle))
                .shadow(color: Color.black.opacity(isDark ? 0.30 : 0.12), radius: 1.5, x: 0, y: 1)
                .position(center)

            // Center Pivot Hub Disc
            Circle()
                .fill(secondHandColor)
                .frame(width: 7.5, height: 7.5)
                .shadow(color: Color.black.opacity(isDark ? 0.35 : 0.15), radius: 1.5, x: 0, y: 1)
                .position(center)

            // Center Arbor Pin Dot
            Circle()
                .fill(isDark ? Color.black.opacity(0.85) : Color(red: 0.15, green: 0.05, blue: 0.05))
                .frame(width: 2.2, height: 2.2)
                .position(center)
        }
    }
}

#Preview("Clock - Light") {
    ClockWidget()
        .frame(width: 170, height: 170)
        .environment(\.colorScheme, ColorScheme.light)
}

#Preview("Clock - Dark") {
    ClockWidget()
        .frame(width: 170, height: 170)
        .environment(\.colorScheme, ColorScheme.dark)
}
