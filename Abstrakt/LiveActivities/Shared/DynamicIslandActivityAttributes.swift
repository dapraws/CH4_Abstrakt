//
//  DynamicIslandActivityAttributes.swift
//  Abstrakt
//

import ActivityKit
import Foundation

enum LiveActivityBackgroundStyle: String, Codable, Hashable, CaseIterable {
    case glass
    case solid

    var title: String {
        switch self {
        case .glass:
            "Glass"
        case .solid:
            "Solid"
        }
    }
}

// MARK: - Attributes

struct DynamicIslandActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var leadingWidget: LiveActivityWidget?
        var trailingWidget: LiveActivityWidget?
        var expandedWidget: LiveActivityWidget?
        var lockScreenWidget: LiveActivityWidget?
        var lockScreenBackgroundStyle: LiveActivityBackgroundStyle

        enum CodingKeys: String, CodingKey {
            case leadingWidget
            case trailingWidget
            case expandedWidget
            case lockScreenWidget
            case lockScreenBackgroundStyle
        }

        init(
            leadingWidget: LiveActivityWidget? = nil,
            trailingWidget: LiveActivityWidget? = nil,
            expandedWidget: LiveActivityWidget? = nil,
            lockScreenWidget: LiveActivityWidget? = nil,
            lockScreenBackgroundStyle: LiveActivityBackgroundStyle = .glass
        ) {
            self.leadingWidget = leadingWidget
            self.trailingWidget = trailingWidget
            self.expandedWidget = expandedWidget
            self.lockScreenWidget = lockScreenWidget
            self.lockScreenBackgroundStyle = lockScreenBackgroundStyle
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            leadingWidget = try container.decodeIfPresent(LiveActivityWidget.self, forKey: .leadingWidget)
            trailingWidget = try container.decodeIfPresent(LiveActivityWidget.self, forKey: .trailingWidget)
            expandedWidget = try container.decodeIfPresent(LiveActivityWidget.self, forKey: .expandedWidget)
            lockScreenWidget = try container.decodeIfPresent(LiveActivityWidget.self, forKey: .lockScreenWidget)
            lockScreenBackgroundStyle = try container.decodeIfPresent(
                LiveActivityBackgroundStyle.self,
                forKey: .lockScreenBackgroundStyle
            ) ?? .glass
        }
    }

    var activityID: String
    var displayName: String

    enum CodingKeys: String, CodingKey {
        case activityID
        case displayName
    }

    init(
        activityID: String = UUID().uuidString,
        displayName: String = "Dynamic Island"
    ) {
        self.activityID = activityID
        self.displayName = displayName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activityID = try container.decodeIfPresent(String.self, forKey: .activityID) ?? UUID().uuidString
        displayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? "Dynamic Island"
    }
}
