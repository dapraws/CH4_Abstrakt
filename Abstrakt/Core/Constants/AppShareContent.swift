//
//  AppShareContent.swift
//  Abstrakt
//
//  Created by Muhammad Darrel Prawira on 06/07/26.
//

import Foundation
import UIKit

/// Single source of truth for outbound links and share copy.
///
/// All URLs are placeholders until the public landing page and App Store
/// listing exist. Swap the values here and every surface updates.
enum AppShareContent {
    // MARK: - Links

    /// Public marketing page. Preferred share destination: it can detect the
    /// visitor's device and route to TestFlight or the App Store, and it looks
    /// far better than a raw TestFlight invite link when pasted into a chat.
    static let landingURL = URL(string: "https://abstrakt.app")!

    /// App Store listing. Used by "Rate Us" as a fallback when the in-app
    /// review prompt is unavailable (e.g. TestFlight builds).
    /// Placeholder ID — replace `id0000000000` once the listing is live.
    static let appStoreURL = URL(string: "https://apps.apple.com/app/id0000000000")!

    /// Deep link that opens the App Store review composer directly.
    static let appStoreReviewURL = URL(string: "https://apps.apple.com/app/id0000000000?action=write-review")!

    // MARK: - Feedback

    static let feedbackEmail = "darrelprawira26@gmail.com"

    // MARK: - Broadcast Copy

    /// Rotating share taglines. One is picked at random per share so the
    /// message feels fresh instead of canned.
    static var broadcastLines: [String] {
        [
            L("broadcast.line.1"),
            L("broadcast.line.2"),
            L("broadcast.line.3"),
            L("broadcast.line.4"),
            L("broadcast.line.5"),
        ]
    }

    static func randomBroadcastLine() -> String {
        broadcastLines.randomElement() ?? broadcastLines[0]
    }

    /// Full message body for the OS share sheet: a broadcast line plus the link.
    static func shareMessage(line: String) -> String {
        "\(line)\n\(landingURL.absoluteString)"
    }

    // MARK: - Feedback Mailto

    /// Builds a `mailto:` URL with a prefilled subject and a body stub that
    /// includes app version and device info to make triage easier.
    static func feedbackMailtoURL(
        appVersion: String = Bundle.main.appVersionDisplay,
        deviceModel: String = UIDevice.current.model,
        systemVersion: String = UIDevice.current.systemVersion
    ) -> URL? {
        let subject = "Abstrakt Feedback"
        let body = """


        —
        App: Abstrakt \(appVersion)
        Device: \(deviceModel), iOS \(systemVersion)
        """

        var components = URLComponents()
        components.scheme = "mailto"
        components.path = feedbackEmail
        components.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]

        return components.url
    }
}

extension Bundle {
    /// "1.0 (1)" style version string for display and feedback.
    var appVersionDisplay: String {
        let short = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        return "\(short) (\(build))"
    }
}
