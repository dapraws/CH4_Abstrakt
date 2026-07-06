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
    @State private var hasRequestedHealthAuth = false

    // MARK: - Properties

    private let runsLiveWidgetTasks: Bool

    init(runsLiveWidgetTasks: Bool = true) {
        self.runsLiveWidgetTasks = runsLiveWidgetTasks
    }

    private var libraryCount: Int {
        SharedModelContainer.readWidgetPresets().count
    }

    // MARK: - Body

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                appShell
            } else {
                OnboardingScreen {
                    hasCompletedOnboarding = true
                }
            }
        }
        .onChange(of: appFontThemeID) { _, newValue in
            SharedModelContainer.write(appFontThemeID: newValue)
            WidgetCenter.shared.reloadAllTimelines()
        }
        .task {
            guard runsLiveWidgetTasks else {
                return
            }

            HealthSummaryProvider.shared.startObservingTodayMetrics {
                Task { @MainActor in
                    await refreshHealthWidgetData()
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
        .task(id: scenePhase) {
            guard runsLiveWidgetTasks, scenePhase == .active else {
                return
            }

            if !hasRequestedHealthAuth {
                hasRequestedHealthAuth = true
                try? await Task.sleep(for: .milliseconds(800))
                await HealthSummaryProvider.shared.requestAuthorization()
            }

            await refreshWidgetData()
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
                LibraryScreen { preset in
                    selectedLibraryPreset = preset
                }
                    .transition(.opacity)
                    .zIndex(2)
            }

            if let selectedGalleryItem {
                WidgetPreviewSheetCover(item: selectedGalleryItem, actionStyle: .saveToLibrary) {
                    self.selectedGalleryItem = nil
                }
                .zIndex(4)
            }

            if let selectedLibraryPreset,
               let selectedLibraryItem = WidgetCatalog.item(withID: selectedLibraryPreset.widgetID) {
                WidgetPreviewSheetCover(
                    item: selectedLibraryItem,
                    actionStyle: .removeFromLibrary(selectedLibraryPreset)
                ) {
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

    private func refreshWidgetData() async {
        SharedModelContainer.write(
            clock: ClockDataProvider.currentSnapshot(),
            calendar: await EventKitProvider.currentSnapshot()
        )
        SharedModelContainer.write(battery: BatteryStatusProvider.currentSnapshot())
        SharedModelContainer.write(storage: StorageProvider.currentSnapshot())
        SharedModelContainer.write(appFontThemeID: appFontThemeID)

        let today = await WeatherProvider.shared.todaySnapshot()
        SharedModelContainer.write(today: today)
        let portal = await WeatherProvider.shared.portalSnapshot()
        SharedModelContainer.write(portal: portal)
        let weather = await WeatherProvider.shared.weatherSnapshot()
        SharedModelContainer.write(weather: weather)
        let daylight = await WeatherProvider.shared.daylightSnapshot()
        SharedModelContainer.write(daylight: daylight)
        let heartRate = await HealthSummaryProvider.shared.latestHeartRate()
        SharedModelContainer.write(heartRate: heartRate)

        await refreshHealthWidgetData()

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func runRefreshLoops() async {
        async let clockLoop: Void = runClockRefreshLoop()
        async let slowLoop: Void = runSlowDataRefreshLoop()
        _ = await (clockLoop, slowLoop)
    }

    private func runClockRefreshLoop() async {
        while !Task.isCancelled {
            SharedModelContainer.write(clock: ClockDataProvider.currentSnapshot())
            do {
                try await Task.sleep(for: Self.clockRefreshInterval)
            } catch {
                return
            }
        }
    }

    private func runSlowDataRefreshLoop() async {
        while !Task.isCancelled {
            SharedModelContainer.write(battery: BatteryStatusProvider.currentSnapshot())
            SharedModelContainer.write(storage: StorageProvider.currentSnapshot())
            WidgetCenter.shared.reloadAllTimelines()
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
        SharedModelContainer.write(health: health)
        SharedModelContainer.write(activity: activity)
    }

}

#Preview {
    ContentView(runsLiveWidgetTasks: false)
}
