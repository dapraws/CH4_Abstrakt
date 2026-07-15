//
//  LockScreenActivity.swift
//  Abstrakt
//

import SwiftUI

struct LockScreenActivity: View {
    let widget: LiveActivityWidget
    var backgroundStyle: LiveActivityBackgroundStyle = .glass

    var body: some View {
        selectedSurface
            .frame(
                maxWidth: .infinity,
                alignment: .center
            )
            .frame(height: activityHeight)
            .background(activityBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                    style: .continuous
                )
            )
            .overlay(activityBorder)
    }

    @ViewBuilder
    private var selectedSurface: some View {
        if widget.layout.usesFullActivityPreview {
            LiveActivityItemRenderer(
                item: widget,
                isLiveActivity: true,
                showsActivityTitle: false,
                activityCornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                activityBackgroundStyle: backgroundStyle,
                drawsActivitySurface: false,
                adaptsContentColorForGlass: true
            )
            .frame(
                maxWidth: .infinity,
                alignment: .top
            )
            .frame(height: activityHeight)
            .compositingGroup()
            .clipShape(
                RoundedRectangle(
                    cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                    style: .continuous
                )
            )
        } else {
            ZStack {
                RoundedRectangle(
                    cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                    style: .continuous
                )
                .fill(Color.black)

                LiveActivityItemRenderer(
                    item: widget,
                    isLiveActivity: true,
                    showsActivityTitle: false
                )
                    .fixedSize()
                    .scaleEffect(0.86)
            }
            .frame(maxWidth: .infinity)
            .frame(height: activityHeight)
        }
    }

    private var activityHeight: CGFloat {
        widget.layout.activityPreviewHeight(isLiveActivity: true)
    }

    @ViewBuilder
    private var activityBackground: some View {
        switch backgroundStyle {
        case .glass:
            let shape = RoundedRectangle(
                cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                style: .continuous
            )

            shape
                .fill(.clear)
                .glassEffect(
                    .regular,
                    in: shape
                )
        case .solid:
            Color.black
        }
    }

    private var activityBorder: some View {
        RoundedRectangle(
            cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
            style: .continuous
        )
        .strokeBorder(
            LinearGradient(
                colors: [
                    .white.opacity(backgroundStyle == .glass ? 0.20 : 0.18),
                    .white.opacity(backgroundStyle == .glass ? 0.08 : 0.08),
                    .white.opacity(backgroundStyle == .glass ? 0.12 : 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            lineWidth: backgroundStyle == .glass ? 0.6 : 0.8
        )
    }
}
