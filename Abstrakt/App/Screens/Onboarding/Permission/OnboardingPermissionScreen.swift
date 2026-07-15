import CoreLocation
import SwiftUI

struct OnboardingPermissionScreen: View {
    @Environment(\.colorScheme) private var colorScheme

    let healthState: HealthPermissionState
    let locationStatus: CLAuthorizationStatus
    let calendarState: CalendarPermissionState
    let requestCount: Int
    let maxRequests: Int
    let isRequesting: Bool
    let requestHealth: () -> Void
    let requestLocation: () -> Void
    let requestCalendar: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            permissionHero
                .padding(.top, 8)
                .padding(.bottom, 12)

            permissionTextBlock
                .padding(.horizontal, 24)
                .padding(.bottom, 48)

            VStack(spacing: 10) {
                OnboardingPermissionRow(
                    icon: "heart.fill",
                    iconColor: AppColors.accentPink,
                    title: "Health widgets",
                    detail: "Steps, activity, sleep, and heart rate snapshots.",
                    isOn: healthState == .requested,
                    isEnabled: canRequestHealth || healthState == .requested,
                    action: requestHealth
                )

                OnboardingPermissionRow(
                    icon: "location.fill",
                    iconColor: AppColors.accentBlue,
                    title: "Weather widgets",
                    detail: "Local weather, daylight, and Portal place context.",
                    isOn: isLocationConnected,
                    isEnabled: canRequestLocation || isLocationConnected,
                    action: requestLocation
                )

                OnboardingPermissionRow(
                    icon: "calendar",
                    iconColor: Color(red: 0.97, green: 0.34, blue: 0.28),
                    title: "Calendar widgets",
                    detail: "Events, reminders, and date-aware layouts.",
                    isOn: isCalendarConnected,
                    isEnabled: canRequestCalendar || isCalendarConnected,
                    action: requestCalendar
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 26)
        }
    }

    private var permissionHero: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let viewportWidth = width
            let coneWidth = min(330, width * 0.52)

            ZStack(alignment: .top) {
                PermissionHeroCone()
                    .fill(heroBlurGradient)
                    .frame(width: coneWidth, height: 210)
                    .blur(radius: 5)
                    .mask(coneFadeMask)
                    .opacity(colorScheme == .dark ? 0.48 : 0.72)
                    .offset(y: 38)

                Image("permission")
                    .resizable()
                    .scaledToFit()
                    .frame(width: min(236, width * 0.72))
                    .offset(y: 12)
            }
            .frame(width: viewportWidth, height: proxy.size.height, alignment: .top)
        }
        .frame(height: 112)
    }

    private var permissionTextBlock: some View {
        VStack(spacing: 16) {
            Text("Power the widgets\nyou choose")
                .font(AppFonts.font(.title))
                .foregroundStyle(AppColors.primaryText)
                .multilineTextAlignment(.center)

            Text(permissionDetailSentence)
                .font(AppFonts.font(.body))
                .foregroundStyle(AppColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
                .frame(maxWidth: 360)
        }
        .frame(maxWidth: .infinity)
    }

    private var permissionDetailSentence: AttributedString {
        var sentence = AttributedString("Grant access when you're ready. Abstrakt\nonly asks for permissions as they're needed.")
        sentence.font = AppFonts.font(.body)
        sentence.foregroundColor = AppColors.secondaryText

        if let brandRange = sentence.range(of: "Abstrakt") {
            sentence[brandRange].font = AppFonts.font(.heading3, theme: .fusionPixel)
            sentence[brandRange].foregroundColor = AppColors.primaryText
        }

        return sentence
    }

    private var heroBlurGradient: LinearGradient {
        LinearGradient(
            colors: colorScheme == .dark
                ? [
                    Color(red: 0x45 / 255.0, green: 0x49 / 255.0, blue: 0x76 / 255.0).opacity(0.26),
                    Color(red: 0x1A / 255.0, green: 0x1D / 255.0, blue: 0x2D / 255.0).opacity(0.02),
                ]
                : [
                    Color(red: 0xD8 / 255.0, green: 0xD9 / 255.0, blue: 0xFF / 255.0).opacity(0.52),
                    Color(red: 0xF0 / 255.0, green: 0xF2 / 255.0, blue: 0xFC / 255.0).opacity(0.08),
                ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var coneFadeMask: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .white.opacity(0.92), location: 0),
                .init(color: .white.opacity(0.78), location: 0.45),
                .init(color: .white.opacity(0), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private var canRequestHealth: Bool {
        !isRequesting && requestCount < maxRequests && healthState == .notDetermined
    }

    private var canRequestLocation: Bool {
        !isRequesting && requestCount < maxRequests && locationStatus == .notDetermined
    }

    private var canRequestCalendar: Bool {
        !isRequesting && requestCount < maxRequests && calendarState == .notDetermined
    }

    private var isLocationConnected: Bool {
        switch locationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            true
        default:
            false
        }
    }

    private var isCalendarConnected: Bool {
        calendarState == .authorized
    }
}
