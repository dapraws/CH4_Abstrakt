import CoreLocation
import SwiftUI
import UIKit
import WidgetKit

struct SettingsScreen: View {
    // MARK: - Storage

    private static let settingsStore = AppGroupConstants.sharedDefaults

    // MARK: - State

    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppSettingsPreference.temperatureUnitKey, store: settingsStore) private var temperatureUnitID = TemperatureUnitPreference.celsius.id
    @AppStorage(AppSettingsPreference.temperatureDisplayKey, store: settingsStore) private var temperatureDisplayID = TemperatureDisplayPreference.actual.id
    @AppStorage(AppSettingsPreference.distanceUnitKey, store: settingsStore) private var distanceUnitID = DistanceUnitPreference.kilometers.id
    @Environment(\.scenePhase) private var scenePhase
    @State private var permissionSnapshot = PermissionAccessSnapshot.loading
    @State private var showsFontPicker = false
    @State private var showsShareSheet = false
    @State private var currentAppIcon = AppIconOption.from(
        alternateIconName: UIApplication.shared.alternateIconName
    )
    @State private var path: [SettingsRoute] = []

    // MARK: - Derived Settings

    private var selectedTheme: AppFontTheme {
        AppFontTheme.from(id: appFontThemeID)
    }

    private var temperatureUnit: TemperatureUnitPreference {
        TemperatureUnitPreference.from(id: temperatureUnitID)
    }

    private var temperatureDisplay: TemperatureDisplayPreference {
        TemperatureDisplayPreference.from(id: temperatureDisplayID)
    }

    private var distanceUnit: DistanceUnitPreference {
        DistanceUnitPreference.from(id: distanceUnitID)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack(path: $path) {
            ScrollFadeView(showsIndicators: false, headerHeight: 36, contentTopPadding: 8, contentBottomPadding: 78, coordinateSpaceName: "settingsScroll") { fadeProgress in
                FadingNavigationBar(fadeProgress: fadeProgress) {
                    Text("Settings")
                        .font(AppFonts.font(.heading2))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(maxWidth: .infinity)
                }
            } content: {
                VStack(spacing: 20) {
                    headerActions
                    displayAppearanceSection
                    temperatureSection
                    measurementsSection
                    widgetsSection
                    othersSection
                    aboutFooter
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
            .background(AppColors.appBackground.ignoresSafeArea())
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .changeIcon:
                    AppIconPickerScreen {
                        path.removeLast()
                    }
                default:
                    SettingsDetailScreen(route: route, permissionSnapshot: $permissionSnapshot) {
                        path.removeLast()
                    }
                }
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .task {
            await refreshPermissionSnapshot()
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            refreshCurrentAppIcon()
            Task {
                await refreshPermissionSnapshot()
            }
        }
        .onChange(of: path) { _, newPath in
            // Returning from the icon picker: reflect any new selection.
            if newPath.isEmpty {
                refreshCurrentAppIcon()
            }
        }
        .sheet(isPresented: $showsFontPicker) {
            FontPickerSheet()
                .presentationDetents([.fraction(0.36)])
        }
        .sheet(isPresented: $showsShareSheet) {
            ShareAppSheet()
                .presentationDetents([.fraction(0.48)])
        }
        .sensoryFeedback(.selection, trigger: temperatureUnitID)
        .sensoryFeedback(.selection, trigger: temperatureDisplayID)
        .sensoryFeedback(.selection, trigger: distanceUnitID)
    }

    // MARK: - Sections

    private var displayAppearanceSection: some View {
        SettingsSection(title: "Display & Appearance", fontTheme: selectedTheme) {
            settingsButtonRow(
                icon: "textformat",
                iconColor: .white,
                iconBackground: AppColors.accentBlue,
                title: "App Font",
                value: selectedTheme.displayName
            ) {
                showsFontPicker = true
            }

            settingsNavigationRow(
                icon: "app.badge",
                iconColor: .white,
                iconBackground: Color(red: 0.08, green: 0.82, blue: 0.56),
                title: "Change Icon",
                value: currentAppIcon.displayName,
                route: .changeIcon
            )
        }
    }

    private var temperatureSection: some View {
        SettingsSection(title: "Temperature", fontTheme: selectedTheme) {
            settingsMenuRow(
                icon: "sun.max.fill",
                iconColor: .white,
                iconBackground: Color(red: 1, green: 0.55, blue: 0.36),
                title: "Temperature Unit",
                value: temperatureUnit.displayName
            ) {
                temperatureUnitButton(.celsius)
                temperatureUnitButton(.fahrenheit)
            }

            settingsMenuRow(
                icon: "thermometer.medium",
                iconColor: .white,
                iconBackground: Color(red: 0.31, green: 0.56, blue: 1),
                title: "Temperature Display",
                value: temperatureDisplay.displayName
            ) {
                temperatureDisplayButton(.actual)
                temperatureDisplayButton(.feelsLike)
            }
        }
    }

    private var measurementsSection: some View {
        SettingsSection(title: "Measurements", fontTheme: selectedTheme) {
            settingsMenuRow(
                icon: "figure.walk",
                iconColor: .white,
                iconBackground: Color(red: 0.45, green: 0.36, blue: 1),
                title: "Distance Unit",
                value: distanceUnit.displayName
            ) {
                distanceUnitButton(.kilometers)
                distanceUnitButton(.miles)
            }
        }
    }

    private var widgetsSection: some View {
        SettingsSection(title: "Widgets & Dynamic Island", fontTheme: selectedTheme) {
            settingsNavigationRow(
                icon: "heart.fill",
                iconColor: .white,
                iconBackground: Color(red: 1, green: 0.42, blue: 0.39),
                title: "Access & Permissions",
                value: permissionSnapshot.summaryValue,
                route: .permissions,
                valueStyle: permissionSnapshot.needsAttention ? .warning : .plain
            )

            settingsNavigationRow(
                icon: "questionmark",
                iconColor: .black,
                iconBackground: Color(red: 1, green: 0.78, blue: 0.31),
                title: "Help & FAQ",
                route: .faq
            )
        }
    }

    private var othersSection: some View {
        SettingsSection(title: "Others", fontTheme: selectedTheme) {
            settingsNavigationRow(
                icon: "arrow.up",
                iconColor: .white,
                iconBackground: Color(red: 0.31, green: 0.56, blue: 1),
                title: "What's New",
                route: .whatsNew
            )
        }
    }

    private var aboutFooter: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .font(AppFonts.font(.heading2))
                .foregroundStyle(AppColors.accentPink)

            Text("Made by SSJ (1.23.0) Build 01")
                .font(AppFonts.font(.caption))
                .foregroundStyle(AppColors.tertiaryText)
        }
        .padding(.top, 6)
        .padding(.bottom, 24)
    }

    // MARK: - Header Actions

    private var headerActions: some View {
        HStack(spacing: 0) {
            footerAction(icon: "arrowshape.turn.up.right.fill", title: "Share App", color: Color(red: 0.08, green: 0.79, blue: 0.55)) {
                showsShareSheet = true
            }
            footerDivider
            footerAction(icon: "star.fill", title: "Rate Us", color: Color(red: 1, green: 0.75, blue: 0.28)) {
                rateApp()
            }
            footerDivider
            footerAction(icon: "at", title: "Feedback", color: Color(red: 0.43, green: 0.46, blue: 1)) {
                sendFeedback()
            }
        }
        .padding(.vertical, 18)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var footerDivider: some View {
        Rectangle()
            .fill(AppColors.separator)
            .frame(width: 1, height: 48)
    }

    private func footerAction(icon: String, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(AppFonts.font(.heading2))
                    .foregroundStyle(color)
                    .frame(height: 28)

                Text(title)
                    .font(AppFonts.font(.caption))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Rows

    private func settingsButtonRow(
        icon: String,
        iconColor: Color,
        iconBackground: Color,
        title: String,
        value: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            SettingsRowContent(
                icon: icon,
                iconColor: iconColor,
                iconBackground: iconBackground,
                title: title,
                value: value,
                valueStyle: .plain,
                fontTheme: selectedTheme,
                showsChevron: true
            )
        }
        .buttonStyle(.plain)
    }

    private func settingsNavigationRow(
        icon: String,
        iconColor: Color,
        iconBackground: Color,
        title: String,
        value: String? = nil,
        route: SettingsRoute,
        valueStyle: SettingsRowValueStyle = .plain
    ) -> some View {
        Button {
            path.append(route)
        } label: {
            SettingsRowContent(
                icon: icon,
                iconColor: iconColor,
                iconBackground: iconBackground,
                title: title,
                value: value,
                valueStyle: valueStyle,
                fontTheme: selectedTheme,
                showsChevron: value == nil
            )
        }
        .buttonStyle(.plain)
    }

    private func settingsMenuRow<Content: View>(
        icon: String,
        iconColor: Color,
        iconBackground: Color,
        title: String,
        value: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        SettingsRowContent(
            icon: icon,
            iconColor: iconColor,
            iconBackground: iconBackground,
            title: title,
            value: value,
            valueStyle: .plain,
            fontTheme: selectedTheme,
            showsChevron: false
        )
        .overlay(alignment: .trailing) {
            Menu {
                content()
            } label: {
                Color.clear
            }
            .frame(width: 156, height: 54)
            .contentShape(Rectangle())
        }
    }

    // MARK: - Menu Actions

    @ViewBuilder
    private func temperatureUnitButton(_ unit: TemperatureUnitPreference) -> some View {
        Button {
            setTemperatureUnit(unit)
        } label: {
            Label(unit.displayName, systemImage: temperatureUnit == unit ? "checkmark.circle.fill" : "circle")
        }
    }

    @ViewBuilder
    private func temperatureDisplayButton(_ display: TemperatureDisplayPreference) -> some View {
        Button {
            setTemperatureDisplay(display)
        } label: {
            Label(display.displayName, systemImage: temperatureDisplay == display ? "checkmark.circle.fill" : "circle")
        }
    }

    @ViewBuilder
    private func distanceUnitButton(_ unit: DistanceUnitPreference) -> some View {
        Button {
            setDistanceUnit(unit)
        } label: {
            Label(unit.displayName, systemImage: distanceUnit == unit ? "checkmark.circle.fill" : "circle")
        }
    }

    private func setTemperatureUnit(_ unit: TemperatureUnitPreference) {
        withAnimation(.smooth(duration: 0.18)) {
            temperatureUnitID = unit.id
        }
        reloadWidgetTimelines()
    }

    private func setTemperatureDisplay(_ display: TemperatureDisplayPreference) {
        withAnimation(.smooth(duration: 0.18)) {
            temperatureDisplayID = display.id
        }
        reloadWidgetTimelines()
    }

    private func setDistanceUnit(_ unit: DistanceUnitPreference) {
        withAnimation(.smooth(duration: 0.18)) {
            distanceUnitID = unit.id
        }
        reloadWidgetTimelines()
    }

    private func reloadWidgetTimelines() {
        WidgetTimelineReloadScheduler.schedule()
    }

    // MARK: - Header Action Handlers

    private func rateApp() {
        // On App Store builds the native in-app review prompt is preferred.
        // It's silent on TestFlight and rate-limited by iOS, so for a testable
        // result now we open the App Store review page directly. Swap to the
        // `requestReview()` path once the listing is live if you want the
        // native prompt to take priority.
        UIApplication.shared.open(AppShareContent.appStoreReviewURL)
    }

    private func sendFeedback() {
        guard let url = AppShareContent.feedbackMailtoURL() else { return }
        UIApplication.shared.open(url)
    }

    private func refreshCurrentAppIcon() {
        currentAppIcon = AppIconOption.from(
            alternateIconName: UIApplication.shared.alternateIconName
        )
    }

    @MainActor
    private func refreshPermissionSnapshot() async {
        permissionSnapshot = await PermissionAccessSnapshot.current()
    }
}

