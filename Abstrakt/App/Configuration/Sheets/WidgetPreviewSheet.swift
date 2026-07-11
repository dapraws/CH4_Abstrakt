import CoreLocation
import SwiftUI
import WidgetKit

enum WidgetPreviewSheetActionStyle: Equatable {
    case saveToLibrary
    case removeFromLibrary(WidgetPreset)
}

struct WidgetPreviewSheetPresentation: View {
    let item: WidgetCatalogItem
    var actionStyle: WidgetPreviewSheetActionStyle = .saveToLibrary
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPresented = false
    @State private var dragOffset: CGFloat = 0

    private let upwardResistanceLimit: CGFloat = 28

    var body: some View {
        GeometryReader { proxy in
            let sheetHeight = proxy.size.height * 0.92
            let hiddenOffset = sheetHeight + upwardResistanceLimit

            ZStack(alignment: .bottom) {
                Color.black
                    .opacity(isPresented ? 0.24 : 0)
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture(perform: close)

                WidgetPreviewSheetContent(item: item, actionStyle: actionStyle)
                {
                    close()
                }
                .frame(width: proxy.size.width, height: sheetHeight)
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: 42,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 0,
                        topTrailingRadius: 42,
                        style: .continuous
                    )
                )
                .background(alignment: .bottom) {
                    AppColors.appBackground
                        .frame(height: upwardResistanceLimit)
                        .frame(maxWidth: .infinity)
                        .offset(y: upwardResistanceLimit)
                }
                .overlay(alignment: .top) {
                    sheetDragHandle
                }
                .offset(y: isPresented ? dragOffset : hiddenOffset)
            }
            .ignoresSafeArea()
            .allowsHitTesting(isPresented)
            .onAppear(perform: present)
        }
    }

    private var sheetDragHandle: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(AppColors.primaryText.opacity(0.16))
                .frame(width: 48, height: 6)
                .padding(.top, 9)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 48)
        .contentShape(Rectangle())
        .gesture(sheetDragGesture)
    }

    private var sheetDragGesture: some Gesture {
        DragGesture(minimumDistance: 4, coordinateSpace: .global)
            .onChanged { value in
                var transaction = Transaction()
                transaction.disablesAnimations = true

                withTransaction(transaction) {
                    dragOffset = interactiveDragOffset(value.translation.height)
                }
            }
            .onEnded { value in
                let shouldDismiss =
                    value.translation.height > 90
                    || value.predictedEndTranslation.height > 180

                if shouldDismiss {
                    close()
                } else {
                    withAnimation(
                        .interactiveSpring(
                            response: 0.22,
                            dampingFraction: 0.86
                        )
                    ) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func present() {
        guard !reduceMotion else {
            isPresented = true
            return
        }

        withAnimation(.smooth(duration: 0.48, extraBounce: 0)) {
            isPresented = true
        }
    }

    private func interactiveDragOffset(_ translation: CGFloat) -> CGFloat {
        if translation >= 0 {
            return translation
        }

        return max(translation * 0.18, -upwardResistanceLimit)
    }

    private func close() {
        guard !reduceMotion else {
            onDismiss()
            return
        }

        withAnimation(
            .smooth(duration: 0.34, extraBounce: 0),
            completionCriteria: .logicallyComplete
        ) {
            isPresented = false
            dragOffset = 0
        } completion: {
            onDismiss()
        }
    }
}

private struct WidgetPreviewSheetContent: View {
    private static let settingsStore = AppGroupConstants.sharedDefaults

    let item: WidgetCatalogItem
    let actionStyle: WidgetPreviewSheetActionStyle
    var onDismiss: (() -> Void)? = nil

    @AppStorage(AppGroupConstants.portalSelectedAppsKey, store: settingsStore)
    private var portalSelectedAppsValue = PortalApp.storageValue(
        for: PortalApp.defaultSelection
    )
    @AppStorage(AppGroupConstants.portalIconClipStyleKey, store: settingsStore)
    private var portalIconClipStyleID = PortalIconClipStyle.default.id
    @AppStorage(AppGroupConstants.activityModeKey, store: settingsStore) private
        var activityModeID = ActivityMode.today.id
    @AppStorage(AppGroupConstants.eventModeKey, store: settingsStore) private
        var eventModeID = EventDisplayMode.upcoming.id
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID =
        AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore)
    private var sharedAppFontThemeID = AppFonts.defaultTheme.id
    @Environment(\.displayScale) private var displayScale
    @Environment(\.colorScheme) private var colorScheme
    @State private var showsAppsPicker = false
    @State private var showsFontPicker = false
    @State private var showingPermissionAlert = false
    @State private var isPerformingPrimaryAction = false
    @State private var appearanceMode: WidgetAppearanceMode = .system
    @State private var fontThemeID: String?
    @State private var initialConfiguration: WidgetSheetConfigurationSnapshot?

    private var portalSelectedApps: [PortalApp] {
        get {
            PortalApp.selection(from: portalSelectedAppsValue)
        }
        nonmutating set {
            portalSelectedAppsValue = PortalApp.storageValue(for: newValue)
            WidgetTimelineReloadScheduler.schedule()
        }
    }

    private var portalIconClipStyle: PortalIconClipStyle {
        get {
            PortalIconClipStyle.from(id: portalIconClipStyleID)
        }
        nonmutating set {
            portalIconClipStyleID = newValue.id
            WidgetTimelineReloadScheduler.schedule()
        }
    }

    private var activityMode: ActivityMode {
        get {
            ActivityMode.from(id: activityModeID)
        }
        nonmutating set {
            activityModeID = newValue.id
            WidgetTimelineReloadScheduler.schedule()
        }
    }

    private var eventMode: EventDisplayMode {
        get {
            EventDisplayMode.from(id: eventModeID)
        }
        nonmutating set {
            eventModeID = newValue.id
            WidgetTimelineReloadScheduler.schedule()
        }
    }

    private var portalSelectedAppsBinding: Binding<[PortalApp]> {
        Binding {
            portalSelectedApps
        } set: { newValue in
            portalSelectedApps = newValue
        }
    }

    private var portalIconClipStyleBinding: Binding<PortalIconClipStyle> {
        Binding {
            portalIconClipStyle
        } set: { newValue in
            portalIconClipStyle = newValue
        }
    }

    private var activityModeBinding: Binding<ActivityMode> {
        Binding {
            activityMode
        } set: { newValue in
            activityMode = newValue
        }
    }

    private var eventModeBinding: Binding<EventDisplayMode> {
        Binding {
            eventMode
        } set: { newValue in
            eventMode = newValue
        }
    }

    private var previewScale: CGFloat {
        switch item.size {
        case .small:
            0.92
        case .medium:
            0.80
        case .large:
            0.72
        }
    }

    var body: some View {
        GeometryReader { proxy in
            let previewSize = item.size.previewSize(
                fittingWidth: max(
                    0,
                    proxy.size.width - (AppSpacing.screenHorizontal * 2)
                )
            )
            let scaledPreviewSize = CGSize(
                width: previewSize.width * previewScale,
                height: previewSize.height * previewScale
            )

            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        configuredPreview()
                            .id(previewIdentity)
                            .frame(
                                width: previewSize.width,
                                height: previewSize.height
                            )
                            .environment(\.colorScheme, previewColorScheme)
                            .scaleEffect(previewScale)
                            .frame(
                                width: scaledPreviewSize.width,
                                height: scaledPreviewSize.height
                            )

                        Text(
                            "\(item.displayName) | \(item.primaryCategory.localizedTitle)"
                        )
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                        .frame(maxWidth: .infinity, alignment: .center)

                        customizationControls
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 36)
                    .padding(.bottom, 132 + AppSpacing.bottomBarInset)
                }

                WidgetPreviewPrimaryButton(
                    configuration: primaryButtonConfiguration
                ) {
                    performPrimaryAction()
                }
                .animation(
                    .snappy(duration: 0.24, extraBounce: 0),
                    value: primaryButtonConfiguration.identity
                )
                .padding(.bottom, AppSpacing.bottomBarInset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.appBackground)
            .ignoresSafeArea(.container, edges: [.horizontal, .bottom])
            .onAppear(perform: syncConfigurationFromPreset)
            .alert(
                L("widget_preview.permission_alert.title"),
                isPresented: $showingPermissionAlert
            ) {
                Button(L("common.cancel"), role: .cancel) {}
                Button(L("widget_preview.permission_alert.open_settings")) {
                    if let url = URL(
                        string: UIApplication.openSettingsURLString
                    ) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text(
                    permissionAlertMessage
                        ?? L("widget_preview.permission_note")
                )
            }
        }
        .sheet(isPresented: $showsAppsPicker) {
            AppsPickerSheet(selectedApps: portalSelectedAppsBinding)
                .presentationDetents([.fraction(0.8)])
        }
        .sheet(isPresented: $showsFontPicker) {
            WidgetFontPickerSheet(selectedThemeID: $fontThemeID)
                .presentationDetents([.fraction(0.36)])
        }
    }

    @ViewBuilder
    private var customizationControls: some View {
        WidgetCustomizationSection(
            title: L("widget_preview.section.appearance")
        ) {
            WidgetAppearanceControls(mode: $appearanceMode)
        }
        .padding(.top, 10)

        WidgetCustomizationSection(title: L("widget_preview.section.font")) {
            WidgetFontCustomizationRow(
                selectedThemeName: selectedFontDisplayName,
                openFontPicker: {
                    showsFontPicker = true
                }
            )
        }
        .padding(.top, 10)

        ForEach(item.customizations) { customization in
            customizationSection(for: customization)
                .padding(.top, 10)
        }
    }

    @ViewBuilder
    private func customizationSection(for customization: WidgetCustomization)
        -> some View
    {
        switch customization {
        case .portalApps:
            WidgetCustomizationSection(
                title: L("widget_preview.section.application")
            ) {
                PortalCustomizationControls(
                    selectedApps: portalSelectedAppsBinding,
                    clipStyle: portalIconClipStyleBinding
                ) {
                    showsAppsPicker = true
                }
            }
        case .activityMode:
            WidgetCustomizationSection(
                title: L("widget_preview.section.data_range")
            ) {
                WidgetSegmentedControl(selection: activityModeBinding)
            }
        case .eventMode:
            WidgetCustomizationSection(
                title: L("widget_preview.section.event_priority")
            ) {
                WidgetSegmentedControl(selection: eventModeBinding)
            }
        }
    }

    private var isSaved: Bool {
        SharedModelContainer.readWidgetPresets().contains {
            $0.widgetID == item.id && $0.size == item.size
        }
    }

    private var primaryButtonConfiguration:
        WidgetPreviewPrimaryButtonConfiguration
    {
        if isPerformingPrimaryAction {
            return WidgetPreviewPrimaryButtonConfiguration(
                title: L("widget_preview.preparing"),
                systemImage: "hourglass",
                tint: .blue
            )
        }

        switch actionStyle {
        case .saveToLibrary:
            return WidgetPreviewPrimaryButtonConfiguration(
                title: isSaved
                    ? L("widget_preview.button.update")
                    : L("widget_preview.button.save"),
                systemImage: "checkmark.seal.fill",
                tint: .green
            )
        case .removeFromLibrary where libraryConfigurationHasChanges:
            return WidgetPreviewPrimaryButtonConfiguration(
                title: L("widget_preview.button.update"),
                systemImage: "checkmark.seal.fill",
                tint: .green
            )
        case .removeFromLibrary:
            return WidgetPreviewPrimaryButtonConfiguration(
                title: L("widget_preview.button.delete"),
                systemImage: "xmark.seal.fill",
                tint: .red
            )
        }
    }

    @State private var permissionAlertMessage: String?

    @MainActor
    private func performPrimaryAction() {
        guard !isPerformingPrimaryAction else {
            return
        }

        Haptics.primary.play()
        isPerformingPrimaryAction = true
        Task { @MainActor in
            var shouldResetActionState = true
            defer {
                if shouldResetActionState {
                    isPerformingPrimaryAction = false
                }
            }

            switch actionStyle {
            case .saveToLibrary:
                guard await requestPermissionsForCurrentWidget() else {
                    return
                }
                savePreset()
                Haptics.success.play()
                await refreshSavedWidgetData()
                shouldResetActionState = false
                onDismiss?()
            case .removeFromLibrary(let preset):
                if libraryConfigurationHasChanges {
                    guard await requestPermissionsForCurrentWidget() else {
                        return
                    }
                    savePreset()
                    Haptics.success.play()
                    await refreshSavedWidgetData()
                } else {
                    removePreset(preset)
                    Haptics.success.play()
                }
                shouldResetActionState = false
                onDismiss?()
            }
        }
    }

    @MainActor
    private func requestPermissionsForCurrentWidget() async -> Bool {
        for category in item.categories {
            switch category {
            case .healthKit:
                let state = HealthSummaryProvider.shared.authorizationState()
                if state == .unavailable {
                    Haptics.warning.play()
                    permissionAlertMessage = L("permission.health.unavailable")
                    showingPermissionAlert = true
                    return false
                }
                if state == .notDetermined {
                    _ = await HealthSummaryProvider.shared
                        .requestAuthorization()
                }
            case .weatherKit:
                let status = CLLocationManager().authorizationStatus
                if status == .notDetermined {
                    let finalStatus = await LocationProvider()
                        .requestAuthorizationStatus()
                    if finalStatus != .authorizedWhenInUse
                        && finalStatus != .authorizedAlways
                    {
                        Haptics.warning.play()
                        permissionAlertMessage = L(
                            "permission.location.required"
                        )
                        showingPermissionAlert = true
                        return false
                    }
                } else if status == .denied || status == .restricted {
                    Haptics.warning.play()
                    permissionAlertMessage = L("permission.location.denied")
                    showingPermissionAlert = true
                    return false
                }
            case .eventKit:
                let state = EventKitProvider.authorizationState()
                if state == .notDetermined {
                    let granted = await EventKitProvider.requestCalendarAccess()
                    if !granted {
                        Haptics.warning.play()
                        permissionAlertMessage = L(
                            "permission.calendar.required"
                        )
                        showingPermissionAlert = true
                        return false
                    }
                } else if state == .denied || state == .restricted {
                    Haptics.warning.play()
                    permissionAlertMessage = L("permission.calendar.denied")
                    showingPermissionAlert = true
                    return false
                }
            default:
                break
            }
        }
        return true
    }

    @MainActor
    private func refreshSavedWidgetData() async {
        if item.categories.contains(.healthKit) {
            let health = await HealthSummaryProvider.shared.todaySnapshot()
            let activity = await HealthSummaryProvider.shared
                .activitySnapshots()
            let heartRate = await HealthSummaryProvider.shared.latestHeartRate()
            SharedModelContainer.write(health: health)
            SharedModelContainer.write(activity: activity)
            SharedModelContainer.write(heartRate: heartRate)
        }

        if item.categories.contains(.weatherKit)
            || item.categories.contains(.portal)
        {
            let today = await WeatherProvider.shared.todaySnapshot()
            let portal = await WeatherProvider.shared.portalSnapshot()
            let weather = await WeatherProvider.shared.weatherSnapshot()
            let daylight = await WeatherProvider.shared.daylightSnapshot()
            SharedModelContainer.write(today: today)
            SharedModelContainer.write(portal: portal)
            SharedModelContainer.write(weather: weather)
            SharedModelContainer.write(daylight: daylight)
        }

        if item.categories.contains(.eventKit) {
            let calendar = await EventKitProvider.currentSnapshot()
            SharedModelContainer.write(calendar: calendar)
        }

        WidgetTimelineReloadScheduler.reloadNow()
    }

    @MainActor
    private func savePreset() {
        var presets = SharedModelContainer.readWidgetPresets()
        let existingIndex: Array<WidgetPreset>.Index?

        switch actionStyle {
        case .saveToLibrary:
            existingIndex = presets.firstIndex {
                $0.widgetID == item.id && $0.size == item.size
            }
        case .removeFromLibrary(let preset):
            existingIndex = presets.firstIndex { $0.id == preset.id }
        }

        let presetID = existingIndex.map { presets[$0].id } ?? UUID()
        let savedPreset = WidgetPreset(
            id: presetID,
            widgetID: item.id,
            name: item.displayName,
            size: item.size,
            appearanceMode: appearanceMode,
            fontThemeID: fontThemeID
        )

        let preview = configuredPreview(isThumbnail: true)
            .frame(width: 160, height: 160)
            .environment(\.colorScheme, thumbnailColorScheme)

        let renderer = ImageRenderer(content: preview)
        renderer.scale = displayScale

        if let image = renderer.uiImage, let data = image.pngData() {
            SharedModelContainer.saveThumbnail(
                data,
                for: savedPreset.id.uuidString
            )
        }

        if let existingIndex {
            presets[existingIndex] = savedPreset
        } else {
            presets.append(savedPreset)
        }

        SharedModelContainer.write(widgetPresets: presets)
        WidgetTimelineReloadScheduler.reloadNow()
    }

    @MainActor
    private func removePreset(_ preset: WidgetPreset) {
        SharedModelContainer.removeWidgetPreset(id: preset.id)
        WidgetTimelineReloadScheduler.reloadNow()
    }

    private var previewIdentity: String {
        previewIdentityComponents.joined(separator: "-")
    }

    private var previewIdentityComponents: [String] {
        [
            item.id,
            appearanceMode.id,
            fontThemeID ?? "app",
            supports(.portalApps) ? portalSelectedAppsValue : nil,
            supports(.portalApps) ? portalIconClipStyleID : nil,
            supports(.activityMode) ? activityModeID : nil,
            supports(.eventMode) ? eventModeID : nil,
        ].compactMap { $0 }
    }

    private func supports(_ customization: WidgetCustomization) -> Bool {
        item.customizations.contains(customization)
    }

    private func configuredPreview(isThumbnail: Bool = false) -> some View {
        WidgetPreview(
            item: item,
            isThumbnail: isThumbnail,
            portalSelectedAppsOverride: supports(.portalApps)
                ? portalSelectedApps : nil,
            portalIconClipStyleOverride: supports(.portalApps)
                ? portalIconClipStyle : nil,
            activityModeOverride: supports(.activityMode) ? activityMode : nil,
            eventModeOverride: supports(.eventMode) ? eventMode : nil,
            fontThemeOverride: selectedWidgetFontTheme
        )
    }

    private var selectedWidgetFontTheme: AbstraktWidgetFontTheme? {
        guard let fontThemeID else {
            return nil
        }

        return AbstraktWidgetFontTheme(rawValue: fontThemeID) ?? .quicksand
    }

    private var selectedFontDisplayName: String {
        guard let fontThemeID else {
            return AppFontTheme.from(id: activeAppFontThemeID).displayName
        }

        return AppFontTheme.from(id: fontThemeID).displayName
    }

    private var activeAppFontThemeID: String {
        sharedAppFontThemeID.isEmpty ? appFontThemeID : sharedAppFontThemeID
    }

    private var previewColorScheme: ColorScheme {
        appearanceMode.colorScheme ?? colorScheme
    }

    private var thumbnailColorScheme: ColorScheme {
        appearanceMode.colorScheme ?? colorScheme
    }

    private var currentConfiguration: WidgetSheetConfigurationSnapshot {
        WidgetSheetConfigurationSnapshot(
            appearanceMode: appearanceMode,
            fontThemeID: fontThemeID,
            portalSelectedAppsValue: portalSelectedAppsValue,
            portalIconClipStyleID: portalIconClipStyleID,
            activityModeID: activityModeID,
            eventModeID: eventModeID
        )
    }

    private var libraryConfigurationHasChanges: Bool {
        guard case .removeFromLibrary = actionStyle,
            let initialConfiguration
        else {
            return false
        }

        return currentConfiguration != initialConfiguration
    }

    private func syncConfigurationFromPreset() {
        let sourcePreset: WidgetPreset?

        switch actionStyle {
        case .saveToLibrary:
            sourcePreset = SharedModelContainer.readWidgetPresets().first {
                $0.widgetID == item.id && $0.size == item.size
            }
        case .removeFromLibrary(let preset):
            sourcePreset = preset
        }

        appearanceMode = sourcePreset?.appearanceMode ?? .system
        fontThemeID = sourcePreset?.fontThemeID
        initialConfiguration = WidgetSheetConfigurationSnapshot(
            appearanceMode: sourcePreset?.appearanceMode ?? .system,
            fontThemeID: sourcePreset?.fontThemeID,
            portalSelectedAppsValue: portalSelectedAppsValue,
            portalIconClipStyleID: portalIconClipStyleID,
            activityModeID: activityModeID,
            eventModeID: eventModeID
        )
    }
}

