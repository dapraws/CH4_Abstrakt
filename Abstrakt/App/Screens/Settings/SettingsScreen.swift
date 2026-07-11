import CoreLocation
import SwiftUI
import UIKit
import WidgetKit

struct SettingsScreen: View {
    // MARK: - Storage

    private static let settingsStore = AppGroupConstants.sharedDefaults

    // MARK: - State

    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID =
        AppFonts.defaultTheme.id
    @AppStorage(AppSettingsPreference.temperatureUnitKey, store: settingsStore)
    private var temperatureUnitID = TemperatureUnitPreference.celsius.id
    @AppStorage(
        AppSettingsPreference.temperatureDisplayKey,
        store: settingsStore
    ) private var temperatureDisplayID = TemperatureDisplayPreference.actual.id
    @AppStorage(AppSettingsPreference.distanceUnitKey, store: settingsStore)
    private var distanceUnitID = DistanceUnitPreference.kilometers.id
    @Environment(\.scenePhase) private var scenePhase
    @State private var permissionSnapshot = PermissionAccessSnapshot.loading
    @State private var showsFontPicker = false
    @State private var showsShareSheet = false
    @Environment(LocalizationManager.self) private var localization
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
            ScrollFadeView(
                showsIndicators: false,
                headerHeight: 36,
                contentTopPadding: 8,
                contentBottomPadding: 78,
                coordinateSpaceName: "settingsScroll"
            ) { fadeProgress in
                FadingNavigationBar(fadeProgress: fadeProgress) {
                    Text(L("settings.title"))
                        .font(AppFonts.font(.heading2))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(maxWidth: .infinity)
                }
            } content: {
                VStack(spacing: 20) {
                    headerActions
                    generalSection
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
                    AppIconScreen {
                        path.removeLast()
                    }
                case .changeLanguage:
                    LanguageScreen {
                        path.removeLast()
                    }
                case .permissions:
                    PermissionsScreen(permissionSnapshot: $permissionSnapshot) {
                        path.removeLast()
                    }
                case .faq:
                    FAQScreen {
                        path.removeLast()
                    }
                case .whatsNew:
                    WhatsNewScreen {
                        path.removeLast()
                    }
                }
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .task {
            await refreshPermissionSnapshot()
        }
        .onChange(of: localization.currentLanguage) { _, _ in
            Task { await refreshPermissionSnapshot() }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase == .active else { return }
            refreshCurrentAppIcon()
            Task {
                await refreshPermissionSnapshot()
            }
        }
        .onChange(of: path) { _, newPath in
            // Returning from the icon screen: reflect any new selection.
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

    private var generalSection: some View {
        SettingsSection(
            title: L("settings.section.general"),
            fontTheme: selectedTheme
        ) {
            settingsNavigationRow(
                icon: "globe",
                iconColor: .white,
                iconBackground: Color(red: 0.31, green: 0.56, blue: 1),
                title: L("settings.row.language"),
                value: localization.currentLanguage.displayName,
                route: .changeLanguage
            )
        }
    }

    private var displayAppearanceSection: some View {
        SettingsSection(
            title: L("settings.section.display_appearance"),
            fontTheme: selectedTheme
        ) {
            settingsButtonRow(
                icon: "textformat",
                iconColor: .white,
                iconBackground: AppColors.accentBlue,
                title: L("settings.row.app_font"),
                value: selectedTheme.displayName
            ) {
                showsFontPicker = true
            }

            settingsNavigationRow(
                icon: "app.badge",
                iconColor: .white,
                iconBackground: Color(red: 0.08, green: 0.82, blue: 0.56),
                title: L("settings.row.change_icon"),
                value: currentAppIcon.localizedName,
                route: .changeIcon
            )
        }
    }

    private var temperatureSection: some View {
        SettingsSection(
            title: L("settings.section.temperature"),
            fontTheme: selectedTheme
        ) {
            settingsMenuRow(
                icon: "sun.max.fill",
                iconColor: .white,
                iconBackground: Color(red: 1, green: 0.55, blue: 0.36),
                title: L("settings.row.temperature_unit"),
                value: temperatureUnit.localizedName
            ) {
                temperatureUnitButton(.celsius)
                temperatureUnitButton(.fahrenheit)
            }

            settingsMenuRow(
                icon: "thermometer.medium",
                iconColor: .white,
                iconBackground: Color(red: 0.31, green: 0.56, blue: 1),
                title: L("settings.row.temperature_display"),
                value: temperatureDisplay.localizedName
            ) {
                temperatureDisplayButton(.actual)
                temperatureDisplayButton(.feelsLike)
            }
        }
    }

    private var measurementsSection: some View {
        SettingsSection(
            title: L("settings.section.measurements"),
            fontTheme: selectedTheme
        ) {
            settingsMenuRow(
                icon: "figure.walk",
                iconColor: .white,
                iconBackground: Color(red: 0.45, green: 0.36, blue: 1),
                title: L("settings.row.distance_unit"),
                value: distanceUnit.localizedName
            ) {
                distanceUnitButton(.kilometers)
                distanceUnitButton(.miles)
            }
        }
    }

    private var widgetsSection: some View {
        SettingsSection(
            title: L("settings.section.widgets"),
            fontTheme: selectedTheme
        ) {
            settingsNavigationRow(
                icon: "heart.fill",
                iconColor: .white,
                iconBackground: Color(red: 1, green: 0.42, blue: 0.39),
                title: L("settings.row.permissions"),
                value: permissionSnapshot.summaryValue,
                route: .permissions,
                valueStyle: permissionSnapshot.needsAttention
                    ? .warning : .plain
            )

            settingsNavigationRow(
                icon: "questionmark",
                iconColor: .black,
                iconBackground: Color(red: 1, green: 0.78, blue: 0.31),
                title: L("settings.row.faq"),
                route: .faq
            )
        }
    }

    private var othersSection: some View {
        SettingsSection(
            title: L("settings.section.others"),
            fontTheme: selectedTheme
        ) {
            settingsNavigationRow(
                icon: "arrow.up",
                iconColor: .white,
                iconBackground: Color(red: 0.31, green: 0.56, blue: 1),
                title: L("settings.row.whats_new"),
                route: .whatsNew
            )
        }
    }

    private var aboutFooter: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.fill")
                .font(AppFonts.font(.heading2))
                .foregroundStyle(AppColors.accentPink)

            BrandCreditFooter(
                fontRole: .caption,
                fontTheme: selectedTheme,
                secondaryColor: AppColors.tertiaryText
            )
        }
        .padding(.top, 6)
        .padding(.bottom, 24)
    }

