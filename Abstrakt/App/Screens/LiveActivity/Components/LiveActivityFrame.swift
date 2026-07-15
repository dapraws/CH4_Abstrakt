//
//  LiveActivityFrame.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import ActivityKit
import SwiftUI

struct LiveActivityFrame: View {
    private enum Metrics {
        static let canvasSize = CGSize(width: 352, height: 191)
        static let previewAreaHeight: CGFloat = 224
        static let previewContentScale: CGFloat = 0.92
        static let baseWidth: CGFloat = canvasSize.width
        static let pageSpacing: CGFloat = 26
        static let slotBarWidth: CGFloat = 164
        static let slotBarHeight: CGFloat = 40
        static let slotBarCornerRadius: CGFloat = 20
        static let expandedSlotBarWidth: CGFloat = LiveActivityWidgetMetrics.islandWidth
        static let expandedSlotBarHeight: CGFloat = LiveActivityWidgetMetrics.expandedIslandHeight
        static let islandSurfaceHeight: CGFloat = LiveActivityWidgetMetrics.expandedSurfaceHeight
        static let expandedSlotCornerRadius: CGFloat = LiveActivityWidgetMetrics.expandedPreviewCornerRadius
        static let liveActivitySlotCornerRadius: CGFloat = LiveActivityWidgetMetrics.lockScreenActivityCornerRadius
        static let liveActivitySlotBarWidth: CGFloat = LiveActivityWidgetMetrics.islandWidth
        static let liveActivitySlotBarHeight: CGFloat = LiveActivityWidgetMetrics.lockScreenIslandHeight
        static let topControlPadding: CGFloat = 20
        static let liveActivityTopControlPadding: CGFloat = 24
        static let actionTopPadding: CGFloat = 6
        static let liveActivityControlsTopPadding: CGFloat = 8
        static let slotButtonSize: CGFloat = 34
        static let compactWidgetScale: CGFloat = 0.58
        static let previewWidgetScale: CGFloat = 0.56
    }
    
    @Environment(LiveActivitiesState.self) private var state
    @State private var dragOffset: CGFloat = 0
    let availableWidth: CGFloat
    var animationNamespace: Namespace.ID
    
    private var previewScale: CGFloat {
        max(availableWidth / Metrics.baseWidth, 0)
    }
    
    private var modes: [LiveActivityMode] {
        LiveActivityMode.allCases
    }
    
    private var selectedIndex: Int {
        modes.firstIndex(of: state.selectedMode) ?? 0
    }
    