// MARK: - Routes

private enum SettingsRoute: Hashable {
    case changeIcon
    case permissions
    case faq
    case whatsNew
}

private enum SettingsRowValueStyle {
    case plain
    case warning
}

// MARK: - Permissions

private struct PermissionAccessSnapshot {
    var items: [PermissionAccessItem]
    var isLoading: Bool = false

    static let loading = PermissionAccessSnapshot(items: [], isLoading: true)

    var actionRequiredCount: Int {
        items.filter(\.needsAttention).count
    }

    var needsAttention: Bool {
        actionRequiredCount > 0
    }

    var summaryValue: String {
        guard !isLoading else { return "..." }
        return needsAttention ? "\(actionRequiredCount)" : "OK"
    }

    @MainActor
    static func current() async -> PermissionAccessSnapshot {
        PermissionAccessSnapshot(
            items: [
                PermissionAccessItem.health(state: HealthSummaryProvider.shared.authorizationState()),
                PermissionAccessItem.location(status: CLLocationManager().authorizationStatus),
                PermissionAccessItem.calendar(state: EventKitProvider.authorizationState()),
                PermissionAccessItem.systemData,
            ]
        )
    }
}

private struct PermissionAccessItem: Identifiable {
    let id: String
    let icon: String
    let gradientColors: [Color]
    let title: String
    let status: PermissionAccessStatus
    let detail: String
    let action: PermissionAccessAction?

