import SwiftUI

struct GradientPickerRow: View {
    @Binding var selection: GradientTheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GradientTheme.allCases) { theme in
                let isSelected = selection == theme

                Button {
                    Haptics.selection.play()
                    withAnimation(.smooth(duration: 0.20)) {
                        selection = theme
                    }
                } label: {
                    VStack(spacing: 5) {
                        ZStack {
                            if theme == .sunsetAmber {
                                // Dark obsidian with warm amber light bleed from bottom right
                                ZStack {
                                    Color(red: 0.04, green: 0.04, blue: 0.05)

                                    // Ambient bottom-up & right atmospheric glow
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.94, green: 0.40, blue: 0.04).opacity(0.75), location: 0.0),
                                            .init(color: Color(red: 0.75, green: 0.22, blue: 0.01).opacity(0.45), location: 0.40),
                                            .init(color: Color(red: 0.45, green: 0.10, blue: 0.01).opacity(0.18), location: 0.70),
                                            .init(color: Color.clear, location: 1.0)
                                        ],
                                        startPoint: .bottomTrailing,
                                        endPoint: .topLeading
                                    )

                                    // Right vertical flame plume glow
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.96, green: 0.46, blue: 0.05).opacity(0.70), location: 0.0),
                                            .init(color: Color(red: 0.80, green: 0.24, blue: 0.02).opacity(0.35), location: 0.50),
                                            .init(color: Color.clear, location: 1.0)
                                        ],
                                        startPoint: .bottomTrailing,
                                        endPoint: .topTrailing
                                    )
                                    .frame(width: 20, height: 36)
                                    .offset(x: 12, y: -4)
                                    .blur(radius: 5)

                                    // Bottom horizontal shelf glow
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.95, green: 0.42, blue: 0.04).opacity(0.70), location: 0.0),
                                            .init(color: Color(red: 0.78, green: 0.22, blue: 0.02).opacity(0.35), location: 0.50),
                                            .init(color: Color.clear, location: 1.0)
                                        ],
                                        startPoint: .bottomTrailing,
                                        endPoint: .bottomLeading
                                    )
                                    .frame(width: 36, height: 20)
                                    .offset(x: -4, y: 12)
                                    .blur(radius: 5)

                                    // Organic corner origin glow (soft, non-abrupt corner falloff)
                                    RadialGradient(
                                        stops: [
                                            .init(color: Color(red: 1.00, green: 0.88, blue: 0.55).opacity(0.90), location: 0.0),
                                            .init(color: Color(red: 0.98, green: 0.58, blue: 0.10).opacity(0.65), location: 0.35),
                                            .init(color: Color(red: 0.85, green: 0.26, blue: 0.02).opacity(0.30), location: 0.65),
                                            .init(color: Color.clear, location: 1.0)
                                        ],
                                        center: .bottomTrailing,
                                        startRadius: 0,
                                        endRadius: 22
                                    )
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .frame(width: 44, height: 44)
                            } else if theme == .fractalPrism {
                                // Chromatic Iridescent Fluted Glass Swatch
                                ZStack {
                                    // Base midnight-indigo
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.04, green: 0.03, blue: 0.08), location: 0.0),
                                            .init(color: Color(red: 0.08, green: 0.05, blue: 0.16), location: 0.50),
                                            .init(color: Color(red: 0.14, green: 0.09, blue: 0.24), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )

                                    // Spectral dispersion blooms
                                    Circle()
                                        .fill(Color(red: 0.45, green: 0.18, blue: 0.75).opacity(0.40))
                                        .frame(width: 22, height: 22)
                                        .offset(x: -8, y: -8)
                                        .blur(radius: 6)

                                    Circle()
                                        .fill(Color(red: 0.10, green: 0.65, blue: 0.80).opacity(0.35))
                                        .frame(width: 20, height: 20)
                                        .offset(x: 6, y: -4)
                                        .blur(radius: 5)

                                    Circle()
                                        .fill(Color(red: 0.88, green: 0.28, blue: 0.58).opacity(0.40))
                                        .frame(width: 22, height: 22)
                                        .offset(x: 6, y: 8)
                                        .blur(radius: 6)

                                    // 4 Fluted reeded glass slats
                                    HStack(spacing: 0) {
                                        ForEach(0..<4, id: \.self) { _ in
                                             LinearGradient(
                                                stops: [
                                                    .init(color: Color.black.opacity(0.06), location: 0.0),
                                                    .init(color: Color.black.opacity(0.10), location: 0.08),
                                                    .init(color: Color.clear, location: 0.22),
                                                    .init(color: Color.white.opacity(0.04), location: 0.78),
                                                    .init(color: Color.white.opacity(0.10), location: 1.0)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        }
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .frame(width: 44, height: 44)
                            } else if theme == .midnightCyan {
                                // Bioluminescent Topographic Oceanic Contour Swatch
                                ZStack {
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.02, green: 0.06, blue: 0.12), location: 0.0),
                                            .init(color: Color(red: 0.03, green: 0.10, blue: 0.18), location: 0.50),
                                            .init(color: Color(red: 0.01, green: 0.04, blue: 0.08), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )

                                    // Ambient bioluminescent glow
                                    Circle()
                                        .fill(Color(red: 0.08, green: 0.55, blue: 0.75).opacity(0.40))
                                        .frame(width: 26, height: 26)
                                        .offset(x: -8, y: 8)
                                        .blur(radius: 6)

                                    // Miniature Topographic Contour Curves
                                    CyanTopographicMeshShape(isWide: false)
                                        .stroke(
                                            LinearGradient(
                                                stops: [
                                                    .init(color: Color(red: 0.30, green: 0.90, blue: 1.00).opacity(0.65), location: 0.0),
                                                    .init(color: Color(red: 0.10, green: 0.60, blue: 0.80).opacity(0.30), location: 0.70),
                                                    .init(color: Color.clear, location: 1.0)
                                                ],
                                                startPoint: .bottomLeading,
                                                endPoint: .topTrailing
                                            ),
                                            lineWidth: 1.2
                                        )

                                    // Elevation summit node
                                    Circle()
                                        .fill(Color(red: 0.40, green: 0.95, blue: 1.00).opacity(0.85))
                                        .frame(width: 3, height: 3)
                                        .offset(x: -8, y: 7)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .frame(width: 44, height: 44)
                            } else if theme == .emeraldMatrix {
                                // Cybernetic Phosphor Matrix Grid Swatch
                                ZStack {
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.02, green: 0.07, blue: 0.04), location: 0.0),
                                            .init(color: Color(red: 0.03, green: 0.12, blue: 0.07), location: 0.50),
                                            .init(color: Color(red: 0.01, green: 0.04, blue: 0.02), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )

                                    // Emerald phosphor core bloom
                                    Circle()
                                        .fill(Color(red: 0.00, green: 0.88, blue: 0.45).opacity(0.40))
                                        .frame(width: 24, height: 24)
                                        .offset(x: -6, y: -6)
                                        .blur(radius: 6)

                                    // Miniature 4x4 matrix dot grid
                                    EmeraldMatrixDotsView(width: 44, height: 44)

                                    // Subtle diagonal scanbeam
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color.clear, location: 0.2),
                                            .init(color: Color(red: 0.20, green: 0.98, blue: 0.60).opacity(0.12), location: 0.5),
                                            .init(color: Color.clear, location: 0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .blendMode(.plusLighter)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .frame(width: 44, height: 44)
                            } else if theme == .acidDither {
                                // Bayer Matrix Phosphor Dither Swatch
                                ZStack {
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color(red: 0.01, green: 0.05, blue: 0.02), location: 0.0),
                                            .init(color: Color(red: 0.02, green: 0.09, blue: 0.04), location: 0.50),
                                            .init(color: Color(red: 0.01, green: 0.03, blue: 0.01), location: 1.0)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )

                                    // Acid green phosphor bloom in lower right
                                    Circle()
                                        .fill(Color(red: 0.20, green: 0.95, blue: 0.45).opacity(0.40))
                                        .frame(width: 26, height: 26)
                                        .offset(x: 8, y: 8)
                                        .blur(radius: 6)

                                    // Miniature procedural dither canvas
                                    DitherCanvasView(width: 44, height: 44, isWide: false)

                                    // Subtle diagonal scanbeam
                                    LinearGradient(
                                        stops: [
                                            .init(color: Color.clear, location: 0.2),
                                            .init(color: Color(red: 0.35, green: 1.00, blue: 0.65).opacity(0.10), location: 0.5),
                                            .init(color: Color.clear, location: 0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                    .blendMode(.plusLighter)
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .frame(width: 44, height: 44)
                            } else {
                                // Planetary Aurora Gradient Swatch (Ruby)
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: theme.baseGradient,
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(alignment: .topLeading) {
                                        Circle()
                                            .fill(theme.topLeftGlow)
                                            .frame(width: 18, height: 18)
                                            .blur(radius: 4)
                                            .offset(x: 1, y: 1)
                                    }
                                    .overlay(alignment: .center) {
                                        Circle()
                                            .fill(theme.midFieldGlow)
                                            .frame(width: 22, height: 22)
                                            .blur(radius: 5)
                                    }
                                    .overlay(alignment: .bottomTrailing) {
                                        Circle()
                                            .fill(theme.bottomRightDome)
                                            .frame(width: 22, height: 22)
                                            .blur(radius: 4)
                                            .offset(x: 2, y: 2)
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .frame(width: 44, height: 44)
                            }

                            if isSelected {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(AppColors.primaryText, lineWidth: 2)
                                    .frame(width: 50, height: 50)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .frame(width: 52, height: 52)

                        Text(theme.displayName)
                            .font(AppFonts.font(.caption))
                            .foregroundStyle(
                                isSelected
                                    ? AppColors.primaryText
                                    : AppColors.secondaryText
                            )
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(theme.displayName) gradient theme")
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 6)
        .background(AppColors.cardSoft)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .frame(maxWidth: 360)
    }
}
