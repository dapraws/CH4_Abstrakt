import SwiftUI

struct LibraryScreen: View {
    @State private var selectedSize: WidgetSize = .small

    private var sizeCounts: [WidgetSize: Int] {
        Dictionary(grouping: WidgetCatalog.items, by: \.size).mapValues(\.count)
    }

    private var filteredItems: [WidgetCatalogItem] {
        WidgetCatalog.items.filter { $0.size == selectedSize }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            libraryBackdrop

            ScrollFadeView(showsIndicators: false, headerHeight: 78, contentTopPadding: 6) { fadeProgress in
                libraryHeader(fadeProgress: fadeProgress)
            } content: {
                LazyVStack(spacing: 0) {
                    ForEach(filteredItems) { item in
                        LibraryWidgetRow(item: item)
                    }
                }
            }

        }
        .background(Color.clear)
    }

    private func libraryHeader(fadeProgress: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(Double(0.68 + (0.16 * fadeProgress)))
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: 0.68),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .top)

            AppColors.appBackground
                .opacity(Double(0.16 + (0.14 * fadeProgress)))
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .ignoresSafeArea(edges: .top)

            sizePicker
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)
        }
    }

    private var sizePicker: some View {
        HStack(spacing: 12) {
            ForEach(WidgetSize.allCases) { size in
                Button {
                    selectedSize = size
                } label: {
                    Text("\(size.title) (\(sizeCounts[size, default: 0]))")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(selectedSize == size ? AppColors.chipTextSelected : AppColors.primaryText.opacity(0.64))
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(selectedSize == size ? AppColors.chipSelected : AppColors.chip.opacity(0.58))
                        .overlay {
                            RoundedRectangle(cornerRadius: 25, style: .continuous)
                                .stroke(selectedSize == size ? AppColors.chipBorderSelected : AppColors.chipBorder, lineWidth: 0.5)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var libraryBackdrop: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            AppColors.appBackground
                .opacity(0.28)
        }
        .ignoresSafeArea()
    }

}

private struct LibraryWidgetRow: View {
    let item: WidgetCatalogItem

    var body: some View {
        GeometryReader { proxy in
            let textWidth = max(112, proxy.size.width - AppSpacing.screenHorizontal - previewFrameWidth - contentGap - previewTrailingInset)

            ZStack(alignment: .trailing) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("\(item.displayName) | \(item.primaryCategory.title)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                        .truncationMode(.tail)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 7) {
                        Image(systemName: item.primaryCategory.systemImage)
                            .font(.system(size: 16, weight: .bold))

                        Text(item.primaryCategory.title)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .foregroundStyle(AppColors.secondaryText)
                }
                .frame(width: textWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, AppSpacing.screenHorizontal)

                ZStack(alignment: .leading) {
                    WidgetCard(item: item, showsTitle: false)
                        .frame(width: previewContentWidth)
                        .scaleEffect(previewScale, anchor: .leading)
                        .rotationEffect(.degrees(rotationDegrees), anchor: .center)
                        .offset(x: previewContentOffset, y: previewYOffset)
                }
                .frame(width: previewFrameWidth, height: rowHeight, alignment: .leading)
                .padding(.trailing, previewTrailingInset)
                .clipped()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: rowHeight)
        .clipped()
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppColors.primaryText.opacity(0.12))
                .frame(height: 1)
                .padding(.leading, AppSpacing.screenHorizontal)
        }
    }

    private var rowHeight: CGFloat {
        switch item.size {
        case .small:
            150
        case .medium:
            160
        case .large:
            168
        }
    }

    private var contentGap: CGFloat {
        switch item.size {
        case .small:
            8
        case .medium:
            10
        case .large:
            12
        }
    }

    private var previewTrailingInset: CGFloat {
        switch item.size {
        case .small:
            16
        case .medium:
            6
        case .large:
            4
        }
    }

    private var previewFrameWidth: CGFloat {
        previewVisibleWidth + rotationBleed
    }

    private var rotationBleed: CGFloat {
        switch item.size {
        case .small:
            14
        case .medium:
            18
        case .large:
            24
        }
    }

    private var previewVisibleWidth: CGFloat {
        switch item.size {
        case .small:
            164
        case .medium:
            220
        case .large:
            230
        }
    }

    private var previewContentWidth: CGFloat {
        switch item.size {
        case .small:
            168
        case .medium:
            250
        case .large:
            480
        }
    }

    private var previewScale: CGFloat {
        switch item.size {
        case .small:
            0.96
        case .medium:
            0.82
        case .large:
            0.44
        }
    }

    private var previewContentOffset: CGFloat {
        switch item.size {
        case .small:
            rotationBleed * 0.5
        case .medium:
            rotationBleed * 0.5
        case .large:
            rotationBleed * 0.5
        }
    }

    private var previewYOffset: CGFloat {
        switch item.size {
        case .small:
            32
        case .medium:
            32
        case .large:
            32
        }
    }

    private var rotationDegrees: Double {
        let seed = item.id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        let angles = [-1.8, 1.2, -1.1, 1.6, -0.7]
        return angles[seed % angles.count]
    }
}

#Preview {
    LibraryScreen()
}
