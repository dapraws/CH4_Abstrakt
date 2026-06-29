import SwiftUI

struct GalleryScreen: View {
    @State private var selectedCategory: WidgetCategory = .all
    
    private let featuredCategories: [WidgetCategory] = [.all, .classic, .portal, .health, .weather, .clock]
    private let onSelectItem: (WidgetCatalogItem) -> Void
    
    private typealias GalleryEntry = WidgetCatalogItem
    
    init(onSelectItem: @escaping (WidgetCatalogItem) -> Void = { _ in }) {
        self.onSelectItem = onSelectItem
    }
    
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
        galleryContent
    }
    
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
                    .padding(.trailing, 40)
                }
                .padding(.horizontal, -AppSpacing.screenHorizontal)
                .scrollClipDisabled()
            }
        } content: {
            LazyVStack(alignment: .leading, spacing: 22) {
                ForEach(galleryRows) { row in
                    switch row {
                    case let .single(entry):
                        Button {
                            onSelectItem(entry)
                        } label: {
                            WidgetCard(item: entry)
                        }
                        .buttonStyle(.plain)
                    case let .pair(first, second):
                        HStack(alignment: .top, spacing: 22) {
                            Button {
                                onSelectItem(first)
                            } label: {
                                WidgetCard(item: first)
                            }
                            .buttonStyle(.plain)
                            
                            if let second {
                                Button {
                                    onSelectItem(second)
                                } label: {
                                    WidgetCard(item: second)
                                }
                                .buttonStyle(.plain)
                            } else {
                                Spacer()
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .background(AppColors.appBackground)
    }
}

struct WidgetPreviewSheetCover: View {
    let item: WidgetCatalogItem
    let onDismiss: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPresented = false
    @State private var dragOffset: CGFloat = 0
    private let upwardResistanceLimit: CGFloat = 28
    
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
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    WidgetPreview(item: item)
                        .frame(width: item.size.previewWidth, height: item.size.previewHeight)
                        .scaleEffect(previewScale)
                        .frame(
                            width: item.size.previewWidth * previewScale,
                            height: item.size.previewHeight * previewScale
                        )
                    
                    Text("\(item.displayName) | \(item.primaryCategory.title)")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: min(item.size.previewWidth * previewScale, 320), alignment: .center)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 62)
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
            .foregroundStyle(Color.green.opacity(0.52))
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
