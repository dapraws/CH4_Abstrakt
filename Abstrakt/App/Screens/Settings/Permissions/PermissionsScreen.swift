import SwiftUI
import UIKit

struct PermissionsScreen: View {
    @Binding var permissionSnapshot: PermissionAccessSnapshot
    let onBack: () -> Void

    var body: some View {
        ScrollFadeView(
            showsIndicators: false,
            headerHeight: 36,
            contentTopPadding: 12,
            coordinateSpaceName: "permissionsScroll"
        ) { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                SettingsSubscreenHeader(
                    title: L("settings.row.permissions"),
                    onBack: onBack
                )
            }
        } content: {
            VStack(spacing: 10) {
                PermissionsOverviewCard(snapshot: permissionSnapshot)

                ForEach(permissionSnapshot.items) { item in
                    PermissionCard(item: item) { action in
                        Task {
                            await performPermissionAction(action)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, 120)
        }
        .background(AppColors.appBackground.ignoresSafeArea())
        .toolbarVisibility(.hidden, for: .navigationBar)
        .settingsEdgeSwipeBack(onBack: onBack)
        .task {
            await refreshPermissionSnapshot()
        }
    }

    @MainActor
    private func performPermissionAction(_ action: PermissionAccessAction) async
    {
        switch action {
        case .requestHealth:
            await HealthSummaryProvider.shared.requestAuthorization()
        case .requestLocation:
            _ = await LocationProvider().requestAuthorizationStatus()
        case .requestCalendar:
            _ = await EventKitProvider.requestCalendarAccess()
        case .openSettings:
            openAppSettings()
        }

        await refreshPermissionSnapshot()
    }

    @MainActor
    private func refreshPermissionSnapshot() async {
        permissionSnapshot = await PermissionAccessSnapshot.current()
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

private struct PermissionCard: View {
    let item: PermissionAccessItem
    let performAction: (PermissionAccessAction) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center, spacing: 12) {
                permissionIcon

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)

                    Text(item.detail)
                        .font(AppFonts.font(.caption))
                        .lineSpacing(AppFonts.lineSpacing(.caption))
                        .foregroundStyle(AppColors.secondaryText)
                        .lineLimit(2)
                }

                Spacer(minLength: 8)

                statusBadge
            }

            if let action = item.action {
                Button(action.title) {
                    performAction(action)
                }
                .font(AppFonts.font(.meta))
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity, alignment: .center)
                .frame(height: 36)
                .background(AppColors.cardSoft)
                .clipShape(Capsule())
            } else {
                HStack(spacing: 8) {
                    Image(systemName: item.status.completionSymbol)
                        .font(.system(size: 12, weight: .semibold))
                    Text(item.status.completionText)
                        .font(AppFonts.font(.meta))
                }
                .foregroundStyle(item.status.color)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 13)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var permissionIcon: some View {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        item.gradientColors.first?.opacity(0.84) ?? AppColors.cardSoft,
                        item.gradientColors.first ?? AppColors.cardSoft,
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 46, height: 46)
            .overlay {
                Image(systemName: item.icon)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(.white)
            }
    }

    private var statusBadge: some View {
        HStack(spacing: 5) {
            Image(systemName: item.status.symbol)
                .font(.system(size: 11, weight: .bold))

            Text(item.status.title)
                .font(AppFonts.font(.meta))
                .lineLimit(1)
        }
        .foregroundStyle(item.status.color)
        .padding(.horizontal, 9)
        .frame(height: 26)
        .background(item.status.color.opacity(0.12))
        .clipShape(Capsule())
    }
}

private struct PermissionsOverviewCard: View {
    let snapshot: PermissionAccessSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                overviewBadge

                VStack(alignment: .leading, spacing: 2) {
                    Text("Permission access")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)

                    Text(headlineText)
                        .font(AppFonts.font(.meta))
                        .foregroundStyle(headlineColor)
                }

                Spacer(minLength: 0)
            }

            Text(summaryText)
                .font(AppFonts.font(.caption))
                .lineSpacing(AppFonts.lineSpacing(.caption))
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(3)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    AppColors.cardSoft.opacity(0.92),
                    AppColors.card.opacity(0.9),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }

    private var readyCount: Int {
        snapshot.items.filter { !$0.needsAttention }.count
    }

    private var attentionCount: Int {
        snapshot.items.filter(\.needsAttention).count
    }

    private var summaryText: String {
        if snapshot.isLoading {
            return "Checking your current access for health, location, calendar, and system-powered widgets."
        }

        if attentionCount == 0 {
            return "Everything is connected and ready for your widgets."
        }

        return "\(attentionCount) permission\(attentionCount == 1 ? "" : "s") still need attention for the best widget experience."
    }

    private var headlineText: String {
        if snapshot.isLoading {
            return "Refreshing status"
        }

        if attentionCount == 0 {
            return "All sources ready"
        }

        return "\(attentionCount) item\(attentionCount == 1 ? "" : "s") to review"
    }

    private var headlineColor: Color {
        if snapshot.isLoading {
            return AppColors.secondaryText
        }

        return attentionCount == 0
            ? AppColors.accentGreen
            : Color(red: 1, green: 0.58, blue: 0.22)
    }

    private var overviewBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppColors.card)
                .frame(width: 46, height: 46)

            Image(systemName: attentionCount == 0 && !snapshot.isLoading ? "checkmark.seal.fill" : "exclamationmark.circle.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, attentionCount == 0 && !snapshot.isLoading ? AppColors.accentGreen : Color(red: 1, green: 0.58, blue: 0.22))
                .font(.system(size: 20))
        }
    }
}

private extension PermissionAccessStatus {
    var symbol: String {
        switch self {
        case .ready:
            "checkmark.circle.fill"
        case .needsRequest:
            "sparkles"
        case .blocked:
            "exclamationmark.triangle.fill"
        case .unavailable:
            "slash.circle.fill"
        }
    }

    var completionSymbol: String {
        switch self {
        case .ready:
            "checkmark.seal.fill"
        case .needsRequest:
            "sparkles"
        case .blocked:
            "exclamationmark.triangle.fill"
        case .unavailable:
            "slash.circle.fill"
        }
    }

    var completionText: String {
        switch self {
        case .ready:
            "All set"
        case .needsRequest:
            "Access can be enabled here"
        case .blocked:
            "Finish this in Settings"
        case .unavailable:
            "This source isn't available"
        }
    }
}
