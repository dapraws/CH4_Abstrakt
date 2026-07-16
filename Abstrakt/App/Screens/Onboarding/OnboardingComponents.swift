import SwiftUI

@ViewBuilder
func titleBlock(title: String, subtitle: String) -> some View {
    VStack(spacing: 10) {
        Text(title)
            .font(AppFonts.font(.title))
            .foregroundStyle(AppColors.primaryText)
            .multilineTextAlignment(.center)

        Text(subtitle)
            .font(AppFonts.font(.body))
            .foregroundStyle(AppColors.secondaryText)
            .multilineTextAlignment(.center)
            .lineSpacing(AppFonts.lineSpacing(.body))
            .lineLimit(3)
            .minimumScaleFactor(0.88)
    }
}

struct LibraryPreviewRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppColors.cardSoft)
                .frame(width: 58, height: 58)
                .overlay {
                    Image(systemName: "square.on.square")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(AppColors.primaryText)
                Text(value)
                    .font(AppFonts.font(.caption))
                    .foregroundStyle(AppColors.secondaryText)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(AppFonts.font(.caption))
                .foregroundStyle(AppColors.tertiaryText)
        }
        .padding(12)
        .background(AppColors.cardSoft.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

struct OnboardingPermissionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let detail: String
    let isOn: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(AppFonts.font(.caption))
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(iconColor)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.88)

                Text(detail)
                    .font(AppFonts.font(.caption))
                    .foregroundStyle(AppColors.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.84)
            }

            Spacer(minLength: 10)

            Button(action: action) {
                OnboardingPermissionToggle(isOn: isOn, isEnabled: isEnabled)
            }
            .simultaneousGesture(
                TapGesture().onEnded {
                    Haptics.selection.play()
                }
            )
            .buttonStyle(.plain)
            .disabled(!isEnabled)
            .accessibilityLabel(title)
            .accessibilityValue(isOn ? "On" : "Off")
            .animation(.smooth(duration: 0.24), value: isOn)
            .animation(.smooth(duration: 0.24), value: isEnabled)
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background(AppColors.card.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct OnboardingPermissionToggle: View {
    let isOn: Bool
    let isEnabled: Bool
    var inactiveTrackColor: Color = AppColors.cardSoft

    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(trackColor)
                .frame(width: 58, height: 34)

            Circle()
                .fill(.white.opacity(isEnabled ? 1 : 0.84))
                .frame(width: 28, height: 28)
                .overlay {
                    if isOn {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(AppColors.accentPurple)
                            .transition(
                                .asymmetric(
                                    insertion: .scale(scale: 0.4, anchor: .center)
                                        .combined(with: .opacity)
                                        .animation(.smooth(duration: 0.28).delay(0.12)),
                                    removal: .scale(scale: 0.4, anchor: .center)
                                        .combined(with: .opacity)
                                        .animation(.smooth(duration: 0.16))
                                )
                            )
                    }
                }
                .padding(3)
                .shadow(color: .black.opacity(isOn ? 0.12 : 0.04), radius: 5, y: 2)
        }
        .animation(.smooth(duration: 0.36), value: isOn)
        .animation(.smooth(duration: 0.26), value: isEnabled)
    }

    private var trackColor: Color {
        if isOn {
            return AppColors.accentPurple
        }
        return isEnabled ? inactiveTrackColor : inactiveTrackColor.opacity(0.7)
    }
}

struct PermissionHeroCone: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: 0))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

var blurFadeTransition: AnyTransition {
    .modifier(
        active: BlurFadeTransitionModifier(opacity: 0, radius: 10),
        identity: BlurFadeTransitionModifier(opacity: 1, radius: 0)
    )
}

struct BlurFadeTransitionModifier: ViewModifier {
    let opacity: Double
    let radius: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .blur(radius: radius)
    }
}
