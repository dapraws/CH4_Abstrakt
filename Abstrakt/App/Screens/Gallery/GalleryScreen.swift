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

    private let featuredCategories: [WidgetCategory] = [.all, .classic, .portal, .health, .weather, .clock]
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

// MARK: - Preview Sheet Cover

struct WidgetPreviewSheetCover: View {
    let item: WidgetCatalogItem
    let onDismiss: () -> Void

    // MARK: Environment

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: State

    @State private var isPresented = false
    @State private var dragOffset: CGFloat = 0

    // MARK: Properties

    private let upwardResistanceLimit: CGFloat = 28

    // MARK: Body

    var body: some View {
        GeometryReader { proxy in
            let sheetHeight = proxy.size.height * 0.92
            let hiddenOffset = sheetHeight + upwardResistanceLimit

            ZStack(alignment: .bottom) {
                Color.black
                    .opacity(isPresented ? 0.24 : 0)
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        close()
                    }

                WidgetPreviewSheet(item: item)
                    .frame(width: proxy.size.width, height: sheetHeight)
                    .clipShape(UnevenRoundedRectangle(
                        topLeadingRadius: 42,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 42,
                        style: .continuous
                    ))
                    .background(alignment: .bottom) {
                        AppColors.appBackground
                            .frame(height: upwardResistanceLimit)
                            .frame(maxWidth: .infinity)
                            .offset(y: upwardResistanceLimit)
                    }
                    .overlay(alignment: .top) {
                        sheetDragHandle
                    }
                    .offset(y: isPresented ? dragOffset : hiddenOffset)
            }
            .ignoresSafeArea()
            .allowsHitTesting(isPresented)
            .onAppear {
                guard !reduceMotion else {
                    isPresented = true
                    return
                }
                
                withAnimation(.smooth(duration: 0.48, extraBounce: 0)) {
                    isPresented = true
                }
            }
        }
    }

    // MARK: Drag Handle

    private var sheetDragHandle: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(AppColors.primaryText.opacity(0.16))
                .frame(width: 48, height: 6)
                .padding(.top, 9)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .contentShape(Rectangle())
        .gesture(sheetDragGesture)
    }

    private var sheetDragGesture: some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .global)
            .onChanged { value in
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    dragOffset = interactiveDragOffset(value.translation.height)
                }
            }
            .onEnded { value in
                let shouldDismiss = value.translation.height > 90 || value.predictedEndTranslation.height > 180

                if shouldDismiss {
                    close()
                } else {
                    withAnimation(.interactiveSpring(response: 0.22, dampingFraction: 0.86)) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func interactiveDragOffset(_ translation: CGFloat) -> CGFloat {
        if translation >= 0 {
            return translation
        }

        return max(translation * 0.18, -upwardResistanceLimit)
    }

    // MARK: Actions

    private func close() {
        guard !reduceMotion else {
            onDismiss()
            return
        }

        withAnimation(.smooth(duration: 0.34, extraBounce: 0), completionCriteria: .logicallyComplete) {
            isPresented = false
            dragOffset = 0
        } completion: {
            onDismiss()
        }
    }
}

// MARK: - Preview Sheet

private struct WidgetPreviewSheet: View {
    let item: WidgetCatalogItem

    private var previewScale: CGFloat {
        switch item.size {
        case .small:
            0.92
        case .medium:
            0.80
        case .large:
            0.72
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let previewSize = item.size.previewSize(
                fittingWidth: max(0, proxy.size.width - (AppSpacing.screenHorizontal * 2))
            )
            let scaledPreviewSize = CGSize(
                width: previewSize.width * previewScale,
                height: previewSize.height * previewScale
            )

            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        WidgetPreview(item: item)
                            .frame(width: previewSize.width, height: previewSize.height)
                            .scaleEffect(previewScale)
                            .frame(
                                width: scaledPreviewSize.width,
                                height: scaledPreviewSize.height
                            )

                        Text("\(item.displayName) | \(item.primaryCategory.title)")
                            .font(AppFonts.font(.heading3))
                            .foregroundStyle(AppColors.primaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(maxWidth: min(scaledPreviewSize.width, 320), alignment: .center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 36)
                    .padding(.bottom, 132 + AppSpacing.bottomBarInset)
                }

                SaveWidgetButton()
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.bottom, AppSpacing.bottomBarInset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.appBackground)
            .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
        }
    }
}

// MARK: - Save Button

private struct SaveWidgetButton: View {
    var body: some View {
        Button {} label: {
            SaveWidgetButtonContent()
                .frame(maxWidth: 256)
                .frame(height: 64)
        }
        .buttonStyle(.plain)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
    }
}

private struct SaveWidgetButtonContent: View {
    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        buttonLabel
            .foregroundStyle(Color.green.opacity(0.64))
            .overlay {
                GeometryReader { proxy in
                    buttonLabel
                        .foregroundStyle(
                            LinearGradient(
                                stops: [
                                    .init(color: Color.green.opacity(0), location: 0),
                                    .init(color: Color.green.opacity(0.12), location: 0.32),
                                    .init(color: Color.green.opacity(0.54), location: 0.5),
                                    .init(color: Color.green.opacity(0.12), location: 0.68),
                                    .init(color: Color.green.opacity(0), location: 1),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(
                            Capsule()
                                .frame(width: proxy.size.width * 0.42, height: proxy.size.height * 1.35)
                                .blur(radius: 6)
                                .rotationEffect(.degrees(8))
                                .offset(x: proxy.size.width * shimmerPhase)
                        )
                        .opacity(0.9)
                }
                .allowsHitTesting(false)
            }
            .symbolEffect(.pulse.wholeSymbol, options: .repeating.speed(0.35), value: shimmerPhase > 0)
            .onAppear {
                shimmerPhase = -0.9
                withAnimation(.easeInOut(duration: 4.4).repeatForever(autoreverses: false)) {
                    shimmerPhase = 1.45
                }
            }
    }

    private var buttonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(AppFonts.font(.heading2))
            
            Text("Save widget")
                .font(AppFonts.font(.heading2))
        }
    }
}

#Preview {
    GalleryScreen()
}
