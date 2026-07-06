import SwiftUI
import WidgetKit

struct FontPickerSheet: View {
    private static let settingsStore = AppGroupConstants.sharedDefaults

    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore) private var sharedAppFontThemeID = AppFonts.defaultTheme.id

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)
    private let tileCornerRadius: CGFloat = 24

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                Image("font-color")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text("Choose Font")
                    .font(AppFonts.font(.heading2))
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 42, height: 42)
                        .background(AppColors.cardSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(AppFontTheme.allCases) { theme in
                    fontTile(theme)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(AppColors.appBackground)
        .sensoryFeedback(.selection, trigger: appFontThemeID)
    }

    private func fontTile(_ theme: AppFontTheme) -> some View {
        let isSelected = appFontThemeID == theme.id

        return Button {
            withAnimation(.smooth(duration: 0.18)) {
                appFontThemeID = theme.id
                sharedAppFontThemeID = theme.id
            }
            WidgetCenter.shared.reloadAllTimelines()
        } label: {
            ZStack {
                Text(tileTitle(for: theme))
                    .font(AppFonts.font(.heading3, theme: theme))
                    .lineSpacing(AppFonts.lineSpacing(.heading3, theme: theme))
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 88)
            .background(isSelected ? AppColors.primaryText.opacity(0.06) : AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: tileCornerRadius, style: .continuous))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: tileCornerRadius, style: .continuous)
                        .stroke(
                            AppColors.primaryText.opacity(0.28),
                            style: StrokeStyle(lineWidth: 2, dash: [7, 5], dashPhase: 0)
                        )
                        .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.18), value: isSelected)
    }

    private func tileTitle(for theme: AppFontTheme) -> String {
        switch theme {
        case .sfPro:
            "Default"
        case .sfProRounded:
            "Round"
        case .quicksand:
            "Quicksand"
        case .fusionPixel:
            "Fusion\nPixel"
        }
    }
}

#Preview {
    FontPickerSheet()
}
