//
//  WeatherWidgetTwo.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 02/07/26.
//

import SwiftUI
import WidgetKit

// MARK: - Render Snapshot

struct SunEventWeatherSnapshot: Codable, Hashable {
    let temperature: Int
    let high: Int
    let low: Int
    let sunEventLabel: String   // "Sunrise" or "Sunset"
    let sunEventTime: String    // pre-formatted HH:mm, e.g. "06:24"
    let sunEventIcon: String    // asset name: "sunrise" or "sunset"

    private var usesFahrenheit: Bool {
        UserDefaults(suiteName: Bundle.main.object(forInfoDictionaryKey: "AppGroupID") as? String ?? "group.default.abstrakt")?
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

extension SunEventWeatherSnapshot {
    static let placeholder = SunEventWeatherSnapshot(
        temperature: 25,
        high: 30,
        low: 20,
        sunEventLabel: "Sunset",
        sunEventTime: "18:12",
        sunEventIcon: "sunset"
    )
}

// MARK: - Widget

struct SunEventWeatherWidget: View {
    let snapshot: SunEventWeatherSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    /// Same transparent-padding trim as ClassicWeatherWidget.
    var iconTrim: CGFloat = 1.5

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: SunEventWeatherSnapshot = .placeholder,
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
            // Top row: icon left, sun event text right
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
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

// MARK: - Preview

#Preview("SunEventWeatherWidget — Light") {
    ZStack {
        Color.black.ignoresSafeArea()
        SunEventWeatherWidget(
            snapshot: SunEventWeatherSnapshot(
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

#Preview("SunEventWeatherWidget — Dark") {
    ZStack {
        Color.white.ignoresSafeArea()
        SunEventWeatherWidget(
            snapshot: SunEventWeatherSnapshot(
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

#Preview("SunEventWeatherWidget — Fusion Pixel") {
    ZStack {
        Color.black.ignoresSafeArea()
        SunEventWeatherWidget(
            snapshot: SunEventWeatherSnapshot(
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