private struct WidgetSheetConfigurationSnapshot: Equatable {
    let appearanceMode: WidgetAppearanceMode
    let fontThemeID: String?
    let portalSelectedAppsValue: String
    let portalIconClipStyleID: String
    let activityModeID: String
    let eventModeID: String
}

private struct WidgetCustomizationSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(AppFonts.font(.heading4))
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal, 4)

            content
        }
        .frame(maxWidth: 360, alignment: .leading)
    }
}

private struct WidgetAppearanceControls: View {
    @Binding var mode: WidgetAppearanceMode

    var body: some View {
        GeometryReader { proxy in
            let options = WidgetAppearanceMode.allCases
            let selectedIndex = options.firstIndex(of: mode) ?? 0
            let innerPadding: CGFloat = 5
            let segmentWidth = max(
                0,
                (proxy.size.width - (innerPadding * 2)) / CGFloat(options.count)
            )

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.card)
                    .frame(width: segmentWidth, height: 58)
                    .offset(
                        x: innerPadding
                            + (CGFloat(selectedIndex) * segmentWidth)
                    )
                    .animation(
                        .snappy(duration: 0.24, extraBounce: 0),
                        value: mode
                    )

                HStack(spacing: 0) {
                    ForEach(options) { option in
                        Button {
                            Haptics.selection.play()
                            mode = option
                        } label: {
                            Label(option.title, systemImage: option.systemImage)
                                .font(AppFonts.font(.heading4))
                                .foregroundStyle(AppColors.primaryText)
                                .labelStyle(.titleAndIcon)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(innerPadding)
            }
            .background(AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .frame(maxWidth: 360)
        .frame(height: 68)
    }
}

private struct WidgetFontCustomizationRow: View {
    let selectedThemeName: String
    let openFontPicker: () -> Void

    var body: some View {
        Button {
            Haptics.selection.play()
            openFontPicker()
        } label: {
            HStack(spacing: 16) {
                Image(systemName: "t.square.fill")
                    .font(AppFonts.font(.title))

                Capsule()
                    .fill(AppColors.primaryText.opacity(0.16))
                    .frame(width: 2, height: 20)

                Spacer(minLength: 10)

                Text(selectedThemeName)
                    .font(AppFonts.font(.heading3))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Image(systemName: "chevron.right")
                    .font(AppFonts.font(.heading4))
                    .foregroundStyle(AppColors.primaryText.opacity(0.42))
            }
            .padding(.horizontal, 18)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .buttonStyle(.plain)
        .frame(maxWidth: 360)
        .accessibilityLabel("Choose widget font")
    }
}

private struct WidgetFontPickerSheet: View {
    private static let settingsStore = AppGroupConstants.sharedDefaults

    @Binding var selectedThemeID: String?
    @Environment(\.dismiss) private var dismiss
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID =
        AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore)
    private var sharedAppFontThemeID = AppFonts.defaultTheme.id

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 14),
        count: 2
    )
    private let tileCornerRadius: CGFloat = 24
    private var activeAppFontTheme: AppFontTheme {
        AppFontTheme.from(
            id: sharedAppFontThemeID.isEmpty
                ? appFontThemeID : sharedAppFontThemeID
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                SheetHeaderSymbol(systemName: "textformat")

                Text(L("font_picker.title"))
                    .font(AppFonts.font(.heading2))
                    .foregroundStyle(AppColors.primaryText)

                Spacer()

                Button {
                    Haptics.selection.play()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(AppFonts.font(.heading3))
                        .foregroundStyle(AppColors.primaryText)
                        .frame(width: 42, height: 42)
                        .background(AppColors.cardSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            LazyVGrid(columns: columns, spacing: 14) {
                ForEach(AppFontTheme.allCases) { theme in
                    fontTile(
                        title: tileTitle(for: theme),
                        themeID: theme.id,
                        fontTheme: theme
                    )
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 20)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(AppColors.appBackground)
        .sensoryFeedback(.selection, trigger: selectedThemeID)
    }

    private func fontTile(
        title: String,
        themeID: String,
        fontTheme: AppFontTheme
    ) -> some View {
        let isSelected =
            selectedThemeID == themeID
            || (selectedThemeID == nil && themeID == activeAppFontTheme.id)

        return Button {
            Haptics.selection.play()
            withAnimation(.smooth(duration: 0.18)) {
                selectedThemeID = themeID
            }
        } label: {
            ZStack {
                Text(title)
                    .font(AppFonts.font(.heading3, theme: fontTheme))
                    .lineSpacing(
                        AppFonts.lineSpacing(.heading3, theme: fontTheme)
                    )
                    .foregroundStyle(AppColors.primaryText)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.72)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 88)
            .background(
                isSelected
                    ? AppColors.primaryText.opacity(0.06) : AppColors.cardSoft
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: tileCornerRadius,
                    style: .continuous
                )
            )
            .overlay {
                if isSelected {
                    RoundedRectangle(
                        cornerRadius: tileCornerRadius - 6,
                        style: .continuous
                    )
                    .stroke(
                        AppColors.primaryText.opacity(0.28),
                        style: StrokeStyle(
                            lineWidth: 2,
                            dash: [7, 5],
                            dashPhase: 0
                        )
                    )
                    .padding(6)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.smooth(duration: 0.18), value: isSelected)
    }

    private func tileTitle(for theme: AppFontTheme) -> String {
        switch theme {
        case .sfPro:
            "SF Pro"
        case .sfProRounded:
            "SF Rounded"
        case .quicksand:
            "Quicksand"
        case .fusionPixel:
            "Fusion\nPixel"
        }
    }
}

private struct PortalCustomizationControls: View {
    @Binding var selectedApps: [PortalApp]
    @Binding var clipStyle: PortalIconClipStyle
    let openAppsPicker: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Button {
                Haptics.selection.play()
                openAppsPicker()
            } label: {
                HStack(spacing: -9) {
                    ForEach(selectedApps.prefix(6), id: \.rawValue) { app in
                        Image(app.assetName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 34, height: 34)
                            .clipShape(
                                PortalIconShape(
                                    style: clipStyle,
                                    cornerRadius: 11
                                )
                            )
                    }
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(AppColors.cardSoft)
                .clipShape(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Choose MiniApps")

            PortalClipStyleMenu(clipStyle: $clipStyle)
        }
        .frame(maxWidth: 360)
    }
}

private struct PortalClipStyleMenu: View {
    @Binding var clipStyle: PortalIconClipStyle

    var body: some View {
        Menu {
            ForEach(PortalIconClipStyle.allCases) { style in
                Button {
                    Haptics.selection.play()
                    withAnimation(.smooth(duration: 0.18)) {
                        clipStyle = style
                    }
                } label: {
                    Label(
                        style.title,
                        systemImage: clipStyle == style
                            ? "checkmark.circle.fill" : style.systemImage
                    )
                }
            }
        } label: {
            Label("Icon clip style", systemImage: clipStyle.systemImage)
                .font(AppFonts.font(.heading3))
                .foregroundStyle(AppColors.primaryText)
                .labelStyle(.iconOnly)
                .frame(width: 58, height: 58)
                .background(AppColors.cardSoft)
                .clipShape(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                )
        }
        .buttonStyle(.plain)
    }
}

private protocol WidgetSegmentedOption: CaseIterable, Hashable, Identifiable
where AllCases: Collection, AllCases.Element == Self {
    var title: String { get }
    var customizationSystemImage: String { get }
}

extension ActivityMode: WidgetSegmentedOption {
    var customizationSystemImage: String {
        switch self {
        case .today:
            "sun.max.fill"
        case .weekly:
            "calendar.badge.clock"
        }
    }
}

extension EventDisplayMode: WidgetSegmentedOption {
    var customizationSystemImage: String {
        switch self {
        case .upcoming:
            "calendar.badge.clock"
        case .current:
            "calendar.badge.exclamationmark"
        }
    }
}

private struct WidgetSegmentedControl<Option: WidgetSegmentedOption>: View {
    @Binding var selection: Option

    var body: some View {
        GeometryReader { proxy in
            let options = Array(Option.allCases)
            let selectedIndex = options.firstIndex(of: selection) ?? 0
            let innerPadding: CGFloat = 5
            let segmentWidth = max(
                0,
                (proxy.size.width - (innerPadding * 2)) / CGFloat(options.count)
            )

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.card)
                    .frame(width: segmentWidth, height: 48)
                    .offset(
                        x: innerPadding
                            + (CGFloat(selectedIndex) * segmentWidth)
                    )
                    .animation(
                        .snappy(duration: 0.24, extraBounce: 0),
                        value: selection
                    )

                HStack(spacing: 0) {
                    ForEach(options) { option in
                        Button {
                            Haptics.selection.play()
                            selection = option
                        } label: {
                            Label(
                                option.title,
                                systemImage: option.customizationSystemImage
                            )
                            .font(AppFonts.font(.heading3))
                            .foregroundStyle(AppColors.primaryText)
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(innerPadding)
            }
            .background(AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .frame(maxWidth: 360)
        .frame(height: 58)
    }
}

private struct WidgetPreviewPrimaryButtonConfiguration {
    let title: String
    let systemImage: String
    let tint: Color

    var identity: String {
        "\(title)-\(systemImage)"
    }

    var isLoading: Bool {
        systemImage == "hourglass"
    }
}

private struct WidgetPreviewPrimaryButton: View {
    let configuration: WidgetPreviewPrimaryButtonConfiguration
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                WidgetPreviewPrimaryButtonContent(configuration: configuration)
                    .id(configuration.identity)
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(
                                with: .scale(scale: 0.96)
                            ),
                            removal: .opacity.combined(
                                with: .scale(scale: 1.04)
                            )
                        )
                    )
            }
            .frame(maxWidth: 256)
            .frame(height: 64)
        }
        .buttonStyle(.plain)
        .disabled(configuration.isLoading)
        .background(Color.white)
        .clipShape(Capsule())
        .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 1)
        .animation(
            .snappy(duration: 0.24, extraBounce: 0),
            value: configuration.identity
        )
    }
}

private struct WidgetPreviewPrimaryButtonContent: View {
    let configuration: WidgetPreviewPrimaryButtonConfiguration
    @State private var shimmerPhase: CGFloat = -1

    var body: some View {
        buttonLabel
            .foregroundStyle(configuration.tint.opacity(0.72))
            .overlay {
                GeometryReader { proxy in
                    buttonLabel
                        .foregroundStyle(
                            LinearGradient(
                                stops: [
                                    .init(
                                        color: configuration.tint.opacity(0),
                                        location: 0
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0.12),
                                        location: 0.32
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0.54),
                                        location: 0.5
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0.12),
                                        location: 0.68
                                    ),
                                    .init(
                                        color: configuration.tint.opacity(0),
                                        location: 1
                                    ),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .mask(
                            Capsule()
                                .frame(
                                    width: proxy.size.width * 0.42,
                                    height: proxy.size.height * 1.35
                                )
                                .blur(radius: 6)
                                .rotationEffect(.degrees(8))
                                .offset(x: proxy.size.width * shimmerPhase)
                        )
                        .opacity(0.9)
                }
                .allowsHitTesting(false)
            }
            .symbolEffect(
                .pulse.wholeSymbol,
                options: .repeating.speed(0.35),
                value: shimmerPhase > 0
            )
            .onAppear {
                shimmerPhase = -0.9
                withAnimation(
                    .easeInOut(duration: 4.4).repeatForever(autoreverses: false)
                ) {
                    shimmerPhase = 1.45
                }
            }
    }

    private var buttonLabel: some View {
        HStack(spacing: 10) {
            Image(systemName: configuration.systemImage)
                .font(AppFonts.font(.heading2))
                .contentTransition(.symbolEffect(.replace))

            Text(configuration.title)
                .font(AppFonts.font(.heading2))
                .contentTransition(.opacity)
        }
    }
}