    var needsAttention: Bool {
        status.needsAttention
    }

    static func health(state: HealthPermissionState) -> PermissionAccessItem {
        switch state {
        case .requested:
            return PermissionAccessItem(
                id: "health",
                icon: "heart.fill",
                gradientColors: [.pink, .red],
                title: "Health",
                status: .ready("Requested"),
                detail: "Used for steps, walking distance, exercise minutes, active energy, and sleep totals. iOS keeps exact Health read grants private after the request.",
                action: nil
            )
        case .notDetermined:
            return PermissionAccessItem(
                id: "health",
                icon: "heart.fill",
                gradientColors: [.pink, .red],
                title: "Health",
                status: .needsRequest("Needs Access"),
                detail: "Allow Health access so widgets can use your real activity, distance, energy, and sleep data.",
                action: .requestHealth
            )
        case .unavailable:
            return PermissionAccessItem(
                id: "health",
                icon: "heart.fill",
                gradientColors: [.gray, .secondary],
                title: "Health",
                status: .unavailable("Unavailable"),
                detail: "Health data is not available on this device, so health widgets will render empty values.",
                action: nil
            )
        }
    }

    static func location(status: CLAuthorizationStatus) -> PermissionAccessItem {
        let base = PermissionAccessItem(
            id: "location",
            icon: "location.fill",
            gradientColors: [.blue, .green.opacity(0.75)],
            title: "Location & Weather",
            status: .ready("Allowed"),
            detail: "Used to fetch local WeatherKit conditions, city names, temperatures, forecasts, and sun-event widgets.",
            action: nil
        )

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return base
        case .notDetermined:
            return base.replacing(status: .needsRequest("Needs Access"), detail: "Allow location access so weather widgets can use your current place.", action: .requestLocation)
        case .denied:
            return base.replacing(status: .blocked("Denied"), detail: "Location access is denied. Weather widgets will use cached or placeholder data until access is enabled.", action: .openSettings)
        case .restricted:
            return base.replacing(status: .blocked("Restricted"), detail: "Location access is restricted on this device. Weather widgets will use cached or placeholder data.", action: .openSettings)
        @unknown default:
            return base.replacing(status: .blocked("Unknown"), detail: "Location access is in an unknown state. Open Settings to review it.", action: .openSettings)
        }
    }

    static func calendar(state: CalendarPermissionState) -> PermissionAccessItem {
        let base = PermissionAccessItem(
            id: "calendar",
            icon: "calendar",
            gradientColors: [.white, .red.opacity(0.78)],
            title: "Calendar",
            status: .ready("Allowed"),
            detail: "Used to show current and upcoming calendar events in the Events widget.",
            action: nil
        )

        switch state {
        case .authorized:
            return base
        case .notDetermined:
            return base.replacing(status: .needsRequest("Needs Access"), detail: "Allow calendar access so the widget can show your next event and now-running events.", action: .requestCalendar)
        case .denied:
            return base.replacing(status: .blocked("Denied"), detail: "Calendar access is denied. Calendar widgets will show a permission state until access is enabled.", action: .openSettings)
        case .restricted:
            return base.replacing(status: .blocked("Restricted"), detail: "Calendar access is restricted on this device. Calendar widgets will show a permission state.", action: .openSettings)
        case .limited:
            return base.replacing(status: .blocked("Limited"), detail: "Calendar access is limited. Full calendar access is needed to show event widgets reliably.", action: .openSettings)
        }
    }

    static let systemData = PermissionAccessItem(
        id: "system",
        icon: "internaldrive.fill",
        gradientColors: [Color(red: 0.31, green: 0.56, blue: 1), Color(red: 0.08, green: 0.79, blue: 0.55)],
        title: "Battery & Storage",
        status: .ready("No Permission Needed"),
        detail: "Battery level and aggregate storage capacity come from system APIs that do not require a user permission prompt.",
        action: nil
    )

    private func replacing(status: PermissionAccessStatus, detail: String, action: PermissionAccessAction?) -> PermissionAccessItem {
        PermissionAccessItem(
            id: id,
            icon: icon,
            gradientColors: gradientColors,
            title: title,
            status: status,
            detail: detail,
            action: action
        )
    }
}

