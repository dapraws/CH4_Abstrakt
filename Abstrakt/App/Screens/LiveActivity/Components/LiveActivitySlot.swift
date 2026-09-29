//
//  LiveActivitySlot.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 09/07/26.
//

import SwiftUI

struct LiveActivitySlot: View {
    @Environment(\.colorScheme) private var colorScheme

    let selectedWidget: LiveActivityWidget?
    let isSelectedSlot: Bool
    let previewWidgetScale: CGFloat
    let isLiveActivity: Bool
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    var backgroundStyle: LiveActivityBackgroundStyle = .solid
    let toggleSelection: () -> Void

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
                toggleSelection()
            }
        } label: {
            ZStack {
                slotBackground

                Group {
                    if let selectedWidget {
                        if selectedWidget.layout.usesFullActivityPreview {
                            LiveActivityItemRenderer(
                                item: selectedWidget,
                                isLiveActivity: isLiveActivity,
                                showsActivityTitle: false,
                                activityCornerRadius: cornerRadius,
                                activityBackgroundStyle: isLiveActivity ? backgroundStyle : .solid,
                                adaptsContentColorForGlass: isLiveActivity
                            )
                            .frame(width: width, height: height, alignment: .top)
                        } else {
                            LiveActivityItemRenderer(
                                item: selectedWidget,
                                isLiveActivity: false,
                                showsActivityTitle: false
                            )
                            .fixedSize()
                            .scaleEffect(previewWidgetScale)
                            .frame(width: height, height: height)
                        }
                    } else {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(plusForegroundStyle)
                    }
                }
                .id(selectedWidget?.id ?? "empty-\(isLiveActivity ? "lock" : "expanded")")
                .transition(.liveActivitySlotContent)
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(slotBorder)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isSelectedSlot ? Color.white.opacity(0.08) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var slotBackground: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        if isLiveActivity, backgroundStyle == .glass {
            shape
                .fill(.clear)
                .glassEffect(
                    .regular,
                    in: shape
                )
        } else {
            shape.fill(Color.black)
        }
    }

    private var slotBorder: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        .white.opacity(isLiveActivity && backgroundStyle == .glass ? 0.20 : 0.18),
                        .white.opacity(isLiveActivity && backgroundStyle == .glass ? 0.08 : 0.08),
                        .white.opacity(isLiveActivity && backgroundStyle == .glass ? 0.12 : 0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: isLiveActivity && backgroundStyle == .glass ? 0.6 : 0.8
            )
            .opacity(isLiveActivity ? 1 : 0)
    }

    private var plusForegroundStyle: Color {
        if isLiveActivity, backgroundStyle == .glass, colorScheme == .light {
            return AppColors.primaryText
        }

        return .white.opacity(0.82)
    }
}

private struct LiveActivitySlotContentTransitionModifier: ViewModifier {
    let opacity: Double
    let scale: CGFloat
    let blurRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .scaleEffect(scale)
            .blur(radius: blurRadius)
    }
}

private extension AnyTransition {
    static var liveActivitySlotContent: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: LiveActivitySlotContentTransitionModifier(opacity: 0, scale: 0.95, blurRadius: 4),
                identity: LiveActivitySlotContentTransitionModifier(opacity: 1, scale: 1, blurRadius: 0)
            ),
            removal: .modifier(
                active: LiveActivitySlotContentTransitionModifier(opacity: 0, scale: 0.98, blurRadius: 3),
                identity: LiveActivitySlotContentTransitionModifier(opacity: 1, scale: 1, blurRadius: 0)
            )
        )
    }
}
