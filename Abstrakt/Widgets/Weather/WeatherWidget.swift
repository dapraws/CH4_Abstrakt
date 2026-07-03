//
//  WeatherWidget.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 01/07/26.
//

import SwiftUI
import WidgetKit

// MARK: - Render Snapshot

struct WeatherSnapshot: Codable, Hashable {
    let temperature: Int
    let high: Int
    let low: Int
    let conditionIcon: String   // asset name in WeatherIcons/
    let conditionLabel: String  // e.g. "Partly Cloudy"
    let locationName: String    // city / kabupaten from reverse geocoding

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

extension WeatherSnapshot {
    static let placeholder = WeatherSnapshot(
        temperature: 25,
        high: 30,
        low: 20,
        conditionIcon: "partlyCloudy-day",
        conditionLabel: "Partly Cloudy",
        locationName: "Jakarta"
    )
}

// MARK: - Widget

struct WeatherWidget: View {
    let snapshot: WeatherSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    /// Weather condition icon assets ship with built-in transparent padding.
    /// This scales the artwork up before clipping to its display frame so the
    /// visible glyph fills the frame instead of floating inside blank space.
    /// Tune this if the icon still looks off-center or too tight/loose.
    var iconTrim: CGFloat = 1.5

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: WeatherSnapshot = .placeholder,
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
            Image(snapshot.conditionIcon)
                .resizable()
                .scaledToFit()
                .frame(width: 40 * iconTrim, height: 40 * iconTrim)
                .frame(width: 40, height: 40)
                .clipped()
            
            Spacer()
    
            Text("\(snapshot.conditionLabel) in \(snapshot.locationName)")
                .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                .foregroundStyle(palette.foreground)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text("\(snapshot.displayTemperature)")
                        .font(AbstraktWidgetFonts.font(.title, theme: fontTheme))
                        .foregroundStyle(palette.foreground)

                    Text("°")
                        .font(AbstraktWidgetFonts.font(.title, theme: fontTheme))
                        .foregroundStyle(palette.foreground)
                        .offset(x: 0, y: -1)
                }

                HStack(spacing: 15) {
                    Text("L: \(snapshot.displayLow)")
                        .foregroundStyle(palette.tertiaryForeground)

                    Text("H: \(snapshot.displayHigh)")
                        .foregroundStyle(palette.tertiaryForeground)
                }
                .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

// MARK: - Preview

#Preview("Weather — Light") {
    ZStack {
        Color.black.ignoresSafeArea()
        WeatherWidget(
            snapshot: WeatherSnapshot(
                temperature: 27,
                high: 31,
                low: 21,
                conditionIcon: "partlyCloudy-day",
                conditionLabel: "Partly Cloudy",
                locationName: "Jakarta Selatan"
            )
        )
        .frame(width: 170, height: 170)
    }
}

#Preview("Weather — Dark") {
    ZStack {
        Color.white.ignoresSafeArea()
        WeatherWidget(
            snapshot: WeatherSnapshot(
                temperature: 18,
                high: 22,
                low: 14,
                conditionIcon: "rain",
                conditionLabel: "Rain",
                locationName: "Bandung"
            )
        )
        .frame(width: 170, height: 170)
    }
    .preferredColorScheme(.dark)
}


#Preview("Weather — Fusion Pixel") {
    ZStack {
        Color.black.ignoresSafeArea()

        WeatherWidget(
            snapshot: WeatherSnapshot(
                temperature: 23,
                high: 31,
                low: 21,
                conditionIcon: "partlyCloudy-day",
                conditionLabel: "Partly Cloudy",
                locationName: "Jakarta Selatan"
            ),
            fontTheme: .fusionPixel
        )
        .frame(width: 170, height: 170)
    }
}
