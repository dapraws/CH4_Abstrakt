//
//  LiveActivitySlot.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import SwiftUI

struct LiveActivitySlot: View {
    @Environment(\.colorScheme) private var colorScheme

    let selectedWidget: LiveActivityWidget?
    let isSelectedSlot: Bool
    let previewWidgetScale: CGFloat
    let isLiveActivity: Bool
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    var backgroundStyle: LiveActivityBackgroundStyle = .solid
    let toggleSelection: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                toggleSelection()
            }
        } label: {
            ZStack {
                if let selectedWidget {
                    if selectedWidget.layout.usesFullActivityPreview {
                        slotBackground

                        LiveActivityItemRenderer(
                            item: selectedWidget,
                            isLiveActivity: isLiveActivity,
                            showsActivityTitle: false,
                            activityCornerRadius: cornerRadius,
                            activityBackgroundStyle: isLiveActivity ? backgroundStyle : .solid,
                            adaptsContentColorForGlass: isLiveActivity
                        )
                        .frame(width: width, alignment: .top)
                        .fixedSize(horizontal: false, vertical: true)
                        .clipShape(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        )
                        .id(selectedWidget.id)
                        .transition(.liveActivitySlotContent)
                    } else {
                        slotBackground

                        LiveActivityItemRenderer(
                            item: selectedWidget,
                            isLiveActivity: false,
                            showsActivityTitle: false
                        )
                            .fixedSize()
                            .scaleEffect(previewWidgetScale)
                            .frame(width: height, height: height)
                            .id(selectedWidget.id)
                            .transition(.liveActivitySlotContent)
                    }
                } else {
                    slotBackground

                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(plusForegroundStyle)
                        .transition(.liveActivitySlotContent)
                }
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(slotBorder)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelectedSlot ? Color.white.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.28, extraBounce: 0.02), value: height)
        .animation(.smooth(duration: 0.28, extraBounce: 0.04), value: selectedWidget?.id)
    }

    @ViewBuilder
    private var slotBackground: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if isLiveActivity, backgroundStyle == .glass {
            shape
                .fill(.clear)
                .glassEffect(
                    .regular,
                    in: shape
                )
        } else {
            shape.fill(Color.black)
        }
    }

    private var slotBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(isLiveActivity && backgroundStyle == .glass ? 0.20 : 0.18),
                        .white.opacity(isLiveActivity && backgroundStyle == .glass ? 0.08 : 0.08),
                        .white.opacity(isLiveActivity && backgroundStyle == .glass ? 0.12 : 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isLiveActivity && backgroundStyle == .glass ? 0.6 : 0.8
            )
            .opacity(isLiveActivity ? 1 : 0)
    }

    private var plusForegroundStyle: Color {
        if isLiveActivity, backgroundStyle == .glass, colorScheme == .light {
            return AppColors.primaryText
        }

        return .white.opacity(0.82)
    }
}

private extension AnyTransition {
    static var liveActivitySlotContent: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.92, anchor: .center).combined(with: .opacity),
            removal: .scale(scale: 0.98, anchor: .center).combined(with: .opacity)
        )
    }
}
