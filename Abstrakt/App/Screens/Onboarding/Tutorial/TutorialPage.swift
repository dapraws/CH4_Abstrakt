import SwiftUI

struct TutorialPage: View {
    var body: some View {
        VStack(spacing: 34) {
            ZStack {
                RoundedRectangle(cornerRadius: 42, style: .continuous)
                    .fill(AppColors.card.opacity(0.86))
                    .frame(width: 300, height: 230)

                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .strokeBorder(AppColors.primaryText.opacity(0.08), lineWidth: 1)
                    .frame(width: 252, height: 178)

                HStack(spacing: 18) {
                    Circle()
                        .fill(AppColors.cardSoft)
                        .frame(width: 72, height: 72)
                        .overlay {
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(AppColors.tertiaryText)
                        }

                    Circle()
                        .fill(AppColors.accentPink)
                        .frame(width: 96, height: 96)
                        .shadow(color: AppColors.accentPink.opacity(0.16), radius: 14, y: 8)
                        .overlay {
                            Image(systemName: "square.grid.2x2.fill")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                }
                .offset(y: 74)
            }

            titleBlock(
                title: "Add your first widget",
                subtitle: "Open Gallery, choose a widget, then tap Save. The big preview shows exactly what you are about to keep."
            )
        }
        .padding(.horizontal, 28)
    }
}

#Preview("Tutorial") {
    AppColors.appBackground
        .overlay {
            TutorialPage()
                .padding(.top, 24)
        }
        .environment(LocalizationManager.shared)
        .environment(\.locale, LocalizationManager.shared.locale)
}