private enum PermissionAccessStatus {
    case ready(String)
    case needsRequest(String)
    case blocked(String)
    case unavailable(String)

    var title: String {
        switch self {
        case .ready(let title), .needsRequest(let title), .blocked(let title), .unavailable(let title):
            title
        }
    }

    var color: Color {
        switch self {
        case .ready:
            AppColors.accentGreen
        case .needsRequest:
            Color(red: 1, green: 0.58, blue: 0.22)
        case .blocked, .unavailable:
            Color(red: 1, green: 0.42, blue: 0.44)
        }
    }

    var needsAttention: Bool {
        switch self {
        case .ready:
            false
        case .needsRequest, .blocked, .unavailable:
            true
        }
    }
}

private enum PermissionAccessAction {
    case requestHealth
    case requestLocation
    case requestCalendar
    case openSettings

    var title: String {
        switch self {
        case .requestHealth, .requestLocation, .requestCalendar:
            "Connect"
        case .openSettings:
            "Settings"
        }
    }
}

// MARK: - Shared Rows

private struct SettingsSection<Content: View>: View {
    let title: String
    let fontTheme: AppFontTheme
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(AppFonts.font(.subHeading, theme: fontTheme))
                .foregroundStyle(AppColors.tertiaryText)
                .padding(.leading, 20)

