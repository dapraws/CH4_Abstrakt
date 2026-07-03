//
//  AbstraktApp.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 22/06/26.
//

import SwiftUI
import WidgetKit

@main
struct AbstraktApp: App {
    init() {
        AppGroupConstants.migrateLegacyFallbackDefaultsIfNeeded()
        AppFonts.registerCustomFonts()
        WidgetCenter.shared.reloadAllTimelines()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
