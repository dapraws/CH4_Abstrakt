import SwiftUI

struct FAQScreen: View {
    let onBack: () -> Void

    var body: some View {
        SettingsSimpleInfoScreen(
            title: L("settings.row.faq"),
            coordinateSpaceName: "faqScroll",
            onBack: onBack
        ) {
            SettingsInfoCard(
                icon: "questionmark",
                iconBackground: LinearGradient(
                    colors: [
                        Color(red: 1, green: 0.78, blue: 0.31),
                        Color(red: 1, green: 0.78, blue: 0.31),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                title: L("settings.row.faq"),
                status: L("faq.status.ready"),
                statusColor: AppColors.accentGreen,
                detail: L("faq.detail")
            )
        }
    }
}
