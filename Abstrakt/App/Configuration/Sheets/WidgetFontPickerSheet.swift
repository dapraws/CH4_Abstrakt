import SwiftUI

struct WidgetFontCustomizationRow: View {
    let selectedThemeName: String
    let openFontPicker: () -> Void

    var body: some View {
        Button {
            Haptics.selection.play()
            openFontPicker()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "t.square.fill")
                    .font(AppFonts.font(.title))

                Capsule()
                    .fill(AppColors.primaryText.opacity(0.16))
                    .frame(width: 2, height: 20)

                Spacer(minLength: 10)

                Text(selectedThemeName)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Image(systemName: "chevron.right")
                    .font(AppFonts.font(.heading4))
                    .foregroundStyle(AppColors.primaryText.opacity(0.42))
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 360)
        .accessibilityLabel("Choose widget font")
    }
}

struct WidgetFontPickerSheet: View {
    private static let settingsStore = AppGroupConstants.sharedDefaults

    @Binding var selectedThemeID: String?
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore)
    private var sharedAppFontThemeID = AppFonts.defaultTheme.id

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 14),
        count: 2
    )
    private let tileCornerRadius: CGFloat = 24
    private var activeAppFontTheme: AppFontTheme {
        AppFontTheme.from(
            id: sharedAppFontThemeID.isEmpty
                ? appFontThemeID : sharedAppFontThemeID
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                SheetHeaderSymbol(systemName: "textformat")

                Text(L("font_picker.title"))
                    .font(AppFonts.font(.heading2))
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Button {
                    Haptics.selection.play()
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
                    fontTile(
                        title: tileTitle(for: theme),
                        themeID: theme.id,
                        fontTheme: theme
                    )
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 20)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(AppColors.appBackground)
        .sensoryFeedback(.selection, trigger: selectedThemeID)
    }

    private func fontTile(
        title: String,
        themeID: String,
        fontTheme: AppFontTheme
    ) -> some View {
        let isSelected =
            selectedThemeID == themeID
            || (selectedThemeID == nil && themeID == activeAppFontTheme.id)

        return Button {
            Haptics.selection.play()
            withAnimation(.smooth(duration: 0.18)) {
                selectedThemeID = themeID
            }
        } label: {
            ZStack {
                Text(title)
                    .font(AppFonts.font(.heading3, theme: fontTheme))
                    .lineSpacing(
                        AppFonts.lineSpacing(.heading3, theme: fontTheme)
                    )
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 88)
            .background(
                isSelected
                    ? AppColors.primaryText.opacity(0.06) : AppColors.cardSoft
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: tileCornerRadius,
                    style: .continuous
                )
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(
                        cornerRadius: tileCornerRadius - 6,
                        style: .continuous
                    )
                    .stroke(
                        AppColors.primaryText.opacity(0.28),
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [7, 5],
                            dashPhase: 0
                        )
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
            "SF Pro"
        case .sfProRounded:
            "SF Rounded"
        case .quicksand:
            "Quicksand"
        case .fusionPixel:
            "Fusion\nPixel"
        }
    }
}
