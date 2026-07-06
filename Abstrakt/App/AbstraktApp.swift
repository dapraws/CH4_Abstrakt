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
    init() {
        prewarmSharedResources()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private extension AbstraktApp {
    func prewarmSharedResources() {
        _ = AppGroupConstants.sharedDefaults

        AppFonts.registerCustomFonts()
        AbstraktWidgetFonts.registerCustomFonts()

        Task.detached(priority: .utility) {
            _ = HealthSummaryProvider.shared
            _ = EKEventStore()
        }
    }
}
