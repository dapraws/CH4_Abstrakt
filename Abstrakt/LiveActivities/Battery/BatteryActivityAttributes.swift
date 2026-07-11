//
//  BatteryActivityAttributes.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 08/07/26.
//

import ActivityKit

struct BatteryActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        let level: Int
        let isCharging: Bool
        let estimatedMinutesRemaining: Int?
    }

    var id: String = "battery-charging"
}
