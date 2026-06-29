import SwiftUI

struct OnboardingScreen: View {
    let onFinish: () -> Void

    @State private var currentStep = 0

    private let steps = [
        "Welcome to Abstrakt.\nBuild your own widget library.",
        "Browse by style or data category.\nThen open a widget to customize it.",
        "Save presets to your library.\nThen choose them from the Home Screen widget."
    ]

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                TabView(selection: $currentStep) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        Text(step)
                            .font(AppFonts.font(.title))
                            .foregroundStyle(AppColors.primaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 28)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .frame(height: 260)

                Button {
                    if currentStep == steps.count - 1 {
                        onFinish()
                    } else {
                        currentStep += 1
                    }
                } label: {
                    Text(currentStep == steps.count - 1 ? "Start" : "Next")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.chipTextSelected)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(AppColors.chipSelected)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
    }
}

#Preview {
    OnboardingScreen(onFinish: {})
}
