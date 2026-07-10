import CoreLocation
import SwiftUI

struct OnboardingScreen: View {
    let onFinish: () -> Void

    @AppStorage("onboardingPermissionRequestCount")
    private var permissionRequestCount = 0

    @State private var currentStep = 0
    @State private var previousStep = 0
    @State private var healthState = HealthSummaryProvider.shared.authorizationState()
    @State private var locationStatus = CLLocationManager().authorizationStatus
    @State private var calendarState = EventKitProvider.authorizationState()
    @State private var isRequestingPermission = false
    @State private var isTopBarVisible = false

    private let steps = OnboardingStep.allCases
    private let maxOnboardingPermissionRequests = 3
    private let onboardingButtonPurple = AppColors.accentPurple

    var body: some View {
        ZStack(alignment: .bottom) {
            AppColors.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                if currentStep == 0 {
                    page(for: currentStep)
                        .id(currentStep)
                        .transition(contentTransition)
                        .animation(.smooth(duration: 0.3), value: currentStep)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    pagedContent
                        .id("paged-content")
                        .transition(contentTransition)
                }
            }

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
        .task {
            refreshPermissionState()
        }
    }

    // MARK: - Navigation

    private var topBar: some View {
        HStack(spacing: 14) {
            Button {
                move(to: currentStep - 1)
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
                            value: currentStep
                        )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 32)
    }

    private var visibleStepCount: Int {
        max(steps.count - 1, 0)
    }

    private var stepperIndex: Int {
        min(max(currentStep - 1, 0), max(visibleStepCount - 1, 0))
    }

    @ViewBuilder
    private var pagedContent: some View {
        GeometryReader { proxy in
            let contentTopPadding = pagedContentTopPadding(for: proxy.safeAreaInsets.top)

            HStack(spacing: 0) {
                ForEach(1..<steps.count, id: \.self) { index in
                    pagedPage(
                        for: index,
                        topPadding: contentTopPadding
                    )
                    .frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            .frame(
                width: proxy.size.width * CGFloat(max(steps.count - 1, 1)),
                height: proxy.size.height,
                alignment: .leading
            )
            .offset(x: -CGFloat(max(currentStep - 1, 0)) * proxy.size.width)
            .animation(.smooth(duration: 0.34), value: currentStep)
        }
        .clipped()
    }

    private func pagedContentTopPadding(for safeAreaTop: CGFloat) -> CGFloat {
        max(48, safeAreaTop + 16)
    }

    @ViewBuilder
    private func pagedPage(for index: Int, topPadding: CGFloat) -> some View {
        ViewThatFits(in: .vertical) {
            pageContent(for: index, topPadding: topPadding, bottomPadding: 112)

            ScrollView(showsIndicators: false) {
                pageContent(for: index, topPadding: topPadding, bottomPadding: 36)
            }
        }
    }

    @ViewBuilder
    private func pageContent(for index: Int, topPadding: CGFloat, bottomPadding: CGFloat) -> some View {
        page(for: index)
            .frame(maxWidth: .infinity)
            .padding(.top, topPadding)
            .padding(.bottom, bottomPadding)
    }

    @ViewBuilder
    private func page(for step: Int) -> some View {
        switch steps[step] {
        case .welcome:
            WelcomePage()
        case .library:
            WidgetLibraryPage()
        case .tutorial:
            TutorialPage()
        case .permissions:
            PermissionsPage(
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
            if currentStep == steps.count - 1 {
                onFinish()
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
                    .transition(blurFadeTransition)
                    .animation(.smooth(duration: 0.4).delay(0.02), value: primaryButtonTitle)

                if primaryButtonShowsLeadingIcon {
                    primaryButtonIcon
                        .transition(primaryButtonIconTransition)
                }
            }
            .font(AppFonts.font(.heading2))
            .foregroundStyle(primaryButtonForeground)
            .frame(maxWidth: .infinity)
            .frame(height: primaryButtonHeight)
            .background(primaryButtonBackground)
            .clipShape(Capsule())
            .animation(.smooth(duration: 0.24), value: currentStep)
        }
        .buttonStyle(.plain)
    }

    private var primaryButtonTitle: String {
        if currentStep == 0 {
            return L("onboarding.get_started")
        }

        return currentStep == steps.count - 1 ? L("onboarding.start") : L("onboarding.next")
    }

    private var primaryButtonForeground: Color {
        currentStep == 0 || currentStep == steps.count - 1 ? .white : AppColors.chipTextSelected
    }

    private var primaryButtonBackground: Color {
        currentStep == 0 || currentStep == steps.count - 1 ? onboardingButtonPurple : AppColors.chipSelected
    }

    private var primaryButtonIcon: some View {
        Image(systemName: primaryButtonIconName)
            .id(primaryButtonIconName)
            .symbolRenderingMode(.hierarchical)
            .animation(.smooth(duration: 0.18).delay(0.035), value: primaryButtonIconName)
    }

    private var primaryButtonIconTransition: AnyTransition {
        .asymmetric(
            insertion: .scale(scale: 0.84).combined(with: .opacity),
            removal: .scale(scale: 0.96).combined(with: .opacity)
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

    private func move(to step: Int) {
        guard steps.indices.contains(step), step != currentStep else { return }
        previousStep = currentStep

        if currentStep == 0, step > 0 {
            withAnimation(topBarShowAnimation.delay(0.12)) {
                isTopBarVisible = true
            }
        } else if step == 0 {
            withAnimation(topBarHideAnimation) {
                isTopBarVisible = false
            }
        }

        withAnimation(.smooth(duration: 0.3)) {
            currentStep = step
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
    case library
    case tutorial
    case permissions
}

private struct WidgetLibraryPage: View {
    var body: some View {
        VStack(spacing: 28) {
            ZStack {
                RoundedRectangle(cornerRadius: 38, style: .continuous)
                    .fill(AppColors.card)
                    .frame(width: 274, height: 310)
                    .shadow(color: .black.opacity(0.06), radius: 18, y: 12)

                VStack(spacing: 18) {
                    LibraryPreviewRow(title: "Gallery", value: "Explore")
                    LibraryPreviewRow(title: "Customize", value: "Theme")
                    LibraryPreviewRow(title: "Library", value: "Saved")
                }
                .padding(24)
                .frame(width: 274)
            }

            titleBlock(
                title: "Save once, place anywhere",
                subtitle: "Pick a widget, tune the look, then save it to your Library for the Home Screen picker."
            )
        }
        .padding(.horizontal, 28)
    }
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

#Preview {
    OnboardingScreen(onFinish: {})
        .environment(LocalizationManager.shared)
        .environment(\.locale, LocalizationManager.shared.locale)
}
