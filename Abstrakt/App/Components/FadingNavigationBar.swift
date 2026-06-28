import SwiftUI

struct FadingNavigationBar<Content: View>: View {
    let fadeProgress: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [
                    AppColors.topFade.opacity(0.98),
                    AppColors.topFade.opacity(max(0.78, 0.38 + (0.56 * fadeProgress))),
                    AppColors.topFade.opacity(0.0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            content
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, 10)
                .padding(.bottom, 8)
        }
    }
}
