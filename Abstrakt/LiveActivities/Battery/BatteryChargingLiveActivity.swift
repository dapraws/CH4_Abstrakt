//
//  BatteryChargingLiveActivity.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 08/07/26.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct BatteryChargingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BatteryActivityAttributes.self) { context in
            BatteryChargingLockScreenView(state: context.state)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.center) {
                    BatteryChargingExpandedView(state: context.state)
                }
            } compactLeading: {
                BatteryChargingCompactLeadingView(state: context.state)
            } compactTrailing: {
                BatteryChargingCompactTrailingView(state: context.state)
            } minimal: {
                BatteryChargingMinimalView(state: context.state)
            }
        }
    }
}

// MARK: - Lock Screen

private struct BatteryChargingLockScreenView: View {
    let state: BatteryActivityAttributes.ContentState

    private var viewData: BatterySnapshotViewData {
        BatterySnapshotViewData(
            level: state.level,
            estimatedMinutesRemaining: state.estimatedMinutesRemaining,
            isCharging: state.isCharging
        )
    }

    var body: some View {
        ZStack {
            AbstraktWidgetPalette(colorScheme: .dark).background

            HStack(spacing: 16) {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(state.level)%")
                        .font(AbstraktWidgetFonts.font(.display, theme: .sharedAppTheme))
                        .foregroundStyle(.white)

                    Text(viewData.timeRemainingLabel)
                        .font(AbstraktWidgetFonts.font(.caption, theme: .sharedAppTheme))
                        .foregroundStyle(.gray)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Dynamic Island

private struct BatteryChargingCompactLeadingView: View {
    let state: BatteryActivityAttributes.ContentState

    var body: some View {
        Image(systemName: "bolt.fill")
            .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))
    }
}

private struct BatteryChargingCompactTrailingView: View {
    let state: BatteryActivityAttributes.ContentState

    var body: some View {
        HStack(spacing: 4) {
            Text("\(state.level)%")
                .foregroundStyle(.white)
            
            if let mins = state.estimatedMinutesRemaining, state.isCharging, state.level < 100 {
                Text(BatterySnapshotViewData.durationLabel(for: mins))
                    .foregroundStyle(Color(red: 0.6, green: 1.0, blue: 0.6)) // light green
            }
        }
        .font(AbstraktWidgetFonts.font(.body, theme: .sharedAppTheme))
    }
}

private struct BatteryChargingExpandedView: View {
    let state: BatteryActivityAttributes.ContentState

    private var viewData: BatterySnapshotViewData {
        BatterySnapshotViewData(
            level: state.level,
            estimatedMinutesRemaining: state.estimatedMinutesRemaining,
            isCharging: state.isCharging
        )
    }

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "bolt.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))

            VStack(alignment: .leading, spacing: 2) {
                Text("\(state.level)% Charged")
                    .font(AbstraktWidgetFonts.font(.title, theme: .sharedAppTheme))

                Text(viewData.timeRemainingLabel)
                    .font(AbstraktWidgetFonts.font(.caption, theme: .sharedAppTheme))
                    .foregroundStyle(.gray)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

private struct BatteryChargingMinimalView: View {
    let state: BatteryActivityAttributes.ContentState

    var body: some View {
        Image(systemName: "bolt.fill")
            .foregroundStyle(Color(red: 1, green: 0.35, blue: 0.22))
    }
}