    private var pageStride: CGFloat {
        Metrics.baseWidth + Metrics.pageSpacing
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                HStack(spacing: Metrics.pageSpacing) {
                    ForEach(modes) { mode in
                        preview(for: mode)
                            .frame(
                                width: Metrics.baseWidth,
                                height: Metrics.previewAreaHeight,
                                alignment: .top
                            )
                    }
                }
                .frame(width: Metrics.baseWidth, alignment: .leading)
                .offset(x: -CGFloat(selectedIndex) * pageStride + dragOffset)
                .animation(.smooth(duration: 0.34, extraBounce: 0), value: selectedIndex)
                .animation(.interactiveSpring(response: 0.22, dampingFraction: 0.92), value: dragOffset)
                .gesture(previewDragGesture)
                
                VStack() {
                    Spacer(minLength: 0)
                    
                    modeIndicator
                }
                .padding(.bottom, -4)
                .frame(width: Metrics.baseWidth, height: Metrics.previewAreaHeight)
                .allowsHitTesting(false)
            }
            .scaleEffect(Metrics.previewContentScale)
            .frame(
                width: Metrics.baseWidth * Metrics.previewContentScale,
                height: Metrics.previewAreaHeight * Metrics.previewContentScale
            )
        }
        .scaleEffect(previewScale, anchor: .top)
        .frame(width: Metrics.baseWidth, alignment: .top)
        .frame(width: availableWidth, alignment: .top)
    }
    
    private var previewDragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                let predictedOffset = value.predictedEndTranslation.width
                let threshold = Metrics.baseWidth * 0.18
                let direction: Int
                
                if predictedOffset < -threshold {
                    direction = 1
                } else if predictedOffset > threshold {
                    direction = -1
                } else {
                    direction = 0
                }
                
                let nextIndex = min(max(selectedIndex + direction, 0), modes.count - 1)
                
                guard modes.indices.contains(nextIndex) else { return }
                
                withAnimation(.smooth(duration: 0.36, extraBounce: 0)) {
                    state.setSelectedMode(modes[nextIndex])
                    dragOffset = 0
                }
            }
    }
    
    @ViewBuilder
    private func preview(for mode: LiveActivityMode) -> some View {
        switch mode {
        case .compact:
            compactPreview()
        case .expanded:
            singleSlotPreview(for: mode)
        case .lockScreen:
            singleSlotPreview(for: mode)
        }
    }
    
    private func compactPreview() -> some View {
        previewCanvas(imageName: LiveActivityMode.compact.assetName) {
            compactSlotBar
                .padding(.top, Metrics.topControlPadding)
            
            if state.hasSelection(for: .compact) {
                actionPill(for: .compact)
                    .padding(.top, Metrics.actionTopPadding)
            }
        }
    }
    
    private func singleSlotPreview(for mode: LiveActivityMode) -> some View {
        let isLiveActivity = mode == .lockScreen
        let isSelectedSlot: Bool = {
            switch mode {
            case .expanded:
                state.activeSelectionSlot == .expanded
            case .lockScreen:
                state.activeSelectionSlot == .lockScreen
            case .compact:
                false
            }
        }()
        
        let selectedWidget: LiveActivityWidget? = {
            switch mode {
            case .expanded:
                state.selectedExpandedWidget
            case .lockScreen:
                state.selectedLockScreenWidget
            case .compact:
                nil
            }
        }()
        
        return previewCanvas(imageName: mode.assetName) {
            let usesSurfacePreview = selectedWidget?.layout.usesFullActivityPreview == true
            
            VStack(spacing: 0) {
                LiveActivitySlot(
                    selectedWidget: selectedWidget,
                    isSelectedSlot: isSelectedSlot,
                    previewWidgetScale: Metrics.previewWidgetScale,
                    isLiveActivity: isLiveActivity,
                    width: isLiveActivity ? Metrics.liveActivitySlotBarWidth : Metrics.expandedSlotBarWidth,
                    height: usesSurfacePreview
                    ? surfacePreviewHeight(for: selectedWidget, isLiveActivity: isLiveActivity)
                    : (isLiveActivity ? Metrics.liveActivitySlotBarHeight : Metrics.expandedSlotBarHeight),
                    cornerRadius: isLiveActivity
                        ? Metrics.liveActivitySlotCornerRadius
                        : Metrics.expandedSlotCornerRadius,
                    backgroundStyle: state.lockScreenBackgroundStyle
                ) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        if mode == .expanded {
                            state.toggleSelection(for: .expanded)
                        } else if mode == .lockScreen {
                            state.toggleSelection(for: .lockScreen)
                        }
                    }
                }

                if isLiveActivity {
                    liveActivityControlRow(hasSelection: state.hasSelection(for: mode))
                        .padding(.top, Metrics.liveActivityControlsTopPadding)
                        .transition(.move(edge: .top).combined(with: .opacity))
                } else if state.hasSelection(for: mode) {
                    actionPill(for: mode)
                        .padding(.top, Metrics.actionTopPadding)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.smooth(duration: 0.26, extraBounce: 0.02), value: selectedWidget?.id)
            .padding(.top, isLiveActivity ? Metrics.liveActivityTopControlPadding : Metrics.topControlPadding)
        }
    }

    private func liveActivityControlRow(hasSelection: Bool) -> some View {
        HStack(spacing: hasSelection ? 12 : 0) {
            liveActivityStyleMenu

            if hasSelection {
                actionPill(for: .lockScreen)
            }
        }
        .animation(.smooth(duration: 0.22, extraBounce: 0.01), value: hasSelection)
    }

    private var liveActivityStyleMenu: some View {
        Menu {
            Button {
                state.setLockScreenBackgroundStyle(.glass)
            } label: {
                Label("Glass", systemImage: state.lockScreenBackgroundStyle == .glass ? "checkmark" : "")
            }

            Button {
                state.setLockScreenBackgroundStyle(.solid)
            } label: {
                Label("Solid", systemImage: state.lockScreenBackgroundStyle == .solid ? "checkmark" : "")
            }
        } label: {
            HStack(spacing: 7) {
                Text(state.lockScreenBackgroundStyle.title)

                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .black, design: .rounded))
            }
            .font(AppFonts.font(.liveActivityControl))
            .foregroundStyle(.white)
            .padding(.horizontal, 15)
            .padding(.vertical, 8)
            .liveActivityControlGlass(cornerRadius: 20)
        }
        .buttonStyle(.plain)
    }
    
    private func surfacePreviewHeight(
        for widget: LiveActivityWidget?,
        isLiveActivity: Bool
    ) -> CGFloat {
        if isLiveActivity {
            return widget?.layout.activityPreviewHeight(isLiveActivity: true)
                ?? Metrics.liveActivitySlotBarHeight
        }
        
        return widget?.layout.activityPreviewHeight(isLiveActivity: false)
            ?? Metrics.expandedSlotBarHeight
    }
    
    private var compactSlotBar: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Metrics.slotBarCornerRadius, style: .continuous)
                .fill(Color.black)
            
            HStack {
                slotButton(
                    widget: state.selectedLeadingWidget,
                    isActive: state.activeSelectionSlot == .leading
                ) {
                    state.toggleSelection(for: .leading)
                }
                
                Spacer(minLength: 24)
                
                slotButton(
                    widget: state.selectedTrailingWidget,
                    isActive: state.activeSelectionSlot == .trailing
                ) {
                    state.toggleSelection(for: .trailing)
                }
            }
            .padding(.horizontal, 9)
        }
        .frame(width: Metrics.slotBarWidth, height: Metrics.slotBarHeight)
    }
    
    private func slotButton(
        widget: LiveActivityWidget?,
        isActive: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                action()
            }
        } label: {
            ZStack {
                if let widget {
                    LiveActivityItemRenderer(
                        item: widget,
                        isLiveActivity: false,
                        showsActivityTitle: false
                    )
                        .fixedSize()
                        .scaleEffect(Metrics.compactWidgetScale)
                        .frame(width: Metrics.slotButtonSize, height: Metrics.slotButtonSize)
                } else {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.72))
                }
            }
            .frame(width: Metrics.slotButtonSize, height: Metrics.slotButtonSize)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isActive ? Color.white.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func actionPill(for mode: LiveActivityMode) -> some View {
        HStack(spacing: 6) {
            Button("Edit") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    state.beginEditingSelection(for: mode)
                }
            }
            
            Text("|")
                .foregroundStyle(.white.opacity(0.55))
            
            Button("Delete") {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                    state.clearSelection(for: mode)
                }
            }
        }
        .font(AppFonts.font(.liveActivityControl))
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .liveActivityControlGlass(cornerRadius: 20)
    }
    
    private func previewCanvas<Content: View>(
        imageName: String,
        @ViewBuilder overlay: () -> Content
    ) -> some View {
        ZStack {
            ZStack(alignment: .top) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: Metrics.canvasSize.width,
                        height: Metrics.canvasSize.height
                    )
                
                VStack(spacing: 0) {
                    overlay()
                    Spacer(minLength: 0)
                }
                .frame(width: Metrics.canvasSize.width, height: Metrics.canvasSize.height)
            }
            .frame(width: Metrics.baseWidth, height: Metrics.previewAreaHeight)
        }
        .frame(width: Metrics.baseWidth, height: Metrics.previewAreaHeight)
    }
    
    private var modeIndicator: some View {
        HStack(spacing: 5) {
            ForEach(LiveActivityMode.allCases) { mode in
                Capsule(style: .continuous)
                    .fill(
                        mode == state.selectedMode
                        ? AppColors.primaryText.opacity(0.88)
                        : AppColors.primaryText.opacity(0.18)
                    )
                    .frame(
                        width: mode == state.selectedMode ? 16 : 5,
                        height: 4
                    )
                    .animation(.smooth(duration: 0.2, extraBounce: 0), value: state.selectedMode)
            }
        }
    }
}

private extension View {
    @ViewBuilder
    func liveActivityControlGlass(cornerRadius: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                .regular
                    .tint(Color.black.opacity(0.24))
                    .interactive(),
                in: .rect(cornerRadius: cornerRadius)
            )
        } else {
            self
                .background(.ultraThinMaterial)
                .background(Color.black.opacity(0.72))
                .clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
        }
    }
}
