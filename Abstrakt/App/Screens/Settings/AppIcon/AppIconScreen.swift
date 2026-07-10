//
//  AppIconScreen.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 06/07/26.
//

import SwiftUI

/// Grid screen for the app's alternate icons.
///
/// Tapping a tile calls `UIApplication.setAlternateIconName`, which is an
/// app-only API (never available in the widget extension). iOS shows its own
/// confirmation alert after the change — that alert is system-owned and cannot
/// be suppressed via public API.
struct AppIconScreen: View {
    let onBack: () -> Void

    @State private var selectedIconID: String = AppIconOption.from(
        alternateIconName: UIApplication.shared.alternateIconName
    ).id
    @State private var changeError: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 4)
    private let iconCornerRadius: CGFloat = 16

    var body: some View {
        ScrollFadeView(
            showsIndicators: false,
            headerHeight: 36,
            contentTopPadding: 12,
            coordinateSpaceName: "appIconScroll"
        ) { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                SettingsSubscreenHeader(
                    title: L("settings.row.change_icon"),
                    onBack: onBack
                )
            }
        } content: {
            VStack(spacing: 16) {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(AppIconOption.all) { option in
                        iconTile(option)
                    }
                }

                if let changeError {
                    Text(changeError)
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(AppColors.accentPink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, -70)
        }
        .background(AppColors.appBackground.ignoresSafeArea())
        .toolbarVisibility(.hidden, for: .navigationBar)
        .settingsEdgeSwipeBack(onBack: onBack)
        .sensoryFeedback(.selection, trigger: selectedIconID)
    }

    // MARK: - Tile

    private func iconTile(_ option: AppIconOption) -> some View {
        let isSelected = selectedIconID == option.id

        return Button {
            select(option)
        } label: {
            VStack(spacing: 8) {
                iconThumbnail(option, isSelected: isSelected)

                Text(option.displayName)
                    .font(AppFonts.font(.caption))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.18), value: isSelected)
    }

    @ViewBuilder
    private func iconThumbnail(_ option: AppIconOption, isSelected: Bool) -> some View {
        let shape = RoundedRectangle(cornerRadius: iconCornerRadius, style: .continuous)

        ZStack(alignment: .topTrailing) {
            if let image = UIImage(named: option.previewAssetName) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 54, height: 54)
                    .clipShape(shape)
            } else {
                // Placeholder shown until the design team drops in real preview art.
                shape
                    .fill(AppColors.miniAppEmptySlot)
                    .frame(width: 54, height: 54)
                    .overlay {
                        Image(systemName: "app.dashed")
                            .font(AppFonts.font(.caption))
                            .foregroundStyle(AppColors.tertiaryText)
                    }
                    .overlay {
                        shape.stroke(AppColors.miniAppEmptySlotBorder, lineWidth: 1)
                    }
            }

            if isSelected {
                Image(systemName: "checkmark.seal.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .green)
                    .font(.system(size: 16))
                    .scaleEffect(isSelected ? 1 : 0.55)
                    .opacity(isSelected ? 1 : 0)
                    .rotationEffect(.degrees(6))
                    .offset(x: 6, y: -6)
                    .transition(
                        .scale(scale: 0.55, anchor: .center)
                            .combined(with: .opacity)
                    )
            }
        }
        .animation(.smooth(duration: 0.24), value: isSelected)
    }

    // MARK: - Selection

    private func select(_ option: AppIconOption) {
        guard selectedIconID != option.id else { return }

        // No-op if the requested icon already matches the live state.
        let currentName = UIApplication.shared.alternateIconName
        guard currentName != option.alternateIconName else {
            withAnimation(.smooth(duration: 0.24)) {
                selectedIconID = option.id
            }
            return
        }

        UIApplication.shared.setAlternateIconName(option.alternateIconName) { error in
            Task { @MainActor in
                if let error {
                    changeError = "Couldn't change icon: \(error.localizedDescription)"
                } else {
                    changeError = nil
                    withAnimation(.smooth(duration: 0.24)) {
                        selectedIconID = option.id
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppIconScreen(onBack: {})
    }
}
