//
//  LanguageScreen.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 07/07/26.
//

import SwiftUI

struct LanguageScreen: View {
    let onBack: () -> Void

    @Environment(LocalizationManager.self) private var localization

    private let tileCornerRadius: CGFloat = 24

    var body: some View {
        ScrollFadeView(
            showsIndicators: false,
            headerHeight: 36,
            contentTopPadding: 12,
            coordinateSpaceName: "languageScroll"
        ) { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                SettingsSubscreenHeader(
                    title: L("language.title"),
                    onBack: onBack
                )
            }
        } content: {
            VStack(spacing: 14) {
                ForEach(AppLanguage.allCases) { language in
                    languageTile(language)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, -70)
        }
        .background(AppColors.appBackground.ignoresSafeArea())
        .toolbarVisibility(.hidden, for: .navigationBar)
        .settingsEdgeSwipeBack(onBack: onBack)
        .sensoryFeedback(.selection, trigger: localization.currentLanguage)
    }

    // MARK: - Tile

    private func languageTile(_ language: AppLanguage) -> some View {
        let isSelected = localization.currentLanguage == language

        return Button {
            select(language)
        } label: {
            Text(language.displayName)
                .font(AppFonts.font(.heading3))
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(isSelected ? AppColors.primaryText.opacity(0.06) : AppColors.cardSoft)
                .clipShape(RoundedRectangle(cornerRadius: tileCornerRadius, style: .continuous))
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: tileCornerRadius - 6, style: .continuous)
                            .stroke(
                                AppColors.primaryText.opacity(0.28),
                                style: StrokeStyle(lineWidth: 2, dash: [7, 5])
                            )
                            .padding(6)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.18), value: isSelected)
    }

    // MARK: - Selection

    private func select(_ language: AppLanguage) {
        guard localization.currentLanguage != language else { return }
        withAnimation(.smooth(duration: 0.18)) {
            localization.setLanguage(language)
        }
        WidgetTimelineReloadScheduler.schedule()
    }
}

#Preview {
    NavigationStack {
        LanguageScreen(onBack: {})
            .environment(LocalizationManager.shared)
            .environment(\.locale, LocalizationManager.shared.locale)
    }
}
