//
//  LockScreenActivity.swift
//  Abstrakt
//

import SwiftUI

struct LockScreenActivity: View {
    let widget: LiveActivityWidget
    var backgroundStyle: LiveActivityBackgroundStyle = .glass
    var isTest = false

    var body: some View {
        selectedSurface
            .frame(
                width: LiveActivityWidgetMetrics.lockScreenActivityWidth,
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
                adaptsContentColorForGlass: true,
                isTest: isTest
            )
            .frame(
                width: LiveActivityWidgetMetrics.lockScreenActivityWidth,
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
                .fill(isTest ? Color.yellow.opacity(0.82) : Color.black)

                LiveActivityItemRenderer(
                    item: widget,
                    isLiveActivity: true,
                    showsActivityTitle: false,
                    isTest: isTest
                )
                    .fixedSize()
                    .scaleEffect(0.86)
            }
            .frame(width: LiveActivityWidgetMetrics.lockScreenActivityWidth)
            .frame(height: activityHeight)
        }
    }

    private var activityHeight: CGFloat {
        widget.layout.activityPreviewHeight(isLiveActivity: true)
    }

    @ViewBuilder
    private var activityBackground: some View {
        if isTest {
            RoundedRectangle(
                cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                style: .continuous
            )
            .fill(Color.yellow.opacity(0.82))
        } else {
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
