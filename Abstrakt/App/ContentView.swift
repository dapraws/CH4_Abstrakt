//
//  ContentView.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 22/06/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var selectedTab: BottomBarTab = .gallery
    @State private var showsLibrary = false

    private var libraryCount: Int {
        WidgetCatalog.items.count
    }

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
    }

    private var appShell: some View {
        ZStack(alignment: .bottom) {
            currentScreen
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppColors.appBackground)
                .blur(radius: showsLibrary ? 18 : 0)
                .scaleEffect(showsLibrary ? 1.02 : 1)
                .animation(.smooth(duration: 0.24), value: showsLibrary)

            if !showsLibrary {
                bottomBarEffect
            }

            BottomBar(
                selectedTab: bottomBarSelection,
                libraryCount: libraryCount,
                isLibraryPresented: showsLibrary
            ) {
                withAnimation(.spring(duration: 0.48, bounce: 0.16)) {
                    showsLibrary = false
                }
            }
            .animation(.spring(duration: 0.48, bounce: 0.16), value: showsLibrary)
            .zIndex(3)

            if showsLibrary {
                LibraryScreen()
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                .zIndex(2)
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .task {
            SharedModelContainer.write(
                clock: ClockDataProvider.currentSnapshot(),
                calendar: EventKitProvider.placeholderSnapshot()
            )
            SharedModelContainer.write(battery: BatteryStatusProvider.currentSnapshot())
            SharedModelContainer.write(dashboard: .placeholder)

            await HealthSummaryProvider.shared.requestAuthorization()
            let health = await HealthSummaryProvider.shared.todaySnapshot()
            SharedModelContainer.write(health: health)
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch selectedTab {
        case .home:
            HomeScreen()
        case .gallery:
            GalleryScreen()
        case .widgets:
            WIPScreen()
        case .settings:
            SettingsScreen()
        case .library:
            EmptyView()
        }
    }

    private var bottomBarSelection: Binding<BottomBarTab> {
        Binding {
            selectedTab
        } set: { newValue in
            if newValue == .library {
                withAnimation(.spring(duration: 0.48, bounce: 0.16)) {
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
}

#Preview {
    ContentView()
}
