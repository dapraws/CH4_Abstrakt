import SwiftUI

struct PortalCustomizationControls: View {
    @Binding var selectedApps: [PortalApp]
    @Binding var clipStyle: PortalIconClipStyle
    let openAppsPicker: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Haptics.selection.play()
                openAppsPicker()
            } label: {
                HStack(spacing: -9) {
                    ForEach(selectedApps.prefix(6), id: \.rawValue) { app in
                        Image(app.assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 34, height: 34)
                            .clipShape(
                                PortalIconShape(
                                    style: clipStyle,
                                    cornerRadius: 11
                                )
                            )
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(AppColors.cardSoft)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose MiniApps")

            PortalClipStyleMenu(clipStyle: $clipStyle)
        }
        .frame(maxWidth: 360)
    }
}

struct PortalClipStyleMenu: View {
    @Binding var clipStyle: PortalIconClipStyle

    var body: some View {
        Menu {
            ForEach(PortalIconClipStyle.allCases) { style in
                Button {
                    Haptics.selection.play()
                    withAnimation(.smooth(duration: 0.18)) {
                        clipStyle = style
                    }
                } label: {
                    Label(
                        style.title,
                        systemImage: clipStyle == style
                            ? "checkmark.circle.fill" : style.systemImage
                    )
                }
            }
        } label: {
            Label("Icon clip style", systemImage: clipStyle.systemImage)
                .font(AppFonts.font(.heading3))
                .foregroundStyle(AppColors.primaryText)
                .labelStyle(.iconOnly)
                .frame(width: 58, height: 58)
                .background(AppColors.cardSoft)
                .clipShape(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }
}
