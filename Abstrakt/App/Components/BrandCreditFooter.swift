import SwiftUI

struct BrandCreditFooter: View {
    var fontRole: AppFontRole = .meta
    var fontTheme: AppFontTheme = .quicksand
    var secondaryColor: Color = AppColors.tertiaryText.opacity(0.78)

    var body: some View {
        HStack(spacing: 0) {
            Text(L("onboarding.made_by_prefix"))
                .foregroundStyle(secondaryColor)
            Text("SSJ")
                .foregroundStyle(AppColors.primaryText)
            Text(" · \(Bundle.main.appVersionDisplay)")
                .foregroundStyle(secondaryColor)
        }
        .font(AppFonts.font(fontRole, theme: fontTheme))
    }
}
