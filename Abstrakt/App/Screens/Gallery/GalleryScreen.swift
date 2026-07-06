import SwiftUI

// MARK: - Row Model

private enum GalleryRow: Identifiable {
    case pair(WidgetCatalogItem, WidgetCatalogItem?)
    case single(WidgetCatalogItem)

    var id: String {
        switch self {
        case let .pair(first, second):
            "\(first.id)-\(second?.id ?? "empty")"
        case let .single(entry):
            entry.id
        }
    }
}

// MARK: - Width Measurement

private struct GalleryRowWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

/// Reports row width without imposing a row height, so card titles keep their natural layout.
private struct GalleryRowWidthReporter: View {
    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: GalleryRowWidthKey.self,
                value: proxy.size.width
            )
        }
    }
}

// MARK: - Gallery Screen

struct GalleryScreen: View {
    // MARK: State

    @State private var selectedCategory: WidgetCategory = .all

    // MARK: Properties

    private let featuredCategories = WidgetCatalog.featuredCategories
    private let onSelectItem: (WidgetCatalogItem) -> Void

    private typealias GalleryEntry = WidgetCatalogItem

    init(onSelectItem: @escaping (WidgetCatalogItem) -> Void = { _ in }) {
        self.onSelectItem = onSelectItem
    }

    // MARK: Data

    private var filteredEntries: [GalleryEntry] {
        WidgetCatalog.galleryItems(for: selectedCategory)
    }

    private var galleryRows: [GalleryRow] {
        var rows: [GalleryRow] = []

        var index = 0
        while index < filteredEntries.count {
            let current = filteredEntries[index]

            if current.size == .small {
                let nextIndex = index + 1
                if nextIndex < filteredEntries.count, filteredEntries[nextIndex].size == .small {
                    rows.append(.pair(current, filteredEntries[nextIndex]))
                    index += 2
                } else {
                    rows.append(.pair(current, nil))
                    index += 1
                }
            } else {
                rows.append(.single(current))
                index += 1
            }
        }

        return rows
    }

    // MARK: Body

    var body: some View {
        galleryContent
    }

    // MARK: Content

    private var galleryContent: some View {
        ScrollFadeView(showsIndicators: false, headerHeight: 48, contentTopPadding: 12) { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.chipGap) {
                        ForEach(featuredCategories) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                CategoryChip(category: category, isSelected: selectedCategory == category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                }
                .padding(.horizontal, -AppSpacing.screenHorizontal)
                .scrollClipDisabled()
            }
        } content: {
            LazyVStack(alignment: .leading, spacing: AppSpacing.cardGap) {
                ForEach(galleryRows) { row in
                    GalleryRowView(row: row, onSelectItem: onSelectItem)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .background(AppColors.appBackground)
    }
}

// MARK: - Gallery Row

private struct GalleryRowView: View {
    let row: GalleryRow
    let onSelectItem: (WidgetCatalogItem) -> Void
    @State private var availableWidth: CGFloat = 0

    var body: some View {
        rowContent(availableWidth: availableWidth)
            .frame(maxWidth: .infinity)
            .background(GalleryRowWidthReporter())
            .onPreferenceChange(GalleryRowWidthKey.self, perform: updateAvailableWidth)
    }

    @ViewBuilder
    private func rowContent(availableWidth: CGFloat) -> some View {
        switch row {
        case let .single(entry):
            let previewWidth = previewWidth(for: entry.size, availableWidth: availableWidth)

            Button {
                onSelectItem(entry)
            } label: {
                WidgetCard(item: entry, maximumPreviewWidth: previewWidth, maximumPreviewScale: maximumScale(for: entry.size))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .center)

        case let .pair(first, second):
            let spacing = pairSpacing(for: availableWidth)
            let previewWidth = previewWidth(for: first.size, availableWidth: max(0, (availableWidth - spacing) / 2))

            HStack(alignment: .top, spacing: spacing) {
                Button {
                    onSelectItem(first)
                } label: {
                    WidgetCard(item: first, maximumPreviewWidth: previewWidth, maximumPreviewScale: maximumScale(for: first.size))
                }
                .buttonStyle(.plain)

                if let second {
                    Button {
                        onSelectItem(second)
                    } label: {
                        WidgetCard(item: second, maximumPreviewWidth: previewWidth, maximumPreviewScale: maximumScale(for: second.size))
                    }
                    .buttonStyle(.plain)
                } else {
                    Spacer(minLength: 0)
                        .frame(width: previewWidth)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private func pairSpacing(for availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth * 0.055, 14), 22)
    }

    private func previewWidth(for size: WidgetSize, availableWidth: CGFloat) -> CGFloat {
        min(max(availableWidth, 0), size.previewWidth * maximumScale(for: size))
    }

    private func maximumScale(for size: WidgetSize) -> CGFloat {
        switch size {
        case .small:
            1.14
        case .medium:
            1.16
        case .large:
            1.08
        }
    }

    private func updateAvailableWidth(_ width: CGFloat) {
        guard width > 0, abs(availableWidth - width) > 0.5 else { return }
        availableWidth = width
    }
}

#Preview {
    GalleryScreen()
}
