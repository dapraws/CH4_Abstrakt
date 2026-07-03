//
//  HeartRateWidget.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 02/07/26.
//

import SwiftUI
import WidgetKit

// MARK: - Render Snapshot

struct HeartRateRenderSnapshot: Codable, Hashable {
    let bpm: Int
    let timestamp: Date

    var bpmLabel: String {
        bpm > 0 ? "\(bpm)" : "--"
    }

    var hasData: Bool {
        bpm > 0
    }
}

#if !WIDGET_EXTENSION
    extension HeartRateRenderSnapshot {
        init(snapshot: HeartRateSnapshot) {
            self.init(
                bpm: snapshot.bpm,
                timestamp: snapshot.timestamp
            )
        }
    }
#endif

// MARK: - Widget

struct HeartRateWidget: View {
    let snapshot: HeartRateRenderSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape: Bool

    @Environment(\.colorScheme) private var colorScheme

    private let heartColor = Color(red: 1.0, green: 0.23, blue: 0.35)

    init(
        snapshot: HeartRateRenderSnapshot,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    #if !WIDGET_EXTENSION
        init(
            fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
            clipsToWidgetShape: Bool = true
        ) {
            self.init(
                snapshot: HeartRateRenderSnapshot(
                    bpm: 93,
                    timestamp: Date.now.addingTimeInterval(-47)
                ),
                fontTheme: fontTheme,
                clipsToWidgetShape: clipsToWidgetShape
            )
        }
    #endif

    // MARK: Body

    var body: some View {
        #if WIDGET_EXTENSION
        widgetContent
            .containerBackground(palette.background, for: .widget)
        #else
        ZStack {
            palette.background
            widgetContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? 22 : 0,
                style: .continuous
            )
        )
        #endif
    }

    // MARK: Content

    private var widgetContent: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Image("heart-color")
                    .resizable()
                    .frame(width: 42, height: 42)
            }
            Spacer()

            Text("Heart rate")
                .font(AbstraktWidgetFonts.font(.bodyBold, theme: fontTheme))
                .foregroundStyle(palette.foreground)
            
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text(snapshot.bpmLabel)
                    .font(AbstraktWidgetFonts.font(.display, theme: fontTheme))
                    .foregroundStyle(palette.foreground)

                Text("BPM")
                    .font(AbstraktWidgetFonts.font(.subDisplay, theme: fontTheme))
                    .foregroundStyle(heartColor)
            }
            
            if snapshot.hasData {
                Text("\(snapshot.timestamp, style: .relative) ago")
                    .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                    .foregroundStyle(palette.tertiaryForeground)
            } else {
                Text("No data")
                    .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                    .foregroundStyle(palette.tertiaryForeground)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
    }

    // MARK: Palette

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

// MARK: - Preview

#Preview("Heart Rate") {
    ZStack {
        Rectangle().fill(Color.blue)
        HeartRateWidget(
            snapshot: HeartRateRenderSnapshot(
                bpm: 93,
                timestamp: Date.now.addingTimeInterval(-47)
            )
        )
        .frame(width: 170, height: 170)
    }
    .ignoresSafeArea()
}
