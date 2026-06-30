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

    private static let activeWidgetRefreshInterval: Duration = .seconds(1)
    private static let libraryTransitionAnimation = Animation.smooth(duration: 0.2)

    // MARK: - Environment

    @Environment(\.scenePhase) private var scenePhase

    // MARK: - State

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @State private var selectedTab: BottomBarTab = .gallery
    @State private var showsLibrary = false
    @State private var selectedGalleryItem: WidgetCatalogItem?

    // MARK: - Properties

    private let runsLiveWidgetTasks: Bool

    init(runsLiveWidgetTasks: Bool = true) {
        self.runsLiveWidgetTasks = runsLiveWidgetTasks
    }

    private var libraryCount: Int {
        WidgetPreset.seededLibrary.count
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
            
            await refreshWidgetData()
            HealthSummaryProvider.shared.startObservingTodayMetrics {
                Task { @MainActor in
                    await refreshFastChangingWidgetData()
                }
            }
        }
        .task(id: scenePhase) {
            guard runsLiveWidgetTasks, scenePhase == .active else {
                return
            }
            
            await runActiveWidgetRefreshLoop()
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
                LibraryScreen()
                    .transition(.opacity)
                    .zIndex(2)
            }

            if let selectedGalleryItem {
                WidgetPreviewSheetCover(item: selectedGalleryItem) {
                    self.selectedGalleryItem = nil
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
            calendar: EventKitProvider.placeholderSnapshot()
        )
        SharedModelContainer.write(battery: BatteryStatusProvider.currentSnapshot())
        SharedModelContainer.write(appFontThemeID: appFontThemeID)
        SharedModelContainer.write(widgetPresets: WidgetPreset.seededLibrary)
        
        await refreshHealthWidgetData()
        
        let dashboard = await WeatherDashboardProvider.shared.dashboardSnapshot()
        SharedModelContainer.write(dashboard: dashboard)
        let portal = await WeatherDashboardProvider.shared.denpasarPortalSnapshot()
        SharedModelContainer.write(portal: portal)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func runActiveWidgetRefreshLoop() async {
        while !Task.isCancelled {
            await refreshFastChangingWidgetData()

            do {
                try await Task.sleep(for: Self.activeWidgetRefreshInterval)
            } catch {
                return
            }
        }
    }
    
    private func refreshFastChangingWidgetData() async {
        SharedModelContainer.write(battery: BatteryStatusProvider.currentSnapshot())
        await refreshHealthWidgetData()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func refreshHealthWidgetData() async {
        await HealthSummaryProvider.shared.requestAuthorization()
        let health = await HealthSummaryProvider.shared.todaySnapshot()
        SharedModelContainer.write(health: health)
    }
}

#Preview {
    ContentView(runsLiveWidgetTasks: false)
}
