import SwiftUI

struct CenterTextScreen: View {
    let title: String

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            Text(title)
                .font(AppFonts.font(.title))
                .foregroundStyle(AppColors.primaryText)
        }
    }
}

#Preview {
    CenterTextScreen(title: "Home")
}
