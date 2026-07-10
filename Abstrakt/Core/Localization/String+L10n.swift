//
//  String+L10n.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 07/07/26.
//

//  Shorthand localization helpers.
//
//  Usage:
//      Text(L("settings.section.general"))
//      let s = L("preference.temperature.celsius")
//      let s = L("settings.footer.made_by", "1.23.0", "01")
//

import Foundation
import SwiftUI

func L(_ key: String, _ args: CVarArg...) -> String {
    let format = LocalizationManager.shared.bundle.localizedString(
        forKey: key,
        value: nil,
        table: nil
    )
    if args.isEmpty { return format }
    return String(format: format, locale: LocalizationManager.shared.locale, arguments: args)
}
