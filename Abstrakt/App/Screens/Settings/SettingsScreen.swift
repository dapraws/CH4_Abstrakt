import SwiftUI
import WidgetKit

struct SettingsScreen: View {
    private static let settingsStore = UserDefaults(suiteName: AppGroupConstants.suiteName)

    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppSettingsPreference.temperatureUnitKey, store: settingsStore) private var temperatureUnitID = TemperatureUnitPreference.celsius.id
    @AppStorage(AppSettingsPreference.temperatureDisplayKey, store: settingsStore) private var temperatureDisplayID = TemperatureDisplayPreference.actual.id
    @AppStorage(AppSettingsPreference.distanceUnitKey, store: settingsStore) private var distanceUnitID = DistanceUnitPreference.kilometers.id
    @State private var showsFontPicker = false
    @State private var path: [SettingsRoute] = []

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
                            value: "Default",
                            route: .changeIcon
                        )
                    }

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

                    SettingsSection(title: "Widgets & Dynamic Island", fontTheme: selectedTheme) {
                        settingsNavigationRow(
                            icon: "heart.fill",
                            iconColor: .white,
                            iconBackground: Color(red: 1, green: 0.42, blue: 0.39),
                            title: "Access & Permissions",
                            value: "2",
                            route: .permissions,
                            valueStyle: .warning
                        )

                        settingsNavigationRow(
                            icon: "questionmark",
                            iconColor: .black,
                            iconBackground: Color(red: 1, green: 0.78, blue: 0.31),
                            title: "Help & FAQ",
                            route: .faq
                        )
                    }

                    SettingsSection(title: "Others", fontTheme: selectedTheme) {
                        settingsNavigationRow(
                            icon: "arrow.up",
                            iconColor: .white,
                            iconBackground: Color(red: 0.31, green: 0.56, blue: 1),
                            title: "What's New",
                            route: .whatsNew
                        )
                    }

                    footerActions

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
                .padding(.horizontal, AppSpacing.screenHorizontal)
            }
            .background(AppColors.appBackground.ignoresSafeArea())
            .navigationDestination(for: SettingsRoute.self) { route in
                SettingsDetailScreen(route: route) {
                    path.removeLast()
                }
            }
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $showsFontPicker) {
            FontPickerSheet()
                .presentationDetents([.fraction(0.36)])
        }
        .sensoryFeedback(.selection, trigger: temperatureUnitID)
        .sensoryFeedback(.selection, trigger: temperatureDisplayID)
        .sensoryFeedback(.selection, trigger: distanceUnitID)
    }

    private var footerActions: some View {
        HStack(spacing: 0) {
            footerAction(icon: "arrowshape.turn.up.right.fill", title: "Share App", color: Color(red: 0.08, green: 0.79, blue: 0.55))
            footerDivider
            footerAction(icon: "star.fill", title: "Rate Us", color: Color(red: 1, green: 0.75, blue: 0.28))
            footerDivider
            footerAction(icon: "at", title: "Feedback", color: Color(red: 0.43, green: 0.46, blue: 1))
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

    private func footerAction(icon: String, title: String, color: Color) -> some View {
        Button { } label: {
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

    @ViewBuilder
    private func temperatureUnitButton(_ unit: TemperatureUnitPreference) -> some View {
        Button {
            withAnimation(.smooth(duration: 0.18)) {
                temperatureUnitID = unit.id
            }
            WidgetCenter.shared.reloadAllTimelines()
        } label: {
            Label(unit.displayName, systemImage: temperatureUnit == unit ? "checkmark.circle.fill" : "circle")
        }
    }

    @ViewBuilder
    private func temperatureDisplayButton(_ display: TemperatureDisplayPreference) -> some View {
        Button {
            withAnimation(.smooth(duration: 0.18)) {
                temperatureDisplayID = display.id
            }
            WidgetCenter.shared.reloadAllTimelines()
        } label: {
            Label(display.displayName, systemImage: temperatureDisplay == display ? "checkmark.circle.fill" : "circle")
        }
    }

    @ViewBuilder
    private func distanceUnitButton(_ unit: DistanceUnitPreference) -> some View {
        Button {
            withAnimation(.smooth(duration: 0.18)) {
                distanceUnitID = unit.id
            }
            WidgetCenter.shared.reloadAllTimelines()
        } label: {
            Label(unit.displayName, systemImage: distanceUnit == unit ? "checkmark.circle.fill" : "circle")
        }
    }
}

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

private struct SettingsDetailScreen: View {
    let route: SettingsRoute
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
            detailCard(
                icon: "app.badge",
                iconBackground: Color(red: 0.08, green: 0.82, blue: 0.56),
                title: "Change Icon",
                status: "Default",
                statusColor: AppColors.accentBlue,
                detail: "Alternate app icons will be selectable here once the icon set is finalized."
            )
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
            permissionCard(
                icon: "heart.fill",
                iconBackground: LinearGradient(colors: [.pink, .red], startPoint: .top, endPoint: .bottom),
                title: "Health",
                status: "Connected",
                statusColor: AppColors.accentGreen,
                detail: "Used to display steps, sleep, heart rate, and other health data in widgets and Dynamic Island.",
                actionTitle: nil
            )

            permissionCard(
                icon: "location.fill",
                iconBackground: LinearGradient(colors: [.blue, .green.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing),
                title: "Location",
                status: "Connected",
                statusColor: AppColors.accentGreen,
                detail: "Used to display your current city, temperature, weather conditions, and other weather data in widgets and Dynamic Island.",
                actionTitle: nil
            )

            permissionCard(
                icon: "calendar",
                iconBackground: LinearGradient(colors: [.white, .red.opacity(0.78)], startPoint: .top, endPoint: .bottom),
                title: "Calendar",
                status: "Disconnected",
                statusColor: Color(red: 1, green: 0.42, blue: 0.44),
                detail: "Used to display upcoming calendar events in widgets and Dynamic Island.",
                actionTitle: "Connect"
            )
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
        actionTitle: String?
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
                    Button(actionTitle) { }
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
}

#Preview {
    SettingsScreen()
}