    // MARK: - Header Actions

    private var headerActions: some View {
        HStack(spacing: 0) {
            footerAction(
                icon: "arrowshape.turn.up.right.fill",
                title: L("settings.header.share_app"),
                color: Color(red: 0.08, green: 0.79, blue: 0.55)
            ) {
                showsShareSheet = true
            }
            footerDivider
            footerAction(
                icon: "star.fill",
                title: L("settings.header.rate_us"),
                color: Color(red: 1, green: 0.75, blue: 0.28)
            ) {
                rateApp()
            }
            footerDivider
            footerAction(
                icon: "at",
                title: L("settings.header.feedback"),
                color: Color(red: 0.43, green: 0.46, blue: 1)
            ) {
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

    private func footerAction(
        icon: String,
        title: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
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
    private func temperatureUnitButton(_ unit: TemperatureUnitPreference)
        -> some View
    {
        Button {
            setTemperatureUnit(unit)
        } label: {
            Label(
                unit.localizedName,
                systemImage: temperatureUnit == unit
                    ? "checkmark.circle.fill" : "circle"
            )
        }
    }

    @ViewBuilder
    private func temperatureDisplayButton(
        _ display: TemperatureDisplayPreference
    ) -> some View {
        Button {
            setTemperatureDisplay(display)
        } label: {
            Label(
                display.displayName,
                systemImage: temperatureDisplay == display
                    ? "checkmark.circle.fill" : "circle"
            )
        }
    }

    @ViewBuilder
    private func distanceUnitButton(_ unit: DistanceUnitPreference) -> some View
    {
        Button {
            setDistanceUnit(unit)
        } label: {
            Label(
                unit.localizedName,
                systemImage: distanceUnit == unit
                    ? "checkmark.circle.fill" : "circle"
            )
        }
    }

    private func setTemperatureUnit(_ unit: TemperatureUnitPreference) {
        withAnimation(.smooth(duration: 0.18)) {
            temperatureUnitID = unit.id
        }
        reloadWidgetTimelines()
    }

    private func setTemperatureDisplay(_ display: TemperatureDisplayPreference)
    {
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
    case changeLanguage
    case permissions
    case faq
    case whatsNew
}

private enum SettingsRowValueStyle {
    case plain
    case warning
}

// MARK: - Permissions

struct PermissionAccessSnapshot {
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
                PermissionAccessItem.health(
                    state: HealthSummaryProvider.shared.authorizationState()
                ),
                PermissionAccessItem.location(
                    status: CLLocationManager().authorizationStatus
                ),
                PermissionAccessItem.calendar(
                    state: EventKitProvider.authorizationState()
                ),
                PermissionAccessItem.systemData,
            ]
        )
    }
}

struct PermissionAccessItem: Identifiable {
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
                gradientColors: [AppColors.accentPink],
                title: L("permission.item.health.title"),
                status: .ready(L("permission.status.requested")),
                detail: L("permission.item.health.detail.requested"),
                action: nil
            )
        case .notDetermined:
            return PermissionAccessItem(
                id: "health",
                icon: "heart.fill",
                gradientColors: [AppColors.accentPink],
                title: L("permission.item.health.title"),
                status: .needsRequest(L("permission.status.needs_access")),
                detail: L("permission.item.health.detail.needs"),
                action: .requestHealth
            )
        case .unavailable:
            return PermissionAccessItem(
                id: "health",
                icon: "heart.fill",
                gradientColors: [.gray],
                title: L("permission.item.health.title"),
                status: .unavailable(L("permission.status.unavailable")),
                detail: L("permission.item.health.detail.unavailable"),
                action: nil
            )
        }
    }

    static func location(status: CLAuthorizationStatus) -> PermissionAccessItem
    {
        let base = PermissionAccessItem(
            id: "location",
            icon: "location.fill",
            gradientColors: [AppColors.accentBlue],
            title: L("permission.item.location.title"),
            status: .ready(L("permission.status.allowed")),
            detail: L("permission.item.location.detail.allowed"),
            action: nil
        )

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            return base
        case .notDetermined:
            return base.replacing(
                status: .needsRequest(L("permission.status.needs_access")),
                detail: L("permission.item.location.detail.needs"),
                action: .requestLocation
            )
        case .denied:
            return base.replacing(
                status: .blocked(L("permission.status.denied")),
                detail: L("permission.item.location.detail.denied"),
                action: .openSettings
            )
        case .restricted:
            return base.replacing(
                status: .blocked(L("permission.status.restricted")),
                detail: L("permission.item.location.detail.restricted"),
                action: .openSettings
            )
        @unknown default:
            return base.replacing(
                status: .blocked(L("permission.status.unknown")),
                detail: L("permission.item.location.detail.unknown"),
                action: .openSettings
            )
        }
    }

    static func calendar(state: CalendarPermissionState) -> PermissionAccessItem
    {
        let base = PermissionAccessItem(
            id: "calendar",
            icon: "calendar",
            gradientColors: [Color(red: 1, green: 0.42, blue: 0.39)],
            title: L("permission.item.calendar.title"),
            status: .ready(L("permission.status.allowed")),
            detail: L("permission.item.calendar.detail.allowed"),
            action: nil
        )

        switch state {
        case .authorized:
            return base
        case .notDetermined:
            return base.replacing(
                status: .needsRequest(L("permission.status.needs_access")),
                detail: L("permission.item.calendar.detail.needs"),
                action: .requestCalendar
            )
        case .denied:
            return base.replacing(
                status: .blocked(L("permission.status.denied")),
                detail: L("permission.item.calendar.detail.denied"),
                action: .openSettings
            )
        case .restricted:
            return base.replacing(
                status: .blocked(L("permission.status.restricted")),
                detail: L("permission.item.calendar.detail.restricted"),
                action: .openSettings
            )
        case .limited:
            return base.replacing(
                status: .blocked(L("permission.status.limited")),
                detail: L("permission.item.calendar.detail.limited"),
                action: .openSettings
            )
        }
    }

    static var systemData: PermissionAccessItem {
        PermissionAccessItem(
            id: "system",
            icon: "internaldrive.fill",
            gradientColors: [Color(red: 0.31, green: 0.56, blue: 1)],
            title: L("permission.item.system.title"),
            status: .ready(L("permission.status.no_permission_needed")),
            detail: L("permission.item.system.detail"),
            action: nil
        )
    }

    private func replacing(
        status: PermissionAccessStatus,
        detail: String,
        action: PermissionAccessAction?
    ) -> PermissionAccessItem {
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

enum PermissionAccessStatus {
    case ready(String)
    case needsRequest(String)
    case blocked(String)
    case unavailable(String)

    var title: String {
        switch self {
        case .ready(let title), .needsRequest(let title), .blocked(let title),
            .unavailable(let title):
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

enum PermissionAccessAction {
    case requestHealth
    case requestLocation
    case requestCalendar
    case openSettings

    var title: String {
        switch self {
        case .requestHealth, .requestLocation, .requestCalendar:
            L("permission.action.connect")
        case .openSettings:
            L("permission.action.settings")
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
                .clipShape(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                )

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

#Preview {
    SettingsScreen()
        .environment(LocalizationManager.shared)
        .environment(\.locale, LocalizationManager.shared.locale)
}
