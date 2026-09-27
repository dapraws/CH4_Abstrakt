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
    @AppStorage(
        AppGroupConstants.reminderSelectedIdentifierKey,
        store: settingsStore
    ) private var reminderSelectedIdentifier = ""
    @AppStorage(
        AppGroupConstants.reminderSelectedTitleKey,
        store: settingsStore
    ) private var reminderSelectedTitle = ""
    @AppStorage(
        AppGroupConstants.gradientSmallThemeKey,
        store: settingsStore
    ) private var gradientSmallThemeID =
        GradientTheme.defaultTheme.id
    @AppStorage(
        AppGroupConstants.gradientMediumThemeKey,
        store: settingsStore
    ) private var gradientMediumThemeID =
        GradientTheme.defaultTheme.id
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID =
        AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore)
    private var sharedAppFontThemeID = AppFonts.defaultTheme.id
    @Environment(\.displayScale) private var displayScale
    @Environment(\.colorScheme) private var colorScheme
    @State private var showsAppsPicker = false
    @State private var showsFontPicker = false
    @State private var showsReminderPicker = false
    @State private var showingPermissionAlert = false
    @State private var isPerformingPrimaryAction = false
    @State private var appearanceMode: WidgetAppearanceMode = .system
    @State private var fontThemeID: String?
    @State private var initialConfiguration: WidgetSheetConfigurationSnapshot?

    private var activeGradientThemeID: String {
        item.size == .medium ? gradientMediumThemeID : gradientSmallThemeID
    }

    private var gradientTheme: GradientTheme {
        get {
            GradientTheme.from(id: activeGradientThemeID)
        }
        nonmutating set {
            if item.size == .medium {
                gradientMediumThemeID = newValue.id
            } else {
                gradientSmallThemeID = newValue.id
            }
            WidgetTimelineReloadScheduler.schedule()
        }
    }

    private var gradientThemeBinding: Binding<GradientTheme> {
        Binding {
            gradientTheme
        } set: { newValue in
            gradientTheme = newValue
        }
    }

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
        .sheet(isPresented: $showsReminderPicker) {
            ReminderPickerSheet(
                selectedReminderIdentifier: $reminderSelectedIdentifier,
                selectedReminderTitle: $reminderSelectedTitle
            )
            .presentationDetents([.fraction(0.72)])
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
        case .reminderItem:
            WidgetCustomizationSection(title: "Reminder") {
                ReminderCustomizationRow(
                    selectedReminderTitle: selectedReminderDisplayTitle
                ) {
                    showsReminderPicker = true
                }
            }
        case .gradientVariation:
            WidgetCustomizationSection(title: "Gradient Theme") {
                GradientPickerRow(
                    selection: gradientThemeBinding
                )
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
                if item.id == "reminder" {
                    let state = ReminderProvider.authorizationState()
                    if state == .notDetermined {
                        let granted = await ReminderProvider.requestReminderAccess()
                        if !granted {
                            Haptics.warning.play()
                            permissionAlertMessage = "Reminders access is required for Reminder widgets."
                            showingPermissionAlert = true
                            return false
                        }
                    } else if state == .denied || state == .restricted {
                        Haptics.warning.play()
                        permissionAlertMessage = "Reminders access is denied. Enable it in Settings to use Reminder widgets."
                        showingPermissionAlert = true
                        return false
                    }
                } else {
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
            let reminders = await ReminderProvider.currentSnapshot()
            SharedModelContainer.write(calendar: calendar)
            SharedModelContainer.write(reminders: reminders)
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
            supports(.reminderItem) ? reminderSelectedIdentifier : nil,
            supports(.gradientVariation) ? activeGradientThemeID : nil,
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
            fontThemeOverride: selectedWidgetFontTheme,
            gradientThemeOverride: supports(.gradientVariation)
                ? gradientTheme : nil
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
            eventModeID: eventModeID,
            reminderSelectedIdentifier: reminderSelectedIdentifier,
            gradientThemeID: activeGradientThemeID
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
            eventModeID: eventModeID,
            reminderSelectedIdentifier: reminderSelectedIdentifier,
            gradientThemeID: activeGradientThemeID
        )
    }

    private var selectedReminderDisplayTitle: String {
        if reminderSelectedTitle.isEmpty {
            return "Choose list"
        }

        return reminderSelectedTitle
    }
}

private struct WidgetSheetConfigurationSnapshot: Equatable {
    let appearanceMode: WidgetAppearanceMode
    let fontThemeID: String?
    let portalSelectedAppsValue: String
    let portalIconClipStyleID: String
    let activityModeID: String
    let eventModeID: String
    let reminderSelectedIdentifier: String
    let gradientThemeID: String
}

#Preview("Widget Preview Sheet — Gradient Small") {
    if let item = WidgetCatalog.item(withID: "gradient") {
        WidgetPreviewSheetPresentation(
            item: item,
            actionStyle: .saveToLibrary,
            onDismiss: {}
        )
    }
}

#Preview("Widget Preview Sheet — Gradient Medium") {
    if let item = WidgetCatalog.item(withID: "gradient-medium") {
        WidgetPreviewSheetPresentation(
            item: item,
            actionStyle: .saveToLibrary,
            onDismiss: {}
        )
    }
}
