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
            .frame(maxWidth: .infinity)
            .frame(height: activityHeight)
            .background(activityBackground)
    }

    @ViewBuilder
    private var selectedSurface: some View {
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
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: activityHeight)
    }

    private var activityHeight: CGFloat {
        widget.layout.activityPreviewHeight(isLiveActivity: true)
    }

    @ViewBuilder
    private var activityBackground: some View {
        if isTest {
            Color.yellow.opacity(0.82)
        } else {
            switch backgroundStyle {
            case .glass:
                Color.clear
            case .solid:
                Color.black
            }
        }
    }
}