            VStack(spacing: 0) {
                content
            }
            .padding(.vertical, 12)
            .background(AppColors.card)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }
}

private struct SettingsRowContent: View {
    let icon: String
    let iconColor: Color
    let iconBackground: Color
    let title: String
    let value: String?
    let valueStyle: SettingsRowValueStyle
    let fontTheme: AppFontTheme
    let showsChevron: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(AppFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(iconColor)
                .frame(width: 34, height: 34)
                .background(iconBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(AppFonts.font(.subHeading, theme: fontTheme))
                .foregroundStyle(AppColors.primaryText)
                .lineLimit(1)

            Spacer(minLength: 10)

            if let value {
                valuePill(value)
            }

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(AppFonts.font(.caption, theme: fontTheme))
                    .foregroundStyle(AppColors.tertiaryText)
            }
        }
        .padding(.horizontal, 22)
        .frame(height: 54)
    }

    @ViewBuilder
    private func valuePill(_ value: String) -> some View {
        switch valueStyle {
        case .plain:
            Text(value)
                .font(AppFonts.font(.caption, theme: fontTheme))
                .foregroundStyle(AppColors.secondaryText)
                .lineLimit(1)
                .padding(.horizontal, 14)
                .frame(height: 34)
                .background(AppColors.appBackground.opacity(0.55))
                .clipShape(Capsule())
        case .warning:
            HStack(spacing: 5) {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(value)
            }
            .font(AppFonts.font(.caption, theme: fontTheme))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Color(red: 1, green: 0.42, blue: 0.32))
            .clipShape(Capsule())
        }
    }
}

// MARK: - Detail Screen

private struct SettingsDetailScreen: View {
    let route: SettingsRoute
    @Binding var permissionSnapshot: PermissionAccessSnapshot
    let onBack: () -> Void

    var body: some View {
        ScrollFadeView(showsIndicators: false, headerHeight: 36, contentTopPadding: 12, coordinateSpaceName: "settingsDetailScroll") { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                header
            }
        } content: {
            VStack(spacing: 16) {
                content
                    .padding(.bottom, 120)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
        }
        .background(AppColors.appBackground.ignoresSafeArea())
        .toolbarVisibility(.hidden, for: .navigationBar)
        .task {
            guard route == .permissions else { return }
            await refreshPermissionSnapshot()
        }
    }

