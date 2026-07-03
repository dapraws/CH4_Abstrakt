//
//  WeatherWidgetTwo.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 02/07/26.
//

import SwiftUI
import WidgetKit

// MARK: - Render Snapshot

struct DaylightSnapshot: Codable, Hashable {
    let temperature: Int
    let high: Int
    let low: Int
    let sunEventLabel: String   // "Sunrise" or "Sunset"
    let sunEventTime: String    // pre-formatted HH:mm, e.g. "06:24"
    let sunEventIcon: String    // asset name: "sunrise" or "sunset"

    private var usesFahrenheit: Bool {
        UserDefaults(suiteName: Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String ?? "group.daffa.abstrakt")?
            .string(forKey: "settings.temperatureUnit") == "fahrenheit"
    }

    var displayTemperature: Int { convertedFromCelsius(temperature) }
    var displayHigh: Int { convertedFromCelsius(high) }
    var displayLow: Int { convertedFromCelsius(low) }

    private func convertedFromCelsius(_ celsius: Int) -> Int {
        guard usesFahrenheit else { return celsius }
        return Int((Double(celsius) * 9.0 / 5.0 + 32.0).rounded())
    }
}

// MARK: - Placeholder

extension DaylightSnapshot {
    static let placeholder = DaylightSnapshot(
        temperature: 25,
        high: 30,
        low: 20,
        sunEventLabel: "Sunset",
        sunEventTime: "18:12",
        sunEventIcon: "sunset"
    )
}

// MARK: - Widget

struct DaylightWidget: View {
    let snapshot: DaylightSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    /// Same transparent-padding trim as WeatherWidget.
    var iconTrim: CGFloat = 1.5

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: DaylightSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true,
        iconTrim: CGFloat = 1.5
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
        self.iconTrim = iconTrim
    }

    // MARK: Body

    var body: some View {
        ZStack {
            if clipsToWidgetShape {
                palette.background
            }
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

    // MARK: Content

    private var widgetContent: some View {
        VStack(alignment: .leading) {
            // Top row: icon left, daylight text right
            HStack(alignment: .center) {
                Image(snapshot.sunEventIcon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50 * iconTrim, height: 50 * iconTrim)
                    .frame(width: 50, height: 50)
                    .clipped()

                Spacer()

                VStack(alignment: .leading, spacing: -2) {
                    Text(snapshot.sunEventLabel)
                        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                        .foregroundStyle(palette.tertiaryForeground)
                        .lineLimit(1)

                    Text("at \(snapshot.sunEventTime)")
                        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                        .foregroundStyle(palette.foreground)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Bottom row: large temp left, H/L arrows right
            HStack(alignment: .center) {
                HStack(spacing: 0) {
                    Text("\(snapshot.displayTemperature)")
                        .font(AbstraktWidgetFonts.font(.title, theme: fontTheme))
                        .foregroundStyle(palette.foreground)

                    Text("°")
                        .font(AbstraktWidgetFonts.font(.title, theme: fontTheme))
                        .foregroundStyle(palette.foreground)
                        .offset(x: -1, y: -1)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrowtriangle.up.fill")
                            .foregroundStyle(palette.tertiaryForeground)
                        Text("\(snapshot.displayHigh)°")
                            .foregroundStyle(palette.foreground)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "arrowtriangle.down.fill")
                            .foregroundStyle(palette.tertiaryForeground)
                        Text("\(snapshot.displayLow)°")
                            .foregroundStyle(palette.foreground)
                    }
                }
                .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

// MARK: - Preview

#Preview("Daylight — Light") {
    ZStack {
        Color.black.ignoresSafeArea()
        DaylightWidget(
            snapshot: DaylightSnapshot(
                temperature: 27,
                high: 31,
                low: 21,
                sunEventLabel: "Sunset",
                sunEventTime: "18:12",
                sunEventIcon: "sunset"
            )
        )
        .frame(width: 170, height: 170)
    }
}

#Preview("Daylight — Dark") {
    ZStack {
        Color.white.ignoresSafeArea()
        DaylightWidget(
            snapshot: DaylightSnapshot(
                temperature: 18,
                high: 22,
                low: 14,
                sunEventLabel: "Sunrise",
                sunEventTime: "06:24",
                sunEventIcon: "sunrise"
            )
        )
        .frame(width: 170, height: 170)
    }
    .preferredColorScheme(.dark)
}

#Preview("Daylight — Fusion Pixel") {
    ZStack {
        Color.black.ignoresSafeArea()
        DaylightWidget(
            snapshot: DaylightSnapshot(
                temperature: 27,
                high: 31,
                low: 21,
                sunEventLabel: "Sunset",
                sunEventTime: "18:12",
                sunEventIcon: "sunset"
            ),
            fontTheme: .fusionPixel
        )
        .frame(width: 170, height: 170)
    }
}
