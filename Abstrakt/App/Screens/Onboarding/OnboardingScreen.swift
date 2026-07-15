import CoreLocation
import SwiftUI

struct OnboardingScreen: View {
    let onFinish: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @AppStorage("onboardingPermissionRequestCount")
    private var permissionRequestCount = 0

    @State private var currentStep = 0
    @State private var renderedStep = 0
    @State private var previousStep = 0
    @State private var healthState = HealthSummaryProvider.shared.authorizationState()
    @State private var locationStatus = CLLocationManager().authorizationStatus
    @State private var calendarState = EventKitProvider.authorizationState()
    @State private var isRequestingPermission = false
    @State private var isTopBarVisible = false
    @State private var isCompleting = false
    @State private var tutorialStep: TutorialStep = .tapAndHold
    @State private var screenStageVisible = true
    @State private var screenStageUsesBlur = true
    @State private var tutorialEditButtonPhase = false
    @State private var tutorialDeletePhase = false
    @State private var tutorialPopoverPhase = false
    @State private var tutorialSheetPhase = false
    @State private var tutorialJiggleActive = false
    @State private var tutorialJigglePhase = false

    private let steps = OnboardingStep.allCases
    private let tutorialSteps = TutorialStep.allCases
    private let maxOnboardingPermissionRequests = 3
    private let onboardingButtonPurple = AppColors.accentPurple

    var body: some View {
        ZStack {
            AppColors.appBackground.ignoresSafeArea()

            ZStack(alignment: .bottom) {
                VStack(spacing: 0) {
                    if renderedStep == 0 {
                        screen(for: renderedStep)
                            .id(renderedStep)
                            .transition(contentTransition)
                            .animation(.smooth(duration: 0.3), value: renderedStep)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .ignoresSafeArea(.container, edges: .bottom)
                    } else {
                        screenContent
                            .id("screen-content")
                            .transition(contentTransition)
                    }
                }
                .opacity(screenStageVisible ? 1 : 0)
                .scaleEffect(screenStageVisible || !screenStageUsesBlur ? 1 : 0.975, anchor: .center)
                .blur(radius: screenStageVisible || !screenStageUsesBlur ? 0 : 9)
                .animation(reduceMotion ? nil : .smooth(duration: 0.3, extraBounce: 0), value: screenStageVisible)

                if isTopBarVisible {
                    topContentFade
                        .allowsHitTesting(false)
                        .zIndex(5)
                        .transition(.opacity)

                    VStack(spacing: 0) {
                        FadingNavigationBar(fadeProgress: 1) {
                            topBar
                        }
                        .frame(height: 88)

                        Spacer()
                    }
                    .allowsHitTesting(currentStep > 0)
                    .zIndex(6)
                    .transition(topBarTransition)
                }

                if currentStep > 0 {
                    bottomFade
                        .allowsHitTesting(false)
                        .zIndex(4)
                }

                primaryAction
                    .padding(.horizontal, 40)
                    .padding(.bottom, 12)
                    .zIndex(5)
            }
            .opacity(isCompleting ? 0 : 1)
            .scaleEffect(isCompleting ? 0.94 : 1, anchor: .center)
            .offset(y: isCompleting ? 18 : 0)
            .blur(radius: isCompleting ? 16 : 0)
            .animation(reduceMotion ? nil : .smooth(duration: 0.58, extraBounce: 0), value: isCompleting)
            .allowsHitTesting(!isCompleting)
        }
        .task {
            refreshPermissionState()
        }
    }

