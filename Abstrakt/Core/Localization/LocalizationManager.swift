//
//  LocalizationManager.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 07/07/26.
//

import Foundation
import Observation

@Observable
final class LocalizationManager {
    static let shared = LocalizationManager()

    private(set) var currentLanguage: AppLanguage

    private init() {
        let stored = AppGroupConstants.sharedDefaults?.string(
            forKey: AppSettingsPreference.appLanguageKey
        )
        currentLanguage = AppLanguage.from(id: stored ?? AppLanguage.system.id)
    }

    func setLanguage(_ language: AppLanguage) {
        guard language != currentLanguage else { return }
        currentLanguage = language
        AppGroupConstants.sharedDefaults?.set(
            language.id,
            forKey: AppSettingsPreference.appLanguageKey
        )
    }

    var bundle: Bundle {
        Bundle.localized(for: currentLanguage.localeCode)
    }

    var locale: Locale {
        if let code = currentLanguage.localeCode {
            return Locale(identifier: code)
        }
        return .current
    }
}
