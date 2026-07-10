import SwiftUI

struct SettingsSubscreenHeader: View {
    let title: String
    let onBack: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(AppFonts.font(.heading2))
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 42, height: 42)
                        .background(AppColors.card)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }
}

private struct SettingsEdgeSwipeBackModifier: ViewModifier {
    private let edgeActivationWidth: CGFloat = 32
    let onBack: () -> Void

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture(minimumDistance: 24, coordinateSpace: .global)
                .onEnded { value in
                    let horizontal = value.translation.width
                    let vertical = value.translation.height
                    guard value.startLocation.x <= edgeActivationWidth,
                          horizontal > 90,
                          abs(horizontal) > abs(vertical) * 1.4 else {
                        return
                    }

                    onBack()
                }
        )
    }
}

extension View {
    func settingsEdgeSwipeBack(onBack: @escaping () -> Void) -> some View {
        modifier(SettingsEdgeSwipeBackModifier(onBack: onBack))
    }
}

struct SettingsSimpleInfoScreen<Content: View>: View {
    let title: String
    let coordinateSpaceName: String
    let onBack: () -> Void
    @ViewBuilder let content: Content

    var body: some View {
        ScrollFadeView(
            showsIndicators: false,
            headerHeight: 36,
            contentTopPadding: 12,
            coordinateSpaceName: coordinateSpaceName
        ) { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                SettingsSubscreenHeader(title: title, onBack: onBack)
            }
        } content: {
            VStack(spacing: 16) {
                content
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, 120)
        }
        .background(AppColors.appBackground.ignoresSafeArea())
        .toolbarVisibility(.hidden, for: .navigationBar)
        .settingsEdgeSwipeBack(onBack: onBack)
    }
}

struct SettingsInfoCard: View {
    let icon: String
    let iconBackground: LinearGradient
    let title: String
    let status: String
    let statusColor: Color
    let detail: String
    var actionTitle: String? = nil
    var action: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(iconBackground)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)

                    Text(status)
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(statusColor)
                }

                Spacer()

                if let actionTitle {
                    Button(actionTitle, action: action)
                        .font(AppFonts.font(.meta))
                        .foregroundStyle(AppColors.primaryText)
                        .padding(.horizontal, 14)
                        .frame(height: 30)
                        .background(AppColors.appBackground.opacity(0.6))
                        .clipShape(Capsule())
                }
            }

            Text(detail)
                .font(AppFonts.font(.caption))
                .lineSpacing(AppFonts.lineSpacing(.caption))
                .foregroundStyle(AppColors.primaryText)
        }
        .padding(16)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