    // MARK: - Navigation

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                Haptics.selection.play()
                goBack()
            } label: {
                Image(systemName: "arrow.left")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white)
                    .frame(width: 32, height: 32)
                    .background(onboardingButtonPurple)
                    .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .leading).combined(with: .opacity))
            .transaction { txn in
                txn.animation = .smooth(duration: 0.32)
            }

            stepper
                .transaction { txn in
                    txn.animation = .smooth(duration: 0.32).delay(0.04)
                }

            Color.clear
                .frame(width: 32, height: 32)
        }
        .frame(height: 48)
    }

    private var stepper: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 8
            let desiredInactiveWidth: CGFloat = 8
            let desiredActiveWidth: CGFloat = 24
            let totalSpacing = spacing * CGFloat(max(visibleStepCount - 1, 0))
            let desiredPillWidth = desiredActiveWidth
                + (desiredInactiveWidth * CGFloat(max(visibleStepCount - 1, 0)))
            let scale = min(1, max(0.64, (proxy.size.width - totalSpacing) / desiredPillWidth))
            let inactiveWidth = desiredInactiveWidth * scale
            let activeWidth = desiredActiveWidth * scale
            let pillHeight = 6 * scale

            HStack(spacing: spacing) {
                ForEach(0..<visibleStepCount, id: \.self) { index in
                    let isActive = index == stepperIndex

                    Capsule()
                        .fill(isActive ? onboardingButtonPurple : onboardingButtonPurple.opacity(0.13))
                        .frame(width: isActive ? activeWidth : inactiveWidth, height: pillHeight)
                        .shadow(
                            color: isActive ? onboardingButtonPurple.opacity(0.14) : .clear,
                            radius: 8,
                            y: 3
                        )
                        .animation(
                            .smooth(duration: 0.28).delay(Double(index) * 0.018),
                            value: stepperIndex
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }

    private var visibleStepCount: Int {
        tutorialSteps.count + 1
    }

    private var stepperIndex: Int {
        switch currentOnboardingStep {
        case .welcome:
            return 0
        case .tutorial:
            return tutorialStepIndex
        case .permissions:
            return tutorialSteps.count
        }
    }

    @ViewBuilder
    private var screenContent: some View {
        GeometryReader { proxy in
            let contentTopPadding = screenContentTopPadding(for: proxy.safeAreaInsets.top)

            screenContainer(
                for: renderedStep,
                topPadding: contentTopPadding
            )
            .frame(width: proxy.size.width, height: proxy.size.height)
            .id(renderedStep)
        }
        .clipped()
    }

    private func screenContentTopPadding(for _: CGFloat) -> CGFloat {
        72
    }

    @ViewBuilder
    private func screenContainer(for index: Int, topPadding: CGFloat) -> some View {
        if steps[index] == .tutorial {
            screenLayout(for: index, topPadding: topPadding, bottomPadding: 112)
        } else {
            ViewThatFits(in: .vertical) {
                screenLayout(for: index, topPadding: topPadding, bottomPadding: 112)

                ScrollView(showsIndicators: false) {
                    screenLayout(for: index, topPadding: topPadding, bottomPadding: 36)
                }
            }
        }
    }

    @ViewBuilder
    private func screenLayout(for index: Int, topPadding: CGFloat, bottomPadding: CGFloat) -> some View {
        screen(for: index)
            .frame(maxWidth: .infinity)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }

    @ViewBuilder
    private func screen(for step: Int) -> some View {
        switch steps[step] {
        case .welcome:
            WelcomeScreen()
        case .tutorial:
            TutorialScreen(
                step: tutorialStep,
                editButtonPhase: $tutorialEditButtonPhase,
                deletePhase: $tutorialDeletePhase,
                popoverPhase: $tutorialPopoverPhase,
                sheetPhase: $tutorialSheetPhase,
                jiggleActive: $tutorialJiggleActive,
                jigglePhase: $tutorialJigglePhase
            )
        case .permissions:
            OnboardingPermissionScreen(
                healthState: healthState,
                locationStatus: locationStatus,
                calendarState: calendarState,
                requestCount: permissionRequestCount,
                maxRequests: maxOnboardingPermissionRequests,
                isRequesting: isRequestingPermission,
                requestHealth: requestHealthPermission,
                requestLocation: requestLocationPermission,
                requestCalendar: requestCalendarPermission
            )
        }
    }

    private var contentTransition: AnyTransition {
        if previousStep == 0 || currentStep == 0 {
            return blurFadeTransition
        }

        let isMovingForward = currentStep >= previousStep
        return .asymmetric(
            insertion: .move(edge: isMovingForward ? .trailing : .leading),
            removal: .move(edge: isMovingForward ? .leading : .trailing)
        )
    }

    private var primaryAction: some View {
        Button {
            Haptics.primary.play()
            if currentStep == steps.count - 1 {
                finishOnboarding()
            } else if currentOnboardingStep == .tutorial, tutorialStep != tutorialSteps.last {
                advanceTutorial()
            } else {
                move(to: currentStep + 1)
            }
        } label: {
            HStack(spacing: 15) {
                if primaryButtonShowsFinalIcon {
                    primaryButtonIcon
                        .transition(primaryButtonIconTransition)
                }

                Text(primaryButtonTitle)
                    .id(primaryButtonTitle)
                    .transition(primaryButtonTextTransition)
                    .animation(primaryButtonTextAnimation, value: primaryButtonLabelIdentity)

                if primaryButtonShowsLeadingIcon {
                    primaryButtonIcon
                        .transition(primaryButtonIconTransition)
                }
            }
            .font(AppFonts.font(.heading2))
            .foregroundStyle(primaryButtonForeground)
            .frame(maxWidth: .infinity)
            .frame(height: primaryButtonHeight)
            .background {
                Capsule()
                    .fill(primaryButtonBackground)
                    .shadow(color: primaryButtonShadow, radius: 10, y: 4)
            }
            .overlay {
                Capsule()
                    .stroke(primaryButtonBorder, lineWidth: 1)
            }
            .animation(.smooth(duration: 0.28, extraBounce: 0), value: currentStep)
        }
        .buttonStyle(.plain)
        .disabled(isCompleting)
    }

    private var primaryButtonTitle: String {
        if currentStep == 0 {
            return L("onboarding.get_started")
        }

        return currentStep == steps.count - 1 ? L("onboarding.start") : L("onboarding.next")
    }

    private var primaryButtonForeground: Color {
        currentStep == 0 || currentStep == steps.count - 1 ? .white : AppColors.primaryText
    }

    private var primaryButtonBackground: Color {
        currentStep == 0 || currentStep == steps.count - 1 ? onboardingButtonPurple : AppColors.widgetBackground
    }

    private var primaryButtonBorder: Color {
        primaryButtonBackground.opacity(currentStep == 0 || currentStep == steps.count - 1 ? 0.72 : 0.2)
    }

    private var primaryButtonShadow: Color {
        primaryButtonBackground.opacity(currentStep == 0 || currentStep == steps.count - 1 ? 0.12 : 0.05)
    }

    private var primaryButtonIcon: some View {
        Image(systemName: primaryButtonIconName)
            .id(primaryButtonIconName)
            .symbolRenderingMode(.hierarchical)
            .animation(primaryButtonIconAnimation, value: primaryButtonLabelIdentity)
    }

    private var primaryButtonTextAnimation: Animation {
        .smooth(duration: 0.28, extraBounce: 0)
    }

    private var primaryButtonIconAnimation: Animation {
        .smooth(duration: 0.24, extraBounce: 0)
    }

    private var primaryButtonTextTransition: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: ButtonLabelSlideModifier(opacity: 0, yOffset: 9, blurRadius: 2),
                identity: ButtonLabelSlideModifier(opacity: 1, yOffset: 0, blurRadius: 0)
            ),
            removal: .modifier(
                active: ButtonLabelSlideModifier(opacity: 0, yOffset: -9, blurRadius: 2),
                identity: ButtonLabelSlideModifier(opacity: 1, yOffset: 0, blurRadius: 0)
            )
        )
    }

    private var primaryButtonIconTransition: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: ButtonLabelSlideModifier(opacity: 0, yOffset: 7, blurRadius: 1.5),
                identity: ButtonLabelSlideModifier(opacity: 1, yOffset: 0, blurRadius: 0)
            ),
            removal: .modifier(
                active: ButtonLabelSlideModifier(opacity: 0, yOffset: -7, blurRadius: 1.5),
                identity: ButtonLabelSlideModifier(opacity: 1, yOffset: 0, blurRadius: 0)
            )
        )
    }

    private var primaryButtonIconName: String {
        primaryButtonShowsFinalIcon ? "checkmark.seal.fill" : "arrow.right"
    }

    private var primaryButtonShowsLeadingIcon: Bool {
        currentStep == 0
    }

    private var primaryButtonShowsFinalIcon: Bool {
        currentStep == steps.count - 1
    }

    private var primaryButtonLabelIdentity: String {
        "\(primaryButtonTitle)-\(primaryButtonIconName)-\(primaryButtonShowsLeadingIcon)-\(primaryButtonShowsFinalIcon)"
    }

    private var primaryButtonHeight: CGFloat {
        72
    }

    private var bottomFade: some View {
        LinearGradient(
            colors: [
                AppColors.appBackground.opacity(0),
                AppColors.appBackground.opacity(0.94),
                AppColors.appBackground,
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 150)
    }

    private var topContentFade: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [
                    AppColors.appBackground.opacity(0.62),
                    AppColors.appBackground.opacity(0.46),
                    AppColors.appBackground.opacity(0.18),
                    AppColors.appBackground.opacity(0),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 132)
            .ignoresSafeArea(edges: .top)

            Spacer(minLength: 0)
        }
    }

    private var topBarTransition: AnyTransition {
        .asymmetric(
            insertion: .modifier(
                active: TopBarVisibilityModifier(opacity: 0, yOffset: -42, blurRadius: 8),
                identity: TopBarVisibilityModifier(opacity: 1, yOffset: 0, blurRadius: 0)
            ),
            removal: .modifier(
                active: TopBarVisibilityModifier(opacity: 0, yOffset: -32, blurRadius: 7),
                identity: TopBarVisibilityModifier(opacity: 1, yOffset: 0, blurRadius: 0)
            )
        )
    }

    private var topBarShowAnimation: Animation {
        .smooth(duration: 0.62)
    }

    private var topBarHideAnimation: Animation {
        .smooth(duration: 0.5)
    }

    private var currentOnboardingStep: OnboardingStep {
        steps[currentStep]
    }

    private var tutorialStepIndex: Int {
        tutorialSteps.firstIndex(of: tutorialStep) ?? 0
    }

    private func advanceTutorial() {
        let nextIndex = tutorialStepIndex + 1
        guard tutorialSteps.indices.contains(nextIndex), !isCompleting else { return }

        changeTutorialStep(to: tutorialSteps[nextIndex], isMovingBackward: false)
    }

    private func goBack() {
        guard !isCompleting else { return }

        if currentOnboardingStep == .tutorial, tutorialStepIndex > 0 {
            changeTutorialStep(to: tutorialSteps[tutorialStepIndex - 1], isMovingBackward: true)
            return
        }

        move(to: currentStep - 1)
    }

    private func changeTutorialStep(to step: TutorialStep, isMovingBackward: Bool) {
        guard tutorialStep != step else { return }

        let oldStep = tutorialStep

        if reduceMotion {
            tutorialStep = step
            setTutorialAnimationPhases(for: step)
            return
        }

        withAnimation(screenAnimation(isMovingBackward: isMovingBackward)) {
            tutorialStep = step
        }

        runTutorialTransition(from: oldStep, to: step)
    }

    private func runTutorialTransition(from oldStep: TutorialStep, to step: TutorialStep) {
        var transaction = Transaction()
        transaction.disablesAnimations = true

        withTransaction(transaction) {
            tutorialJiggleActive = false
            tutorialJigglePhase = false
        }

        switch (oldStep, step) {
        case (.tapAndHold, .edit):
            withTransaction(transaction) {
                tutorialEditButtonPhase = false
                tutorialDeletePhase = false
                tutorialPopoverPhase = false
                tutorialSheetPhase = false
            }

            Task { @MainActor in
                await nextFrame()
                guard tutorialStep == step else { return }

                withAnimation(.spring(duration: 0.34, bounce: 0.2)) {
                    tutorialEditButtonPhase = true
                    tutorialDeletePhase = true
                }
                startTutorialJiggle(after: 390)
            }

        case (.edit, .addWidget):
            withTransaction(transaction) {
                tutorialEditButtonPhase = true
                tutorialDeletePhase = true
                tutorialPopoverPhase = false
                tutorialSheetPhase = false
            }

            Task { @MainActor in
                await nextFrame()
                guard tutorialStep == step else { return }

                withAnimation(.spring(duration: 0.28, bounce: 0.16)) {
                    tutorialDeletePhase = false
                }

                try? await Task.sleep(for: .milliseconds(220))
                guard tutorialStep == step else { return }

                withAnimation(.spring(duration: 0.34, bounce: 0.18)) {
                    tutorialPopoverPhase = true
                }
            }

        case (.addWidget, .findAbstrakt):
            withTransaction(transaction) {
                tutorialEditButtonPhase = true
                tutorialPopoverPhase = true
                tutorialDeletePhase = false
                tutorialSheetPhase = false
            }

            Task { @MainActor in
                await nextFrame()
                guard tutorialStep == step else { return }

                withAnimation(.smooth(duration: 0.24, extraBounce: 0)) {
                    tutorialEditButtonPhase = false
                    tutorialPopoverPhase = false
                }

                try? await Task.sleep(for: .milliseconds(220))
                guard tutorialStep == step else { return }

                withAnimation(.easeOut(duration: 0.34)) {
                    tutorialSheetPhase = true
                }
            }

        case (.findAbstrakt, .addWidget):
            withTransaction(transaction) {
                tutorialEditButtonPhase = false
                tutorialPopoverPhase = false
                tutorialDeletePhase = false
                tutorialSheetPhase = true
            }

            Task { @MainActor in
                await nextFrame()
                guard tutorialStep == step else { return }

                withAnimation(.easeOut(duration: 0.24)) {
                    tutorialSheetPhase = false
                }

                try? await Task.sleep(for: .milliseconds(150))
                guard tutorialStep == step else { return }

                withAnimation(.spring(duration: 0.34, bounce: 0.18)) {
                    tutorialEditButtonPhase = true
                    tutorialPopoverPhase = true
                }
            }

        case (.addWidget, .edit):
            withTransaction(transaction) {
                tutorialEditButtonPhase = true
                tutorialPopoverPhase = true
                tutorialDeletePhase = false
                tutorialSheetPhase = false
            }

            Task { @MainActor in
                await nextFrame()
                guard tutorialStep == step else { return }

                withAnimation(.smooth(duration: 0.2, extraBounce: 0)) {
                    tutorialPopoverPhase = false
                }

                try? await Task.sleep(for: .milliseconds(120))
                guard tutorialStep == step else { return }

                withAnimation(.spring(duration: 0.34, bounce: 0.2)) {
                    tutorialDeletePhase = true
                }
                startTutorialJiggle(after: 300)
            }

        case (.edit, .tapAndHold):
            Task { @MainActor in
                await nextFrame()
                guard tutorialStep == step else { return }

                withAnimation(.smooth(duration: 0.22, extraBounce: 0)) {
                    tutorialEditButtonPhase = false
                    tutorialDeletePhase = false
                }
            }

        default:
            Task { @MainActor in
                await nextFrame()
                guard tutorialStep == step else { return }

                withAnimation(.smooth(duration: 0.24, extraBounce: 0)) {
                    setTutorialAnimationPhases(for: step)
                }

                if step == .edit {
                    startTutorialJiggle(after: 360)
                }
            }
        }
    }

    private func setTutorialAnimationPhases(for step: TutorialStep) {
        switch step {
        case .tapAndHold:
            tutorialEditButtonPhase = false
            tutorialDeletePhase = false
            tutorialPopoverPhase = false
            tutorialSheetPhase = false
        case .edit:
            tutorialEditButtonPhase = true
            tutorialDeletePhase = true
            tutorialPopoverPhase = false
            tutorialSheetPhase = false
        case .addWidget:
            tutorialEditButtonPhase = true
            tutorialDeletePhase = false
            tutorialPopoverPhase = true
            tutorialSheetPhase = false
        case .findAbstrakt:
            tutorialEditButtonPhase = false
            tutorialDeletePhase = false
            tutorialPopoverPhase = false
            tutorialSheetPhase = true
        }
    }

    private func startTutorialJiggle(after delay: Int) {
        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(delay))
            guard tutorialStep == .edit else { return }

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                tutorialJiggleActive = true
                tutorialJigglePhase = false
            }

            withAnimation(.easeInOut(duration: 0.18).repeatForever(autoreverses: true)) {
                tutorialJigglePhase = true
            }
        }
    }

    private func nextFrame() async {
        try? await Task.sleep(for: .milliseconds(17))
    }

    private func move(to step: Int) {
        guard steps.indices.contains(step), step != currentStep, !isCompleting else { return }
        let sourceStep = currentStep
        previousStep = sourceStep
        let isMovingBackward = step < currentStep
        let animation = screenAnimation(isMovingBackward: isMovingBackward)

        if currentStep == 0, step > 0 {
            withAnimation(topBarShowAnimation.delay(0.1)) {
                isTopBarVisible = true
            }
        } else if step == 0 {
            withAnimation(topBarHideAnimation) {
                isTopBarVisible = false
            }
        }

        if shouldCrossfadeScreenMove(from: sourceStep, to: step) {
            fadeScreenMove(to: step)
            return
        }

        withAnimation(animation) {
            currentStep = step
            renderedStep = step
        }

        if !reduceMotion {
            screenStageUsesBlur = true
            screenStageVisible = false
            withAnimation(.smooth(duration: 0.34, extraBounce: 0).delay(0.04)) {
                screenStageVisible = true
            }
        }
    }

    private func shouldCrossfadeScreenMove(from sourceStep: Int, to destinationStep: Int) -> Bool {
        guard steps.indices.contains(sourceStep), steps.indices.contains(destinationStep) else { return false }

        return (steps[sourceStep] == .tutorial && steps[destinationStep] == .permissions)
            || (steps[sourceStep] == .permissions && steps[destinationStep] == .tutorial)
    }

    private func fadeScreenMove(to step: Int) {
        guard !reduceMotion else {
            currentStep = step
            renderedStep = step
            return
        }

        screenStageUsesBlur = true
        currentStep = step

        withAnimation(.smooth(duration: 0.3, extraBounce: 0)) {
            screenStageVisible = false
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(300))
            guard steps.indices.contains(step), renderedStep != step else { return }

            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                renderedStep = step
            }

            await nextFrame()

            withAnimation(.smooth(duration: 0.34, extraBounce: 0).delay(0.04)) {
                screenStageVisible = true
            }
        }
    }

    private func screenAnimation(isMovingBackward: Bool) -> Animation? {
        guard !reduceMotion else { return nil }

        if isMovingBackward {
            return .smooth(duration: 0.42, extraBounce: 0)
        }

        return .smooth(duration: 0.32, extraBounce: 0)
    }

    private func finishOnboarding() {
        guard !isCompleting else { return }

        guard !reduceMotion else {
            onFinish()
            return
        }

        withAnimation(.smooth(duration: 0.58, extraBounce: 0)) {
            isCompleting = true
        }

        Task {
            try? await Task.sleep(for: .milliseconds(680))
            await MainActor.run {
                onFinish()
            }
        }
    }

    // MARK: - Permissions

    private var canRequestOnboardingPermission: Bool {
        permissionRequestCount < maxOnboardingPermissionRequests
    }

    private func requestHealthPermission() {
        guard canRequestOnboardingPermission, !isRequestingPermission else { return }
        isRequestingPermission = true
        permissionRequestCount += 1

        Task {
            _ = await HealthSummaryProvider.shared.requestAuthorization()
            await MainActor.run {
                healthState = HealthSummaryProvider.shared.authorizationState()
                isRequestingPermission = false
            }
        }
    }

    private func requestLocationPermission() {
        guard canRequestOnboardingPermission, !isRequestingPermission else { return }
        isRequestingPermission = true
        permissionRequestCount += 1

        Task {
            let status = await LocationProvider().requestAuthorizationStatus()
            await MainActor.run {
                locationStatus = status
                isRequestingPermission = false
            }
        }
    }

    private func requestCalendarPermission() {
        guard canRequestOnboardingPermission, !isRequestingPermission else { return }
        isRequestingPermission = true
        permissionRequestCount += 1

        Task {
            _ = await EventKitProvider.requestCalendarAccess()
            await MainActor.run {
                calendarState = EventKitProvider.authorizationState()
                isRequestingPermission = false
            }
        }
    }

    private func refreshPermissionState() {
        healthState = HealthSummaryProvider.shared.authorizationState()
        locationStatus = CLLocationManager().authorizationStatus
        calendarState = EventKitProvider.authorizationState()
    }
}

private enum OnboardingStep: CaseIterable {
    case welcome
    case tutorial
    case permissions
}

private struct TopBarVisibilityModifier: ViewModifier {
    let opacity: Double
    let yOffset: CGFloat
    let blurRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(y: yOffset)
            .blur(radius: blurRadius)
    }
}

private struct ButtonLabelSlideModifier: ViewModifier {
    let opacity: Double
    let yOffset: CGFloat
    let blurRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .offset(y: yOffset)
            .blur(radius: blurRadius)
    }
}

#Preview {
    OnboardingScreen(onFinish: {})
        .environment(LocalizationManager.shared)
        .environment(\.locale, LocalizationManager.shared.locale)
}
