//
//  AppIconPickerScreen.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 06/07/26.
//

import SwiftUI

/// Grid picker for the app's alternate icons.
///
/// Tapping a tile calls `UIApplication.setAlternateIconName`, which is an
/// app-only API (never available in the widget extension). iOS shows its own
/// confirmation alert after the change — that alert is system-owned and cannot
/// be suppressed via public API.
struct AppIconPickerScreen: View {
    let onBack: () -> Void

    @State private var selectedIconID: String = AppIconOption.from(
        alternateIconName: UIApplication.shared.alternateIconName
    ).id
    @State private var changeError: String?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 2)
    private let tileCornerRadius: CGFloat = 24

    var body: some View {
        ScrollFadeView(
            showsIndicators: false,
            headerHeight: 36,
            contentTopPadding: 12,
            coordinateSpaceName: "appIconPickerScroll"
        ) { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                header
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
        .sensoryFeedback(.selection, trigger: selectedIconID)
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("App Icon")
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

    // MARK: - Tile

    private func iconTile(_ option: AppIconOption) -> some View {
        let isSelected = selectedIconID == option.id

        return Button {
            select(option)
        } label: {
            VStack(spacing: 12) {
                iconThumbnail(option)

                Text(option.displayName)
                    .font(AppFonts.font(.caption))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 36)
            .padding(.bottom, 24)
            .background(isSelected ? AppColors.primaryText.opacity(0.06) : AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: tileCornerRadius, style: .continuous))
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: tileCornerRadius, style: .continuous)
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

    @ViewBuilder
    private func iconThumbnail(_ option: AppIconOption) -> some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)

        if let image = UIImage(named: option.previewAssetName) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 74, height: 74)
                .clipShape(shape)
        } else {
            // Placeholder shown until the design team drops in real preview art.
            shape
                .fill(AppColors.miniAppEmptySlot)
                .frame(width: 74, height: 74)
                .overlay {
                    Image(systemName: "app.dashed")
                        .font(AppFonts.font(.heading2))
                        .foregroundStyle(AppColors.tertiaryText)
                }
                .overlay {
                    shape.stroke(AppColors.miniAppEmptySlotBorder, lineWidth: 1)
                }
        }
    }

    // MARK: - Selection

    private func select(_ option: AppIconOption) {
        guard selectedIconID != option.id else { return }

        // No-op if the requested icon already matches the live state.
        let currentName = UIApplication.shared.alternateIconName
        guard currentName != option.alternateIconName else {
            selectedIconID = option.id
            return
        }

        UIApplication.shared.setAlternateIconName(option.alternateIconName) { error in
            Task { @MainActor in
                if let error {
                    changeError = "Couldn't change icon: \(error.localizedDescription)"
                } else {
                    changeError = nil
                    withAnimation(.smooth(duration: 0.18)) {
                        selectedIconID = option.id
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        AppIconPickerScreen(onBack: {})
    }
}
