//
//  ExpandedActivity.swift
//  Abstrakt
//

import SwiftUI

struct ExpandedActivity: View {
    let widget: LiveActivityWidget
    var isTest = false

    var body: some View {
        if widget.layout.usesFullActivityPreview {
            LiveActivityItemRenderer(
                item: widget,
                isLiveActivity: false,
                showsActivityTitle: false,
                activityCornerRadius: 0,
                drawsActivitySurface: false,
                isTest: isTest
            )
            .frame(
                maxWidth: .infinity,
                alignment: .top
            )
            .frame(height: widget.layout.activityPreviewHeight(isLiveActivity: false))
        } else {
            LiveActivityItemRenderer(
                item: widget,
                isLiveActivity: false,
                showsActivityTitle: false,
                drawsActivitySurface: false,
                isTest: isTest
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .frame(height: LiveActivityWidgetMetrics.expandedIslandHeight)
        }
    }
}
