import SwiftUI

struct OnboardingScreen: View {
    let onFinish: () -> Void

    @State private var currentStep = 0

    private let stepKeys = [
        "onboarding.step1",
        "onboarding.step2",
        "onboarding.step3"
    ]

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                TabView(selection: $currentStep) {
                    ForEach(Array(stepKeys.enumerated()), id: \.offset) { index, key in
                        Text(L(key))
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
                    if currentStep == stepKeys.count - 1 {
                        onFinish()
                    } else {
                        currentStep += 1
                    }
                } label: {
                    Text(currentStep == stepKeys.count - 1 ? L("onboarding.start") : L("onboarding.next"))
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
