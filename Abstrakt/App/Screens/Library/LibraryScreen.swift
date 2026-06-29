import SwiftUI

struct LibraryScreen: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedSize: WidgetSize = .small

    private var sizeCounts: [WidgetSize: Int] {
        Dictionary(grouping: WidgetPreset.seededLibrary, by: \.size).mapValues(\.count)
    }

    private func presets(for size: WidgetSize) -> [WidgetPreset] {
        WidgetPreset.seededLibrary.filter { $0.size == size }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            libraryBackdrop

            TabView(selection: $selectedSize) {
                ForEach(WidgetSize.allCases) { size in
                    LibrarySizePage(
                        size: size,
                        presets: presets(for: size),
                        palette: palette,
                        headerHeight: headerHeight
                    )
                    .tag(size)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack(spacing: 0) {
                libraryHeader
                    .frame(height: headerHeight)
                    .zIndex(1)

                Spacer(minLength: 0)
            }
        }
        .background(Color.clear)
    }

    private var palette: LibraryPalette {
        LibraryPalette(colorScheme: colorScheme)
    }

    private var headerHeight: CGFloat {
        70
    }

    private var libraryHeader: some View {
        FadingNavigationBar(fadeProgress: 1) {
            sizePicker
        }
    }

    private var sizePicker: some View {
        HStack(spacing: 12) {
            ForEach(WidgetSize.allCases) { size in
                Button {
                    selectedSize = size
                } label: {
                    Text("\(size.title) (\(sizeCounts[size, default: 0]))")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(selectedSize == size ? palette.chipTextSelected : palette.chipText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(selectedSize == size ? palette.chipSelected : palette.chip)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var libraryBackdrop: some View {
        ZStack {
            palette.background

            RadialGradient(
                colors: [
                    palette.backgroundWash,
                    Color.clear,
                ],
                center: .bottom,
                startRadius: 24,
                endRadius: 420
            )

            palette.scrim
        }
        .ignoresSafeArea()
    }

}

private struct LibraryPalette {
    let colorScheme: ColorScheme

    var isDark: Bool {
        colorScheme == .dark
    }

    var background: Color {
        isDark ? Color(red: 0.16, green: 0.16, blue: 0.18) : AppColors.appBackground
    }

    var backgroundWash: Color {
        isDark ? Color(red: 0.46, green: 0.26, blue: 0.46).opacity(0.28) : Color.white.opacity(0.46)
    }

    var scrim: Color {
        isDark ? Color.black.opacity(0.1) : Color.white.opacity(0.08)
    }

    var chip: Color {
        isDark ? Color.white.opacity(0.16) : Color.white.opacity(0.66)
    }

    var chipSelected: Color {
        isDark ? Color.white : Color(red: 0.08, green: 0.08, blue: 0.1)
    }

    var chipText: Color {
        primaryText.opacity(0.62)
    }

    var chipTextSelected: Color {
        isDark ? Color(red: 0.08, green: 0.08, blue: 0.1) : Color.white
    }

    var primaryText: Color {
        isDark ? Color.white : Color(red: 0.08, green: 0.08, blue: 0.1)
    }

    var secondaryText: Color {
        primaryText.opacity(0.5)
    }

    var separator: Color {
        primaryText.opacity(0.12)
    }
}

private struct LibrarySizePage: View {
    let size: WidgetSize
    let presets: [WidgetPreset]
    let palette: LibraryPalette
    let headerHeight: CGFloat

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0) {
                if presets.isEmpty {
                    LibraryEmptyState(size: size, palette: palette)
                } else {
                    ForEach(presets) { preset in
                        LibraryWidgetRow(preset: preset, palette: palette)
                    }
                }
            }
            .padding(.top, headerHeight - 10)
            .padding(.bottom, 140)
        }
    }
}

private struct LibraryEmptyState: View {
    let size: WidgetSize
    let palette: LibraryPalette

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: emptyIcon)
                .font(AppFonts.font(.title))
                .foregroundStyle(palette.secondaryText)
                .frame(width: 68, height: 68)
                .background(palette.chip)
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))

            VStack(spacing: 6) {
                Text("No \(size.title.lowercased()) widgets")
                    .font(AppFonts.font(.heading2))
                    .foregroundStyle(palette.primaryText)

                Text("Saved \(size.title.lowercased()) widgets will appear here.")
                    .font(AppFonts.font(.body))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 128)
    }

    private var emptyIcon: String {
        switch size {
        case .small:
            "square"
        case .medium:
            "rectangle"
        case .large:
            "rectangle.grid.1x2"
        }
    }
}

