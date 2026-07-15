//
//  SmartPillIslandRegion.swift
//  Abstrakt
//

import SwiftUI

struct SmartPillIslandRegion: View {
    let widget: LiveActivityWidget?

    var body: some View {
        if let widget {
            LiveActivityItemRenderer(
                item: widget,
                isLiveActivity: true,
                showsActivityTitle: false
            )
                .fixedSize()
                .scaleEffect(0.62)
                .frame(height: 36)
        }
    }
}

struct MinimalSmartPillIslandRegion: View {
    let widget: LiveActivityWidget?

    var body: some View {
        if let widget {
            if widget.isSystemImage {
                Image(systemName: widget.iconName)
                    .foregroundStyle(widget.color)
            } else {
                Image(widget.iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
            }
        } else {
            Color.clear
                .frame(width: 1, height: 1)
        }
    }
}
