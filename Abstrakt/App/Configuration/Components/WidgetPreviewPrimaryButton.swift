import SwiftUI

struct WidgetPreviewPrimaryButtonConfiguration {
    let title: String
    let systemImage: String
    let tint: Color

    var identity: String {
        "\(title)-\(systemImage)"
    }

    var isLoading: Bool {
        systemImage == "hourglass"
    }
}

struct WidgetPreviewPrimaryButton: View {
    let configuration: WidgetPreviewPrimaryButtonConfiguration
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                WidgetPreviewPrimaryButtonContent(configuration: configuration)
                    .id(configuration.identity)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(
                                with: .scale(scale: 0.96)
                            ),
                            removal: .opacity.combined(
                                with: .scale(scale: 1.04)
                            )
                        )
                    )
            }
            .frame(maxWidth: 256)
            .frame(height: 64)
        }
        .buttonStyle(.plain)
        .disabled(configuration.isLoading)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        .animation(
            .snappy(duration: 0.24, extraBounce: 0),
            value: configuration.identity
        )
    }
}

struct WidgetPreviewPrimaryButtonContent: View {
    let configuration: WidgetPreviewPrimaryButtonConfiguration
    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        buttonLabel
            .foregroundStyle(configuration.tint.opacity(0.72))
            .overlay {
                GeometryReader { proxy in
                    buttonLabel
                        .foregroundStyle(
                            LinearGradient(
                                stops: [
                                    .init(
                                        color: configuration.tint.opacity(0),
                                        location: 0
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0.12),
                                        location: 0.32
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0.54),
                                        location: 0.5
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0.12),
                                        location: 0.68
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0),
                                        location: 1
                                    ),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(
                            Capsule()
                                .frame(
                                    width: proxy.size.width * 0.42,
                                    height: proxy.size.height * 1.35
                                )
                                .blur(radius: 6)
                                .rotationEffect(.degrees(8))
                                .offset(x: proxy.size.width * shimmerPhase)
                        )
                        .opacity(0.9)
                }
                .allowsHitTesting(false)
            }
            .symbolEffect(
                .pulse.wholeSymbol,
                options: .repeating.speed(0.35),
                value: shimmerPhase > 0
            )
            .onAppear {
                shimmerPhase = -0.9
                withAnimation(
                    .easeInOut(duration: 4.4).repeatForever(autoreverses: false)
                ) {
                    shimmerPhase = 1.45
                }
            }
    }

    private var buttonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: configuration.systemImage)
                .font(AppFonts.font(.heading2))
                .contentTransition(.symbolEffect(.replace))

            Text(configuration.title)
                .font(AppFonts.font(.heading2))
                .contentTransition(.opacity)
        }
    }
}