    private var header: some View {
        ZStack {
            Text(title)
                .font(AppFonts.font(.heading2))
                .foregroundStyle(AppColors.primaryText)
                .frame(maxWidth: .infinity)

            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 42, height: 42)
                        .background(AppColors.card)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch route {
        case .permissions:
            permissionsContent
        case .faq:
            detailCard(
                icon: "questionmark",
                iconBackground: Color(red: 1, green: 0.78, blue: 0.31),
                title: "Help & FAQ",
                status: "Ready",
                statusColor: AppColors.accentGreen,
                detail: "Answers for widgets, permissions, refresh timing, and customization will live here."
            )
        case .changeIcon:
            // Handled by AppIconPickerScreen via navigationDestination; never
            // rendered here. Kept for switch exhaustiveness.
            EmptyView()
        case .whatsNew:
            detailCard(
                icon: "arrow.up",
                iconBackground: Color(red: 0.31, green: 0.56, blue: 1),
                title: "What's New",
                status: "Build 19",
                statusColor: AppColors.accentBlue,
                detail: "Custom fonts, widget previews, library sheets, and shared unit preferences are now part of the app foundation."
            )
        }
    }

    private var permissionsContent: some View {
        VStack(spacing: 14) {
            ForEach(permissionSnapshot.items) { item in
                permissionCard(item)
            }
        }
    }

    private var title: String {
        switch route {
        case .changeIcon:
            "Change Icon"
        case .permissions:
            "Access & Permissions"
        case .faq:
            "Help & FAQ"
        case .whatsNew:
            "What's New"
        }
    }

    private func detailCard(icon: String, iconBackground: Color, title: String, status: String, statusColor: Color, detail: String) -> some View {
        detailCard(icon: icon, iconBackground: LinearGradient(colors: [iconBackground, iconBackground], startPoint: .top, endPoint: .bottom), title: title, status: status, statusColor: statusColor, detail: detail)
    }

    private func detailCard(icon: String, iconBackground: LinearGradient, title: String, status: String, statusColor: Color, detail: String) -> some View {
        permissionCard(icon: icon, iconBackground: iconBackground, title: title, status: status, statusColor: statusColor, detail: detail, actionTitle: nil)
    }

    private func permissionCard(
        icon: String,
        iconBackground: LinearGradient,
        title: String,
        status: String,
        statusColor: Color,
        detail: String,
        actionTitle: String?,
        action: @escaping () -> Void = {}
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                    Text(status)
                        .font(AppFonts.font(.caption))
                        .foregroundStyle(statusColor)
                }

                Spacer()

                if let actionTitle {
                    Button(actionTitle, action: action)
                        .font(AppFonts.font(.meta))
                        .foregroundStyle(AppColors.primaryText)
                        .padding(.horizontal, 14)
                        .frame(height: 30)
                        .background(AppColors.appBackground.opacity(0.6))
                        .clipShape(Capsule())
                }
            }

            Text(detail)
                .font(AppFonts.font(.caption))
                .lineSpacing(AppFonts.lineSpacing(.caption))
                .foregroundStyle(AppColors.primaryText)
        }
        .padding(16)
        .background(AppColors.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func permissionCard(_ item: PermissionAccessItem) -> some View {
        permissionCard(
            icon: item.icon,
            iconBackground: LinearGradient(colors: item.gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
            title: item.title,
            status: item.status.title,
            statusColor: item.status.color,
            detail: item.detail,
            actionTitle: item.action?.title
        ) {
            guard let action = item.action else { return }
            Task {
                await performPermissionAction(action)
            }
        }
    }

    @MainActor
    private func performPermissionAction(_ action: PermissionAccessAction) async {
        switch action {
        case .requestHealth:
            await HealthSummaryProvider.shared.requestAuthorization()
        case .requestLocation:
            _ = await LocationProvider().requestAuthorizationStatus()
        case .requestCalendar:
            _ = await EventKitProvider.requestCalendarAccess()
        case .openSettings:
            openAppSettings()
        }

        await refreshPermissionSnapshot()
    }

    @MainActor
    private func refreshPermissionSnapshot() async {
        permissionSnapshot = await PermissionAccessSnapshot.current()
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}

#Preview {
    SettingsScreen()
}
