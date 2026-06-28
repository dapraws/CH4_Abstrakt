import SwiftUI

struct GalleryScreen: View {
    @State private var selectedCategory: WidgetCategory = .all

    private let featuredCategories: [WidgetCategory] = [.all, .classic, .portal, .health, .weather, .clock]

    private typealias GalleryEntry = WidgetCatalogItem

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

    var body: some View {
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
                    .padding(.trailing, 40)
                }
                .padding(.horizontal, -AppSpacing.screenHorizontal)
                .scrollClipDisabled()
            }
        } content: {
            VStack(alignment: .leading, spacing: 22) {
                LazyVStack(alignment: .leading, spacing: 22) {
                    ForEach(galleryRows) { row in
                        switch row {
                        case let .single(entry):
                            WidgetCard(item: entry)
                        case let .pair(first, second):
                            HStack(alignment: .top, spacing: 22) {
                                WidgetCard(item: first)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)

                                if let second {
                                    WidgetCard(item: second)
                                        .frame(maxWidth: .infinity, alignment: .topLeading)
                                } else {
                                    Spacer()
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .background(AppColors.appBackground)
    }
}

#Preview {
    GalleryScreen()
}
