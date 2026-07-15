//
//  ExpandedActivity.swift
//  Abstrakt
//

import SwiftUI

struct ExpandedActivity: View {
    let widget: LiveActivityWidget

    var body: some View {
        if widget.layout.usesFullActivityPreview {
            LiveActivityItemRenderer(
                item: widget,
                isLiveActivity: false,
                showsActivityTitle: false,
                activityCornerRadius: LiveActivityWidgetMetrics.expandedIslandCornerRadius
            )
            .frame(
                width: LiveActivityWidgetMetrics.islandWidth,
                height: widget.layout.activityPreviewHeight(isLiveActivity: false),
                alignment: .top
            )
            .compositingGroup()
            .clipShape(
                RoundedRectangle(
                    cornerRadius: LiveActivityWidgetMetrics.expandedIslandCornerRadius,
                    style: .continuous
                )
            )
        } else {
            ZStack {
                RoundedRectangle(
                    cornerRadius: LiveActivityWidgetMetrics.expandedIslandCornerRadius,
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
            .frame(
                width: LiveActivityWidgetMetrics.islandWidth,
                height: LiveActivityWidgetMetrics.expandedIslandHeight
            )
        }
    }
}
