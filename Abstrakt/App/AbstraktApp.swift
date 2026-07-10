//
//  AbstraktApp.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 22/06/26.
//

import EventKit
import SwiftUI

@main
struct AbstraktApp: App {
    @State private var localization = LocalizationManager.shared

    init() {
        prewarmSharedResources()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(localization)
                .environment(\.locale, localization.locale)
        }
    }
}

private extension AbstraktApp {
    func prewarmSharedResources() {
        _ = AppGroupConstants.sharedDefaults

        AppFonts.registerCustomFonts()
        AbstraktWidgetFonts.registerCustomFonts()

        _ = HealthSummaryProvider.shared

        Task.detached(priority: .utility) {
            _ = EKEventStore()
        }
    }
}
