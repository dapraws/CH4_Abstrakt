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
                        backgroundStyle: context.state.lockScreenBackgroundStyle,
                        isTest: context.state.isTest
                    )
                    .padding(.vertical, 10)
                } else {
                    LiveActivityEmptyState(
                        backgroundStyle: context.state.lockScreenBackgroundStyle,
                        showsGlassBorder: false,
                        adaptsContentColorForGlass: true
                    )
                    .padding(.horizontal, 12)
                    .frame(maxWidth: .infinity)
                    .frame(height: LiveActivityWidgetMetrics.lockScreenEmptyStateHeight)
                }
            }
            .activityBackgroundTint(
                context.state.lockScreenBackgroundStyle == .solid ? Color.black : Color.clear
            )
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    if let widget = context.state.expandedWidget {
                        ExpandedActivity(
                            widget: widget,
                            isTest: context.state.isTest
                        )
                    } else {
                        LiveActivityEmptyState(
                            backgroundStyle: .solid,
                            showsGlassBorder: false
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: LiveActivityWidgetMetrics.expandedIslandHeight)
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
