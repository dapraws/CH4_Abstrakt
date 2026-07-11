//
//  ContentView.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 22/06/26.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    // MARK: - Constants

    private static let clockRefreshInterval: Duration = .seconds(1)
    private static let slowDataRefreshInterval: Duration = .seconds(60)
    private static let libraryTransitionAnimation = Animation.smooth(duration: 0.2)

    // MARK: - Environment

    @Environment(\.scenePhase) private var scenePhase

    // MARK: - State

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @State private var selectedTab: BottomBarTab = .gallery
    @State private var showsLibrary = false
    @State private var selectedGalleryItem: WidgetCatalogItem?
    @State private var selectedLibraryPreset: WidgetPreset?
    @State private var widgetPresets = SharedModelContainer.readWidgetPresets()
    @State private var hasRequestedHealthAuth = false

    // MARK: - Properties

    private let runsLiveWidgetTasks: Bool
    private let previewHasCompletedOnboarding: Bool?

    private var shouldRunRefreshLoops: Bool {
        runsLiveWidgetTasks && scenePhase == .active && !widgetPresets.isEmpty
    }

    private var shouldObserveHealth: Bool {
        runsLiveWidgetTasks && savedWidgetCategories().contains(.healthKit)
    }

    init(
        runsLiveWidgetTasks: Bool = true,
        initialTab: BottomBarTab = .gallery,
        previewHasCompletedOnboarding: Bool? = nil
    ) {
        self.runsLiveWidgetTasks = runsLiveWidgetTasks
        self.previewHasCompletedOnboarding = previewHasCompletedOnboarding
        _selectedTab = State(initialValue: initialTab)
    }

    private var libraryCount: Int {
        widgetPresets.count
    }

    // MARK: - Body

    var body: some View {
        Group {
            if previewHasCompletedOnboarding ?? hasCompletedOnboarding {
                appShell
            } else {
                OnboardingScreen {
                    hasCompletedOnboarding = true
                }
            }
        }
        .onChange(of: appFontThemeID) { _, newValue in
            SharedModelContainer.write(appFontThemeID: newValue)
            WidgetTimelineReloadScheduler.schedule()
        }
        .onReceive(NotificationCenter.default.publisher(for: SharedModelContainer.widgetPresetsDidChangeNotification)) { _ in
            reloadWidgetPresets()
        }
        .task(id: shouldObserveHealth) {
            guard shouldObserveHealth else {
                return
            }

            HealthSummaryProvider.shared.startObservingTodayMetrics {
                Task { @MainActor in
                    await refreshHealthWidgetData()
                    WidgetTimelineReloadScheduler.schedule()
                }
            }
        }
        .task(id: scenePhase) {
            guard runsLiveWidgetTasks, scenePhase == .active else {
                return
            }

            await refreshBaselineWidgetData(reloadsTimelines: true)

            if shouldObserveHealth,
               !hasRequestedHealthAuth,
               HealthSummaryProvider.shared.authorizationState() == .notDetermined {
                hasRequestedHealthAuth = true
                try? await Task.sleep(for: .milliseconds(800))
                await HealthSummaryProvider.shared.requestAuthorization()
            }

            try? await Task.sleep(for: .milliseconds(220))

            if !widgetPresets.isEmpty {
                await refreshSavedWidgetData()
            }
        }
        .task(id: shouldRunRefreshLoops) {
            guard shouldRunRefreshLoops else {
                return
            }

            await runRefreshLoops()
        }
    }

    // MARK: - App Shell

    private var appShell: some View {
        ZStack(alignment: .bottom) {
            currentScreen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.appBackground)
                .blur(radius: showsLibrary ? 18 : 0)
                .animation(Self.libraryTransitionAnimation, value: showsLibrary)

            bottomBarEffect
                .opacity(showsLibrary ? 0 : 1)
                .animation(Self.libraryTransitionAnimation, value: showsLibrary)

            BottomBar(
                selectedTab: bottomBarSelection,
                libraryCount: libraryCount,
                isLibraryPresented: showsLibrary
            ) {
                withAnimation(Self.libraryTransitionAnimation) {
                    showsLibrary = false
                }
            }
            .animation(Self.libraryTransitionAnimation, value: showsLibrary)
            .zIndex(3)

            if showsLibrary {
                LibraryScreen(presets: widgetPresets) { preset in
                    selectedLibraryPreset = preset
                }
                    .transition(.opacity)
                    .zIndex(2)
            }

            if let selectedGalleryItem {
                WidgetPreviewSheetPresentation(item: selectedGalleryItem, actionStyle: .saveToLibrary) {
                    reloadWidgetPresets()
                    self.selectedGalleryItem = nil
                }
                .zIndex(4)
            }

            if let selectedLibraryPreset,
               let selectedLibraryItem = WidgetCatalog.item(withID: selectedLibraryPreset.widgetID) {
                WidgetPreviewSheetPresentation(
                    item: selectedLibraryItem,
                    actionStyle: .removeFromLibrary(selectedLibraryPreset)
                ) {
                    reloadWidgetPresets()
                    self.selectedLibraryPreset = nil
                }
                .zIndex(4)
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch selectedTab {
        case .home:
            HomeScreen()
        case .gallery:
            GalleryScreen { item in
                selectedGalleryItem = item
            }
        case .widgets:
            WIPScreen()
        case .settings:
            SettingsScreen()
        case .library:
            EmptyView()
        }
    }

    // MARK: - Bottom Bar

    private var bottomBarSelection: Binding<BottomBarTab> {
        Binding {
            selectedTab
        } set: { newValue in
            if newValue == .library {
                withAnimation(Self.libraryTransitionAnimation) {
                    showsLibrary = true
                }
            } else {
                withAnimation(.smooth(duration: 0.22)) {
                    selectedTab = newValue
                }
            }
        }
    }

    private var bottomBarEffect: some View {
        LinearGradient(
            stops: [
                .init(color: AppColors.appBackground.opacity(0), location: 0),
                .init(color: AppColors.appBackground.opacity(0.42), location: 0.44),
                .init(color: AppColors.appBackground.opacity(0.88), location: 1),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 116)
        .allowsHitTesting(false)
    }

    // MARK: - Widget Data Refresh

    private func refreshBaselineWidgetData(reloadsTimelines: Bool = false) async {
        let storageTask = Task.detached(priority: .utility) {
            StorageProvider.currentSnapshot()
        }

        SharedModelContainer.write(clock: ClockDataProvider.currentSnapshot())
        SharedModelContainer.write(battery: BatteryStatusProvider.currentSnapshot())
        SharedModelContainer.write(appFontThemeID: appFontThemeID)
        SharedModelContainer.write(storage: await storageTask.value)

        if reloadsTimelines {
            WidgetTimelineReloadScheduler.schedule()
        }
    }

    private func refreshSavedWidgetData() async {
        let categories = savedWidgetCategories()

        await refreshBaselineWidgetData()

        if categories.contains(.eventKit) {
            let calendar = await EventKitProvider.currentSnapshot()
            let reminders = await ReminderProvider.currentSnapshot()
            SharedModelContainer.write(calendar: calendar)
            SharedModelContainer.write(reminders: reminders)
        }

        if categories.contains(.weatherKit) || categories.contains(.portal) {
            async let today = WeatherProvider.shared.todaySnapshot()
            async let portal = WeatherProvider.shared.portalSnapshot()
            async let weather = WeatherProvider.shared.weatherSnapshot()
            async let daylight = WeatherProvider.shared.daylightSnapshot()

            let (
                todaySnapshot,
                portalSnapshot,
                weatherSnapshot,
                daylightSnapshot
            ) = await (
                today,
                portal,
                weather,
                daylight
            )

            SharedModelContainer.write(today: todaySnapshot)
            SharedModelContainer.write(portal: portalSnapshot)
            SharedModelContainer.write(weather: weatherSnapshot)
            SharedModelContainer.write(daylight: daylightSnapshot)
        }

        if categories.contains(.healthKit) {
            async let heartRate = HealthSummaryProvider.shared.latestHeartRate()
            async let health = HealthSummaryProvider.shared.todaySnapshot()
            async let activity = HealthSummaryProvider.shared.activitySnapshots()
            async let sleep = HealthSummaryProvider.shared.sleepSnapshot()

            let (
                heartRateSnapshot,
                healthSnapshot,
                activitySnapshots,
                sleepSnapshot
            ) = await (
                heartRate,
                health,
                activity,
                sleep
            )

            SharedModelContainer.write(heartRate: heartRateSnapshot)
            SharedModelContainer.write(health: healthSnapshot)
            SharedModelContainer.write(activity: activitySnapshots)
            SharedModelContainer.write(sleep: sleepSnapshot)
        }

        WidgetTimelineReloadScheduler.reloadNow()
    }

    private func runRefreshLoops() async {
        async let clockLoop: Void = runClockRefreshLoop()
        async let slowLoop: Void = runSlowDataRefreshLoop()
        _ = await (clockLoop, slowLoop)
    }

    private func runClockRefreshLoop() async {
        while !Task.isCancelled, !SharedModelContainer.readWidgetPresets().isEmpty {
            SharedModelContainer.write(clock: ClockDataProvider.currentSnapshot())
            do {
                try await Task.sleep(for: Self.clockRefreshInterval)
            } catch {
                return
            }
        }
    }

    private func runSlowDataRefreshLoop() async {
        while !Task.isCancelled, !SharedModelContainer.readWidgetPresets().isEmpty {
            await refreshSavedWidgetData()
            do {
                try await Task.sleep(for: Self.slowDataRefreshInterval)
            } catch {
                return
            }
        }
    }


    private func refreshHealthWidgetData() async {
        let health = await HealthSummaryProvider.shared.todaySnapshot()
        let activity = await HealthSummaryProvider.shared.activitySnapshots()
        let sleep = await HealthSummaryProvider.shared.sleepSnapshot()
        SharedModelContainer.write(health: health)
        SharedModelContainer.write(activity: activity)
        SharedModelContainer.write(sleep: sleep)
    }

    private func savedWidgetCategories() -> Set<WidgetCategory> {
        let catalog = WidgetCatalog.items
        let needed = widgetPresets
            .compactMap { preset in catalog.first { $0.id == preset.widgetID }?.categories }
            .flatMap { $0 }
        return Set(needed)
    }

    private func reloadWidgetPresets() {
        widgetPresets = SharedModelContainer.readWidgetPresets()
    }

}

#Preview("ContentView") {
    ContentView(
        runsLiveWidgetTasks: false,
        initialTab: .home,
        previewHasCompletedOnboarding: true
    )
    .environment(LocalizationManager.shared)
    .environment(\.locale, LocalizationManager.shared.locale)
}
