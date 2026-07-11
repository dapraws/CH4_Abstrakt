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
            VStack(spacing: 8) {
                ForEach(AppLanguage.allCases) { language in
                    ZStack {
                        languageTile(language)
                    }
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
            HStack(spacing: 14) {
                languageBadge(language, isSelected: isSelected)

                VStack(alignment: .leading, spacing: 1) {
                    Text(language.displayName)
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .multilineTextAlignment(.leading)

                    Text(language.secondaryDisplayName)
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 12)

                if isSelected {
                    Image(systemName: "checkmark.seal.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .green)
                        .font(.system(size: 20))
                        .transition(
                            .scale(scale: 0.55, anchor: .center)
                                .combined(with: .opacity)
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(isSelected ? AppColors.cardSoft.opacity(0.96) : AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: tileCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.18), value: isSelected)
    }

    @ViewBuilder
    private func languageBadge(_ language: AppLanguage, isSelected: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: 14, style: .continuous)

        ZStack {
            shape
                .fill(isSelected ? AppColors.primaryText.opacity(0.1) : AppColors.cardSoft)

            if language == .system {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.primaryText)
            } else {
                Text(language.badgeText)
                    .font(.system(size: 20))
            }
        }
        .frame(width: 44, height: 44)
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
