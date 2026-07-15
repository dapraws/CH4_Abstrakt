//
//  LiveActivityPreviewSheet.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import SwiftUI

struct LiveActivityPreviewSheet: View {
    private enum Metrics {
        static let containerCornerRadius: CGFloat = 34
        static let sectionTopPadding: CGFloat = 20
        static let sectionHeaderBottomPadding: CGFloat = 6
        static let sectionHorizontalPadding: CGFloat = 22
        static let sectionVerticalPadding: CGFloat = 20
        static let gridSpacing: CGFloat = 22
        static let tileSize: CGFloat = 56
        static let tileCornerRadius: CGFloat = 16
        static let labelSpacing: CGFloat = 9
        static let previewSheetHorizontalPadding: CGFloat = 16
        static let previewSheetVerticalPadding: CGFloat = 24
        static let expandedScrollBottomPadding: CGFloat = 160
        static let previewRowSpacing: CGFloat = 24
        static let activityPreviewWidth: CGFloat = LiveActivityWidgetMetrics.islandWidth
        static let activityPreviewCornerRadius: CGFloat = 30
        static let sheetHeaderIconSize: CGFloat = 20
        static let sheetHeaderSpacing: CGFloat = 8
        static let sheetHeaderTopPadding: CGFloat = 24
        static let sheetHeaderBottomPadding: CGFloat = 14
        static let sheetSeparatorPadding: CGFloat = 12
        static let expandedScrollTopAnchor = "live-activity-expanded-scroll-top"
    }
    
    @Environment(LiveActivitiesState.self) private var state
    let availableWidth: CGFloat
    var animationNamespace: Namespace.ID
    
