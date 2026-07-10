import SwiftUI

struct WhatsNewScreen: View {
    let onBack: () -> Void

    var body: some View {
        SettingsSimpleInfoScreen(
            title: L("settings.row.whats_new"),
            coordinateSpaceName: "whatsNewScroll",
            onBack: onBack
        ) {
            SettingsInfoCard(
                icon: "arrow.up",
                iconBackground: LinearGradient(
                    colors: [
                        Color(red: 0.31, green: 0.56, blue: 1),
                        Color(red: 0.31, green: 0.56, blue: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                title: L("settings.row.whats_new"),
                status: "Build 19",
                statusColor: AppColors.accentBlue,
                detail: L("whats_new.detail")
            )
        }
    }
}
