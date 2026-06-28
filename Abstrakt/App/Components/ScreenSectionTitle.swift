import SwiftUI

struct ScreenSectionTitle: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(AppFonts.font(.title))
                .foregroundStyle(AppColors.primaryText)

            if let subtitle {
                Text(subtitle)
                    .font(AppFonts.font(.body))
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }
}