    private let baseContainerWidth: CGFloat = 352
    private var containerWidth: CGFloat {
        max(availableWidth, 0)
    }
    private var containerScale: CGFloat {
        guard baseContainerWidth > 0 else { return 1 }
        return max(containerWidth / baseContainerWidth, 0)
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    private var isActivityPreviewMode: Bool {
        state.selectedMode != .compact
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                sheetHeader
                
                ScrollViewReader { scrollProxy in
                    ScrollView(showsIndicators: false) {
                        Color.clear
                            .frame(height: 1)
                            .id(Metrics.expandedScrollTopAnchor)
                        
                        VStack(spacing: 0) {
                            pickerContent(items: state.currentWidgets)
                            
                            if state.isPickerExpanded {
                                Color.clear
                                    .frame(height: Metrics.expandedScrollBottomPadding)
                            }
                        }
                    }
                    .scrollDisabled(!state.isPickerExpanded)
                    .coordinateSpace(.named("SCROLL"))
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 10)
                            .onEnded { value in
                                if !state.isPickerExpanded && value.translation.height < -15 {
                                    state.setPickerExpanded(true)
                                }
                            }
                    )
                    .onChange(of: state.isPickerExpanded, initial: true) {
                        if state.isPickerExpanded {
                            scrollToTop(scrollProxy)
                        }
                    }
                    .onChange(of: state.selectedMode) {
                        if state.isPickerExpanded {
                            scrollToTop(scrollProxy)
                        }
                    }
                }
            }
            .background(AppColors.liveActivityCard)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: Metrics.containerCornerRadius,
                    topTrailingRadius: Metrics.containerCornerRadius,
                    style: .continuous
                )
            )
        }
        .scaleEffect(containerScale, anchor: .top)
        .frame(width: baseContainerWidth, alignment: .top)
        .frame(width: containerWidth, alignment: .top)
    }
    
    private var sheetHeader: some View {
        VStack(spacing: Metrics.sheetHeaderBottomPadding) {
            HStack(spacing: Metrics.sheetHeaderSpacing) {
                Image(state.selectedMode.iconAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: Metrics.sheetHeaderIconSize,
                        height: Metrics.sheetHeaderIconSize
                    )
                
                Text(state.selectedMode.previewSheetTitle)
                    .font(AppFonts.font(.liveActivitySection))
            }
            .foregroundStyle(AppColors.primaryText)
            .padding(.top, Metrics.sheetHeaderTopPadding)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
                state.setPickerExpanded(!state.isPickerExpanded)
            }
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        if value.translation.height < -30 {
                            state.setPickerExpanded(true)
                        } else if value.translation.height > 30 {
                            state.setPickerExpanded(false)
                        }
                    }
            )
            
            appSeparator
                .padding(.horizontal, Metrics.previewSheetHorizontalPadding)
                .padding(.top, Metrics.sheetSeparatorPadding)
        }
    }
    
    private func scrollToTop(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.async {
            proxy.scrollTo(Metrics.expandedScrollTopAnchor, anchor: .top)
        }
    }
    
    private var appSeparator: some View {
        GeometryReader { geo in
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: geo.size.width, y: 0))
            }
            .stroke(style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
            .foregroundColor(AppColors.primaryText.opacity(0.07))
        }
        .frame(height: 1)
    }
    
    @ViewBuilder
    private func pickerContent(items: [LiveActivityWidget]) -> some View {
        Group {
            if isActivityPreviewMode {
                activityPreviewList(items: items)
                    .padding(.horizontal, Metrics.previewSheetHorizontalPadding)
                    .padding(.bottom, Metrics.previewSheetVerticalPadding)
                    .padding(.top, Metrics.sectionVerticalPadding)
            } else {
                compactWidgetGrid(items: items)
                    .padding(.horizontal, Metrics.sectionHorizontalPadding)
                    .padding(.vertical, Metrics.sectionVerticalPadding)
            }
        }
        .id(state.selectedMode)
        .transition(.activityModeBlurFade)
        .animation(.smooth(duration: 0.32, extraBounce: 0), value: state.selectedMode)
    }
    
    private func activityPreviewList(items: [LiveActivityWidget]) -> some View {
        LazyVStack(spacing: Metrics.previewRowSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                Button {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.82)) {
                        state.selectWidget(item)
                    }
                } label: {
                    LiveActivityItemRenderer(
                        item: item,
                        isLiveActivity: state.selectedMode == .lockScreen,
                        activityCornerRadius: activityPreviewCornerRadius,
                        activityTitleColor: AppColors.primaryText
                    )
                    .frame(
                        width: Metrics.activityPreviewWidth,
                        alignment: .top
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: activityPreviewCornerRadius,
                            style: .continuous
                        )
                    )
                    .overlay(alignment: .topLeading) {
                        if isSelected(item) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .green)
                                .offset(x: -3, y: -3)
                                .transition(.selectedActivityBadge)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
                .animation(
                    .smooth(duration: 0.34, extraBounce: 0.04)
                    .delay(Double(index) * 0.018),
                    value: state.selectedMode
                )
            }
        }
    }
    
    private func isSelected(_ item: LiveActivityWidget) -> Bool {
        switch state.selectedMode {
        case .compact:
            state.selectedLeadingWidget?.id == item.id || state.selectedTrailingWidget?.id == item.id
        case .expanded:
            state.selectedExpandedWidget?.id == item.id
        case .lockScreen:
            state.selectedLockScreenWidget?.id == item.id
        }
    }
    
    private var activityPreviewCornerRadius: CGFloat {
        Metrics.activityPreviewCornerRadius
    }
    
    private func compactWidgetGrid(items: [LiveActivityWidget]) -> some View {
        LazyVGrid(columns: columns, spacing: Metrics.gridSpacing) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                let isLeading = state.selectedLeadingWidget?.id == item.id
                let isTrailing = state.selectedTrailingWidget?.id == item.id
                let isExpandedSelected = state.selectedExpandedWidget?.id == item.id
                let isLockScreenSelected = state.selectedLockScreenWidget?.id == item.id
                
                let isSelected: Bool = {
                    switch state.selectedMode {
                    case .compact:
                        isLeading || isTrailing
                    case .expanded:
                        isExpandedSelected
                    case .lockScreen:
                        isLockScreenSelected
                    }
                }()
                VStack(spacing: Metrics.labelSpacing) {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            state.selectWidget(item)
                        }
                    } label: {
                        ZStack {
                            RoundedRectangle(
                                cornerRadius: Metrics.tileCornerRadius,
                                style: .continuous
                            )
                            .fill(Color.black)
                            .frame(
                                width: Metrics.tileSize,
                                height: Metrics.tileSize
                            )
                            
                            if item.layout.usesFullActivityPreview {
                                Image(systemName: item.iconName)
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(.white)
                                    .frame(
                                        width: Metrics.tileSize,
                                        height: Metrics.tileSize
                                    )
                            } else {
                                LiveActivityItemRenderer(
                                    item: item,
                                    isLiveActivity: false,
                                    showsActivityTitle: false
                                )
                                .fixedSize()
                                .scaleEffect(0.60)
                                .frame(
                                    width: Metrics.tileSize,
                                    height: Metrics.tileSize
                                )
                            }
                            
                            if isSelected {
                                VStack {
                                    HStack {
                                        selectedItemBadge(isLeading: isLeading, isTrailing: isTrailing)
                                            .transition(.selectedActivityBadge)
                                        
                                        Spacer(minLength: 0)
                                    }
                                    .offset(x: -2, y: -4)
                                    
                                    Spacer()
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Text(item.name)
                        .font(AppFonts.font(.liveActivityLabel))
                        .foregroundStyle(.primary)
                        .kerning(-0.1)
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                        .allowsTightening(true)
                        .multilineTextAlignment(.center)
                }
                .animation(
                    .smooth(duration: 0.34, extraBounce: 0.05)
                    .delay(Double(index) * 0.018),
                    value: state.selectedMode
                )
                .animation(
                    .smooth(duration: 0.34, extraBounce: 0.04)
                    .delay(Double(index) * 0.01),
                    value: state.isPickerExpanded
                )
                .animation(.smooth(duration: 0.26, extraBounce: 0), value: isSelected)
            }
        }
    }
    
    @ViewBuilder
    private func selectedItemBadge(
        isLeading: Bool,
        isTrailing: Bool
    ) -> some View {
        if state.selectedMode == .compact {
            if isLeading {
                selectionBadge("L")
            } else if isTrailing {
                selectionBadge("R")
            }
        } else {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, .green)
        }
    }
    
    private func selectionBadge(_ label: String) -> some View {
        ZStack {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20, weight: .semibold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(.green, .green)
            
            Text(label)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: 20, height: 20)
    }
}

