//
//  DeviceStorageWidget.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 30/06/26.
//

import SwiftUI
import WidgetKit
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Render Snapshot

struct DeviceStorageRenderSnapshot: Codable, Hashable {
    let totalBytes: Int64
    let availableBytes: Int64

    var usedBytes: Int64 { totalBytes - availableBytes }

    var availableGB: Double {
        Double(availableBytes) / 1_000_000_000.0
    }

    var usedGB: Double {
        Double(max(0, usedBytes)) / 1_000_000_000.0
    }

    var totalGB: Double {
        Double(totalBytes) / 1_000_000_000.0
    }

    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return min(max(Double(usedBytes) / Double(totalBytes), 0), 1)
    }

    var availableFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return min(max(Double(availableBytes) / Double(totalBytes), 0), 1)
    }

    var availableLabel: String {
        Self.gigabyteLabel(availableGB)
    }

    var usedLabel: String {
        Self.gigabyteLabel(usedGB)
    }

    var totalLabel: String {
        Self.gigabyteLabel(totalGB)
    }

    var segments: [StorageSegment] {
        [
            StorageSegment(name: "Used", fraction: usedFraction, color: .used),
            StorageSegment(name: "Available", fraction: availableFraction, color: .available),
        ]
    }

    private static func gigabyteLabel(_ value: Double) -> String {
        value >= 100
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}

#if !WIDGET_EXTENSION
extension DeviceStorageRenderSnapshot {
    init(snapshot: StorageSnapshot) {
        self.init(
            totalBytes: snapshot.totalBytes,
            availableBytes: snapshot.availableBytes
        )
    }
}
#endif

// MARK: - Segment Types

enum StorageSegmentColor: String, Codable, Hashable {
    case used, available

    var color: Color {
        switch self {
        case .used:
            Color(red: 1.0, green: 0.34, blue: 0.27)
        case .available:
            #if canImport(UIKit)
            Color(uiColor: UIColor { traits in
                traits.userInterfaceStyle == .dark
                    ? UIColor(red: 0.26, green: 0.26, blue: 0.27, alpha: 1)
                : UIColor(red: 0.63, green: 0.63, blue: 0.67, alpha: 0.4)
            })
            #else
            Color(red: 0.63, green: 0.63, blue: 0.67)
            #endif
        }
    }
}

struct StorageSegment: Codable, Hashable {
    let name: String
    let fraction: Double
    let color: StorageSegmentColor
}

// MARK: - Widget

struct DeviceStorageWidget: View {
    let snapshot: DeviceStorageRenderSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape: Bool

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: DeviceStorageRenderSnapshot,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    #if !WIDGET_EXTENSION
    init(
        snapshot: StorageSnapshot = StorageProvider.currentSnapshot(),
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.init(
            snapshot: DeviceStorageRenderSnapshot(snapshot: snapshot),
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
            Text("DEVICE STORAGE")
                .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                .foregroundStyle(palette.foreground)

            Spacer().frame(height: 10)

            storageBar

            Spacer().frame(height: 10)

            storageLegend
            
            Spacer()

            VStack(alignment: .leading, spacing: 2) {
                Text("Available")
                    .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                    .foregroundStyle(palette.tertiaryForeground)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(snapshot.availableLabel)
                        .font(AbstraktWidgetFonts.font(.title, theme: fontTheme))
                        .foregroundStyle(palette.foreground)

                    Text("GB")
                        .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                        .foregroundStyle(palette.tertiaryForeground)
                }
            }
        }
        .padding(.horizontal, 15)
        .padding(.top, 15)
        .padding(.bottom, 10)
    }

    // MARK: Storage Bar

    private var storageBar: some View {
        GeometryReader { proxy in
            let containerPadding: CGFloat = 1.5
            let segmentSpacing: CGFloat = 1.5
            let availableWidth = max(0, proxy.size.width - (containerPadding * 2) - segmentSpacing)

            ZStack {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.gray.opacity(0.2))

                HStack(spacing: segmentSpacing) {
                    ForEach(snapshot.segments, id: \.name) { segment in
                        storageSegmentFill(segment)
                            .frame(width: segmentWidth(for: segment, availableWidth: availableWidth))
                            .clipShape(RoundedRectangle(cornerRadius: 3, style: .continuous))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .padding(containerPadding)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .stroke(Color.clear, lineWidth: 1)
            )
        }
        .frame(height: 24)
    }

    @ViewBuilder
    private func storageSegmentFill(_ segment: StorageSegment) -> some View {
        switch segment.color {
        case .used:
            Rectangle()
                .fill(segment.color.color)
        case .available:
            Rectangle()
                .fill(segment.color.color)
                .overlay(alignment: .center) {
                    DiagonalStripePattern(color: palette.storageBarStripe)
                }
        }
    }

    private func segmentWidth(for segment: StorageSegment, availableWidth: CGFloat) -> CGFloat {
        guard segment.fraction > 0 else {
            return 0
        }

        return max(4, availableWidth * segment.fraction)
    }

    // MARK: Legend

    private var storageLegend: some View {
        HStack(spacing: 12) {
            legendItem(snapshot.segments[0])
            legendItem(snapshot.segments[1])
        }
    }

    private func legendItem(_ segment: StorageSegment) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(segment.color.color)
                .frame(width: 6, height: 6)

            Text(segment.name)
                .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
                .foregroundStyle(palette.secondaryForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
    }

    // MARK: Palette

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }
}

private struct DiagonalStripePattern: View {
    let color: Color

    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 7
            let lineWidth: CGFloat = 2
            var path = Path()
            var x = -size.height

            while x < size.width {
                path.move(to: CGPoint(x: x, y: size.height))
                path.addLine(to: CGPoint(x: x + size.height, y: 0))
                x += spacing
            }

            context.stroke(path, with: .color(color), lineWidth: lineWidth)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Preview

#Preview("Device Storage") {
    ZStack{
        Rectangle().fill(Color.blue)
        DeviceStorageWidget(
            snapshot: DeviceStorageRenderSnapshot(
                totalBytes: 256_060_514_304,
                availableBytes: 233_390_000_000
            )
        )
        .frame(width: 170, height: 170)
    }
    .ignoresSafeArea()
}
