//
//  DynamicIslandActivity.swift
//  Abstrakt
//

import ActivityKit
import SwiftUI
import WidgetKit

// MARK: - ActivityKit Registration

struct DynamicIslandActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DynamicIslandActivityAttributes.self) { context in
            Group {
                if let widget = context.state.lockScreenWidget {
                    LockScreenActivity(
                        widget: widget,
                        backgroundStyle: context.state.lockScreenBackgroundStyle
                    )
                } else {
                    LiveActivityEmptyState(
                        backgroundStyle: context.state.lockScreenBackgroundStyle,
                        showsGlassBorder: true,
                        adaptsContentColorForGlass: true
                    )
                        .frame(maxWidth: .infinity)
                        .frame(height: LiveActivityWidgetMetrics.lockScreenEmptyStateHeight)
                }
            }
            .activityBackgroundTint(.clear)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    if let widget = context.state.expandedWidget {
                        ExpandedActivity(widget: widget)
                    } else {
                        LiveActivityEmptyState()
                            .frame(
                                width: LiveActivityWidgetMetrics.islandWidth,
                                height: LiveActivityWidgetMetrics.expandedIslandHeight
                            )
                    }
                }
            } compactLeading: {
                SmartPillIslandRegion(
                    widget: context.state.leadingWidget
                )
            } compactTrailing: {
                SmartPillIslandRegion(
                    widget: context.state.trailingWidget
                )
            } minimal: {
                MinimalSmartPillIslandRegion(
                    widget: context.state.leadingWidget ?? context.state.trailingWidget
                )
            }
        }
        .contentMarginsDisabled()
    }
}
