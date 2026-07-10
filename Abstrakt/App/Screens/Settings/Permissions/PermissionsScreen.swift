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
            VStack(spacing: 14) {
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
        SettingsInfoCard(
            icon: item.icon,
            iconBackground: LinearGradient(
                colors: [
                    item.gradientColors.first?.opacity(0.82) ?? AppColors.cardSoft,
                    item.gradientColors.first ?? AppColors.cardSoft,
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            title: item.title,
            status: item.status.title,
            statusColor: item.status.color,
            detail: item.detail,
            actionTitle: item.action?.title
        ) {
            guard let action = item.action else { return }
            performAction(action)
        }
    }
}