private struct SelectedActivityBadgeModifier: ViewModifier {
    let opacity: Double
    let blurRadius: CGFloat
    let rotation: Angle
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .blur(radius: blurRadius)
            .rotationEffect(rotation)
    }
}

private struct ActivityModeBlurFadeModifier: ViewModifier {
    let opacity: Double
    let blurRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .blur(radius: blurRadius)
    }
}

private extension AnyTransition {
    static var selectedActivityBadge: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: SelectedActivityBadgeModifier(
                    opacity: 0,
                    blurRadius: 7,
                    rotation: .degrees(-16)
                ),
                identity: SelectedActivityBadgeModifier(
                    opacity: 1,
                    blurRadius: 0,
                    rotation: .zero
                )
            ),
            removal: .modifier(
                active: SelectedActivityBadgeModifier(
                    opacity: 0,
                    blurRadius: 6,
                    rotation: .degrees(12)
                ),
                identity: SelectedActivityBadgeModifier(
                    opacity: 1,
                    blurRadius: 0,
                    rotation: .zero
                )
            )
        )
    }
    
    static var activityModeBlurFade: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: ActivityModeBlurFadeModifier(opacity: 0, blurRadius: 10),
                identity: ActivityModeBlurFadeModifier(opacity: 1, blurRadius: 0)
            ),
            removal: .modifier(
                active: ActivityModeBlurFadeModifier(opacity: 0, blurRadius: 8),
                identity: ActivityModeBlurFadeModifier(opacity: 1, blurRadius: 0)
            )
        )
    }
}