private struct LibraryWidgetRow: View {
    let preset: WidgetPreset
    let palette: LibraryPalette

    private var item: WidgetCatalogItem? {
        WidgetCatalog.item(withID: preset.widgetID)
    }

    private var displayName: String {
        preset.name
    }

    private var category: WidgetCategory {
        item?.primaryCategory ?? .all
    }

    private var size: WidgetSize {
        preset.size
    }

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = proxy.size.width - AppSpacing.screenHorizontal
            let textWidth = min(contentWidth * textWidthRatio, maximumTextWidth)
            let previewColumnWidth = max(0, contentWidth - textWidth - contentGap)
            let previewSize = scaledPreviewSize

            HStack(alignment: .top, spacing: contentGap) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(displayName)
                        .font(AppFonts.font(titleFontRole))
                        .foregroundStyle(palette.primaryText)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 7) {
                        Image(systemName: category.systemImage)
                            .font(AppFonts.font(categoryFontRole))

                        Text(category.title)
                            .font(AppFonts.font(categoryFontRole))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .foregroundStyle(palette.secondaryText)
                }
                .frame(width: textWidth, height: rowHeight - textBottomPadding, alignment: .bottomLeading)
                .padding(.bottom, textBottomPadding)

                ZStack(alignment: .topLeading) {
                    if let item {
                        WidgetPreview(item: item)
                            .frame(width: size.previewWidth, height: size.previewHeight)
                            .scaleEffect(previewScale, anchor: .topLeading)
                            .frame(width: previewSize.width, height: previewSize.height, alignment: .topLeading)
                            .rotationEffect(.degrees(rotationDegrees), anchor: .center)
                            .offset(x: previewXOffset, y: previewYOffset)
                    }
                }
                .frame(width: previewColumnWidth, height: rowHeight, alignment: .topLeading)
                .clipped()
            }
            .padding(.leading, AppSpacing.screenHorizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity)
        .frame(height: rowHeight)
        .clipped()
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(palette.separator)
                .frame(height: 1)
                .padding(.leading, AppSpacing.screenHorizontal)
        }
    }

    private var rowHeight: CGFloat {
        switch size {
        case .small:
            170
        case .medium:
            170
        case .large:
            184
        }
    }

    private var contentGap: CGFloat {
        switch size {
        case .small:
            20
        case .medium:
            10
        case .large:
            12
        }
    }

    private var textWidthRatio: CGFloat {
        switch size {
        case .small:
            0.4
        case .medium:
            0.3
        case .large:
            0.5
        }
    }

    private var maximumTextWidth: CGFloat {
        switch size {
        case .small:
            150
        case .medium:
            120
        case .large:
            186
        }
    }

    private var scaledPreviewSize: CGSize {
        CGSize(
            width: size.previewWidth * previewScale,
            height: size.previewHeight * previewScale
        )
    }

    private var previewScale: CGFloat {
        switch size {
        case .small:
            0.96
        case .medium:
            0.64
        case .large:
            0.56
        }
    }

    private var textBottomPadding: CGFloat {
        switch size {
        case .small:
            34
        case .medium:
            32
        case .large:
            36
        }
    }

    private var previewXOffset: CGFloat {
        switch size {
        case .small:
            20
        case .medium:
            10
        case .large:
            0
        }
    }

    private var previewYOffset: CGFloat {
        switch size {
        case .small:
            48
        case .medium:
            72
        case .large:
            24
        }
    }

    private var titleFontRole: AppFontRole {
        switch size {
        case .small:
            .heading2
        case .medium:
            .heading3
        case .large:
            .heading3
        }
    }

    private var categoryFontRole: AppFontRole {
        switch size {
        case .small:
            .heading3
        case .medium:
            .chip
        case .large:
            .chip
        }
    }

    private var rotationDegrees: Double {
        let seed = preset.widgetID.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let angles = [-1.8, 1.2, -1.1, 1.6, -0.7]
        return angles[seed % angles.count]
    }
}

#Preview {
    LibraryScreen()
}
