//
//  DeviceStorageWidget.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 30/06/26.
//

import SwiftUI

// MARK: - Render Snapshot

struct DeviceStorageRenderSnapshot: Codable, Hashable {
    let totalBytes: Int64
    let availableBytes: Int64

    var usedBytes: Int64 { totalBytes - availableBytes }

    var availableGB: Double {
        Double(availableBytes) / 1_073_741_824.0
    }

    var totalGB: Double {
        Double(totalBytes) / 1_073_741_824.0
    }

    var usedFraction: Double {
        guard totalBytes > 0 else { return 0 }
        return Double(usedBytes) / Double(totalBytes)
    }

    var availableLabel: String {
        String(
            format: "%.0f,%02.0f",
            floor(availableGB),
            (availableGB - floor(availableGB)) * 100
        )
    }

    var categories: [StorageCategory] {
        let used = usedFraction
        return [
            StorageCategory(name: "Apps", fraction: used * 0.45, color: .appsRed),
            StorageCategory(name: "Photos", fraction: used * 0.20, color: .photosBlue),
            StorageCategory(name: "Media", fraction: used * 0.20, color: .mediaPurple),
            StorageCategory(name: "System", fraction: used * 0.15, color: .systemGray),
        ]
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

// MARK: - Category Types

enum StorageCategoryColor: String, Codable, Hashable {
    case appsRed, photosBlue, mediaPurple, systemGray

    var color: Color {
        switch self {
        case .appsRed:
            Color(red: 1.0, green: 0.27, blue: 0.23)
        case .photosBlue:
            Color(red: 0.35, green: 0.48, blue: 1.0)
        case .mediaPurple:
            Color(red: 0.58, green: 0.39, blue: 0.98)
        case .systemGray:
            Color(red: 0.56, green: 0.56, blue: 0.58)
        }
    }
}

struct StorageCategory: Codable, Hashable {
    let name: String
    let fraction: Double
    let color: StorageCategoryColor
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

            legendGrid
            
            Spacer().frame(height: 10)

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
        .padding(15)
    }

    // MARK: Storage Bar

    private var storageBar: some View {
        GeometryReader { proxy in
            HStack(spacing: 1) {
                ForEach(snapshot.categories, id: \.name) { category in
                    RoundedRectangle(cornerRadius: 1, style: .continuous)
                        .fill(category.color.color)
                        .frame(width: max(4, proxy.size.width * category.fraction))
                        .padding(.vertical, 1)
                }
            }
        }
        .frame(height: 24)
        .background(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(palette.subtleFill)
        )
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
    }

    // MARK: Legend Grid

    private var legendGrid: some View {
        let rows = stride(from: 0, to: snapshot.categories.count, by: 2)
            .map { Array(snapshot.categories[$0..<min($0 + 2, snapshot.categories.count)]) }

        return VStack(alignment: .leading, spacing: 6) {
            ForEach(rows, id: \.first?.name) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.name) { category in
                        legendItem(category)
                    }
                }
            }
        }
    }

    private func legendItem(_ category: StorageCategory) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(category.color.color)
                .frame(width: 6, height: 6)

            Text(category.name)
                .font(AbstraktWidgetFonts.font(.meta, theme: fontTheme))
                .foregroundStyle(palette.secondaryForeground)
        }
    }

    // MARK: Palette

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
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
