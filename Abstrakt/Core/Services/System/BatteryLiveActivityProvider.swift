//
//  BatteryLiveActivityProvider.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 08/07/26.
//

import ActivityKit

@MainActor
final class BatteryLiveActivityProvider {
    static let shared = BatteryLiveActivityProvider()

    private var activity: Activity<BatteryActivityAttributes>?

    private init() {
        self.activity = Activity<BatteryActivityAttributes>.activities.first
    }

    var isActive: Bool {
        activity != nil
    }

    func startIfNeeded(with snapshot: BatterySnapshot) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }

        guard snapshot.isCharging else {
            return
        }

        guard activity == nil else {
            return
        }

        let state = BatteryActivityAttributes.ContentState(
            level: snapshot.level,
            isCharging: snapshot.isCharging,
            estimatedMinutesRemaining: snapshot.estimatedMinutesRemaining
        )

        do {
            activity = try Activity.request(
                attributes: BatteryActivityAttributes(),
                content: .init(state: state, staleDate: nil),
                pushType: nil
            )
        } catch {
            print("Failed to request battery live activity: \(error)")
        }
    }

    func update(with snapshot: BatterySnapshot) {
        guard let activity else {
            return
        }

        let state = BatteryActivityAttributes.ContentState(
            level: snapshot.level,
            isCharging: snapshot.isCharging,
            estimatedMinutesRemaining: snapshot.estimatedMinutesRemaining
        )

        Task {
            await activity.update(.init(state: state, staleDate: nil))
        }

        if !snapshot.isCharging {
            end()
        }
    }

    func end() {
        guard let activity else {
            return
        }

        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            self.activity = nil
        }
    }
}
