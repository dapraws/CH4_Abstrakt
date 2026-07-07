//
//  Bundle+Localized.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 07/07/26.
//

import Foundation

extension Bundle {
    /// Returns the localized bundle for the given language code.
    /// - Parameter languageCode: BCP-47 code such as "en" or "id". Pass `nil` to follow the system.
    /// - Returns: The matching `.lproj` bundle, or `Bundle.main` as fallback.
    static func localized(for languageCode: String?) -> Bundle {
        guard let code = languageCode,
              let path = Bundle.main.path(forResource: code, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return .main
        }
        return bundle
    }
}
