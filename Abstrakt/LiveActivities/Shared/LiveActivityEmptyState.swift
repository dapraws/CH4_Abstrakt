//
//  LiveActivityEmptyState.swift
//  Abstrakt
//

import SwiftUI

struct LiveActivityEmptyState: View {
    @Environment(\.colorScheme) private var colorScheme

    var backgroundStyle: LiveActivityBackgroundStyle = .glass
    var showsGlassBorder = false
    var adaptsContentColorForGlass = false

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                style: .continuous
            )
            .fill(backgroundStyle == .glass ? .clear : Color.black.opacity(0.74))
            .glassEffectIfNeeded(backgroundStyle)
            .overlay(
                RoundedRectangle(
                    cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
                    style: .continuous
                )
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            .white.opacity(backgroundStyle == .glass ? 0.20 : 0.18),
                            .white.opacity(0.08),
                            .white.opacity(backgroundStyle == .glass ? 0.12 : 0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: backgroundStyle == .glass ? 0.6 : 0.8
                )
                .opacity(showsGlassBorder ? 1 : 0)
            )

            VStack(spacing: 9) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(emptyStateContentColor.opacity(0.94))

                Text("Add Activity")
                    .font(LiveActivityTypography.islandFont(.title, scale: 0.92))
                    .foregroundStyle(emptyStateContentColor.opacity(0.92))
                    .liveActivityTextFormatting()

                Text("Tap to add a Live Activity in the app.")
                    .font(LiveActivityTypography.islandFont(.label, scale: 0.9))
                    .foregroundStyle(emptyStateContentColor.opacity(0.58))
                    .liveActivityTextFormatting()
            }
            .multilineTextAlignment(.center)
        }
    }

    private var emptyStateContentColor: Color {
        if backgroundStyle == .glass, adaptsContentColorForGlass, colorScheme == .light {
            return Color(red: 20 / 255, green: 20 / 255, blue: 20 / 255)
        }

        return .white
    }
}

private extension View {
    @ViewBuilder
    func glassEffectIfNeeded(_ backgroundStyle: LiveActivityBackgroundStyle) -> some View {
        let shape = RoundedRectangle(
            cornerRadius: LiveActivityWidgetMetrics.lockScreenActivityCornerRadius,
            style: .continuous
        )

        if backgroundStyle == .glass {
            glassEffect(
                .regular,
                in: shape
            )
        } else {
            self
        }
    }
}
