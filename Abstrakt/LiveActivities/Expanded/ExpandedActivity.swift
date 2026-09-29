//
//  ExpandedActivity.swift
//  Abstrakt
//

import SwiftUI

struct ExpandedActivity: View {
    let widget: LiveActivityWidget
    var isTest = false

    var body: some View {
        LiveActivityItemRenderer(
            item: widget,
            isLiveActivity: false,
            showsActivityTitle: false,
            activityCornerRadius: 0,
            drawsActivitySurface: false,
            isTest: isTest
        )
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: widget.layout.activityPreviewHeight(isLiveActivity: false))
    }
}
