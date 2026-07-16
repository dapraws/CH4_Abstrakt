//
//  LiveActivityScreen.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import SwiftUI

struct LiveActivityScreen: View {
    private let baseContentWidth: CGFloat = 354
    private let horizontalInset: CGFloat = 20
    @Environment(\.scenePhase) private var scenePhase
    
    private enum SheetOffset {
        static let control: CGFloat = 230
        static let collapsed: CGFloat = 380
        
        static func expanded(for mode: LiveActivityMode) -> CGFloat {
            switch mode {
            case .compact:
                158
            case .expanded:
                184
            case .lockScreen:
                184
            }
        }
    }
    
    @State private var state = LiveActivitiesState()
    @Namespace private var animationNamespace
    
    var body: some View {
        GeometryReader { geometry in
            let contentWidth = max(geometry.size.width - (horizontalInset * 2), 0)
            let layoutScale = max(contentWidth / baseContentWidth, 0)
            let scaledSheetTopOffset = sheetTopOffset * layoutScale
            let scaledControlTopOffset = SheetOffset.control * layoutScale
            let sheetVisibleHeight = max(geometry.size.height - scaledSheetTopOffset, 0)
            
            ZStack(alignment: .top) {
                // Background
                AppColors.appBackground
                    .ignoresSafeArea()
                
                // Top Area
                LiveActivityFrame(
                    availableWidth: contentWidth,
                    animationNamespace: animationNamespace
                )
                
                LiveActivityPreviewControlCard(availableWidth: contentWidth)
                    .padding(.top, scaledControlTopOffset)
                    .animation(.smooth(duration: 0.38, extraBounce: 0), value: state.isLiveActivityEnabled)
                    .animation(.smooth(duration: 0.28, extraBounce: 0), value: state.isUpdatingLiveActivity)
                
                LiveActivityPreviewSheet(
                    availableWidth: contentWidth,
                    animationNamespace: animationNamespace
                )
                .frame(height: sheetVisibleHeight, alignment: .top)
                .padding(.top, scaledSheetTopOffset)
                .ignoresSafeArea(edges: .bottom)
                .animation(.smooth(duration: 0.42, extraBounce: 0.08), value: state.isPickerExpanded)
                .animation(.smooth(duration: 0.38, extraBounce: 0.04), value: state.selectedMode)
            }
            .environment(state)
            .task {
                await state.refreshWidgetData()
            }
            .onChange(of: scenePhase) {
                guard scenePhase == .active else { return }

                Task {
                    await state.refreshWidgetData()
                }
            }
        }
    }
    
    private var sheetTopOffset: CGFloat {
        if state.isPickerExpanded {
            SheetOffset.expanded(for: state.selectedMode)
        } else {
            SheetOffset.collapsed
        }
    }
}

private struct LiveActivityPreviewControlCard: View {
    private enum Metrics {
        static let baseWidth: CGFloat = 354
        static let cornerRadius: CGFloat = 30
        static let horizontalPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 18
        static let separatorTopPadding: CGFloat = 14
        static let bodyTopPadding: CGFloat = 14
    }
    
    @Environment(LiveActivitiesState.self) private var state
    let availableWidth: CGFloat
    
    private var cardWidth: CGFloat {
        max(availableWidth, 0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    Task {
                        if !state.isLiveActivityEnabled {
                            await state.setLiveActivityEnabled(true)
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "chevron.up.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(AppColors.cardSoft, AppColors.primaryText)
                            .font(.system(size: 16, weight: .bold))
                        
                        Text("Go Preview")
                            .font(AppFonts.font(.heading4))
                            .foregroundStyle(AppColors.primaryText)
                            .lineLimit(1)
                    }
                    .fixedSize(horizontal: true, vertical: false)
                }
                .buttonStyle(.plain)
                
                Spacer(minLength: 6)
                
                Text("Dynamic Island")
                    .font(AppFonts.font(.heading4))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Button {
                    Task {
                        await state.setLiveActivityEnabled(!state.isLiveActivityEnabled)
                    }
                } label: {
                    OnboardingPermissionToggle(
                        isOn: state.isLiveActivityEnabled,
                        isEnabled: !state.isUpdatingLiveActivity,
                        inactiveTrackColor: AppColors.controlInactive
                    )
                    .scaleEffect(0.88)
                    .frame(width: 54, height: 34)
                }
                .buttonStyle(.plain)
                .disabled(state.isUpdatingLiveActivity)
                .accessibilityLabel("Dynamic Island")
                .accessibilityValue(state.isLiveActivityEnabled ? "On" : "Off")
            }
            
            Capsule(style: .continuous)
                .fill(AppColors.primaryText.opacity(0.06))
                .frame(height: 1)
                .padding(.top, Metrics.separatorTopPadding)
            
            Text(state.liveActivityErrorMessage ?? "Dynamic Island stays for up to 8 hours. Set up automation for all-day display.")
                .font(AppFonts.font(.subBody))
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(AppFonts.lineSpacing(.subBody))
                .padding(.top, Metrics.bodyTopPadding)
        }
        .padding(.horizontal, Metrics.horizontalPadding)
        .padding(.vertical, Metrics.verticalPadding)
        .frame(width: Metrics.baseWidth)
        .background(AppColors.liveActivityCard)
        .clipShape(
            RoundedRectangle(
                cornerRadius: Metrics.cornerRadius,
                style: .continuous
            )
        )
        .scaleEffect(cardWidth / Metrics.baseWidth, anchor: .top)
        .frame(width: cardWidth, alignment: .top)
        .task {
            state.refreshLiveActivityStatus()
        }
    }
}

#Preview {
    LiveActivityScreen()
}
