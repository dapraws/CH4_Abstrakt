//
//  LiveActivityViewModel.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 10/07/26.
//

import SwiftUI
import Observation

@Observable
final class LiveActivityViewModel {
    // MARK: - State
    var isExpanded: Bool = false
    var activeSelectionSlot: SelectionSlot = .none
    var selectedPreviewMode: LiveActivityPreviewMode = .compact
    
    var selectedLeadingWidget: CompactWidgetModel?
    var selectedTrailingWidget: CompactWidgetModel?
    var selectedExpandedWidget: CompactWidgetModel?
    var selectedLockScreenWidget: CompactWidgetModel?
    
    var compactWidgets: [CompactWidgetModel] = CompactWidgetModel.compactGalleryPresets
    var expandedWidgets: [CompactWidgetModel] = CompactWidgetModel.expandedGalleryPresets
    var lockScreenWidgets: [CompactWidgetModel] = CompactWidgetModel.lockScreenGalleryPresets
    
    var currentWidgets: [CompactWidgetModel] {
        switch selectedPreviewMode {
        case .compact:
            return compactWidgets
        case .expanded:
            return expandedWidgets
        case .lockScreen:
            return lockScreenWidgets
        }
    }
    
    // MARK: - Actions
    
    func toggleExpanded() {
        isExpanded.toggle()
    }
    
    func setExpanded(_ expanded: Bool) {
        isExpanded = expanded
    }
    
    func handleWidgetTap(_ item: CompactWidgetModel) {
        switch activeSelectionSlot {
        case .leading:
            selectedLeadingWidget = item
            activeSelectionSlot = .none
        case .trailing:
            selectedTrailingWidget = item
            activeSelectionSlot = .none
        case .expanded:
            selectedExpandedWidget = item
            activeSelectionSlot = .none
        case .lockScreen:
            selectedLockScreenWidget = item
            activeSelectionSlot = .none
        case .none:
            break
        }
    }
    
    func toggleLeadingSelection() {
        if selectedLeadingWidget != nil {
            selectedLeadingWidget = nil
        } else {
            activeSelectionSlot = activeSelectionSlot == .leading ? .none : .leading
        }
    }
    
    func toggleTrailingSelection() {
        if selectedTrailingWidget != nil {
            selectedTrailingWidget = nil
        } else {
            activeSelectionSlot = activeSelectionSlot == .trailing ? .none : .trailing
        }
    }
    
    func toggleExpandedSelection() {
        if selectedExpandedWidget != nil {
            selectedExpandedWidget = nil
        } else {
            activeSelectionSlot = activeSelectionSlot == .expanded ? .none : .expanded
        }
    }
    
    func toggleLockScreenSelection() {
        if selectedLockScreenWidget != nil {
            selectedLockScreenWidget = nil
        } else {
            activeSelectionSlot = activeSelectionSlot == .lockScreen ? .none : .lockScreen
        }
    }
    
    // MARK: - Data Loading
    
    @MainActor
    func loadData() async {
        // Fetch Storage
        let storage = StorageProvider.currentSnapshot()
        let percent = Double(storage.usedBytes) / Double(storage.totalBytes) * 100.0
        let percentStr = "\(Int(percent.rounded()))%"
        
        // Fetch Weather
        let weather = await WeatherProvider.shared.todaySnapshot()
        
        // Fetch Health (Steps, Calories)
        let healthAuth = HealthSummaryProvider.shared.authorizationState()
        var stepsStr: String? = nil
        
        if healthAuth == .requested {
            let healthSnapshot = await HealthSummaryProvider.shared.todaySnapshot()
            stepsStr = healthSnapshot.stepsLabel
        }
        
        // Current date formatting
        let now = Date.now
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        let dayStr = dayFormatter.string(from: now)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d"
        let dateStr = dateFormatter.string(from: now)
        
        let dateLeadingZeroFormatter = DateFormatter()
        dateLeadingZeroFormatter.dateFormat = "dd"
        let dateLeadingZeroStr = dateLeadingZeroFormatter.string(from: now)
        
        let monthFormatter = DateFormatter()
        monthFormatter.dateFormat = "MMM"
        let monthStr = monthFormatter.string(from: now)
        
        let updateList: (inout [CompactWidgetModel]) -> Void = { list in
            if let idx = list.firstIndex(where: { $0.name == "Storage" }) {
                list[idx].primaryText = percentStr
            }
            if let idx = list.firstIndex(where: { $0.name == "Temperature" && $0.layout == .temperatureHighLow }) {
                list[idx].primaryText = "\(weather.high)°"
                list[idx].secondaryText = "\(weather.low)°"
                list[idx].isSystemImage = false
            }
            if let idx = list.firstIndex(where: { $0.name == "Temperature" && $0.layout == .largeTextSplit }) {
                list[idx].primaryText = "\(weather.temperature)"
                list[idx].secondaryText = "\(weather.low)"
                list[idx].isSystemImage = false
            }
            if let idx = list.firstIndex(where: { $0.name == "Weather" }) {
                list[idx].isSystemImage = false
            }
            if let stepsStr = stepsStr {
                if let idx = list.firstIndex(where: { $0.name == "Steps" && $0.layout == .textTopTextBottom }) {
                    list[idx].primaryText = stepsStr
                }
                if let idx = list.firstIndex(where: { $0.name == "Steps" && $0.layout == .caloriesStyle }) {
                    list[idx].primaryText = stepsStr
                }
            }
            // Update calendar widgets
            if let idx = list.firstIndex(where: { $0.name == "Calendar" && $0.layout == .calendarSplit }) {
                list[idx].primaryText = dayStr
                list[idx].secondaryText = dateStr
            }
            if let idx = list.firstIndex(where: { $0.name == "Month" }) {
                list[idx].primaryText = monthStr
            }
            if let idx = list.firstIndex(where: { $0.name == "Day" }) {
                list[idx].primaryText = dayStr
            }
            if let idx = list.firstIndex(where: { $0.name == "Date" }) {
                list[idx].primaryText = dateLeadingZeroStr
            }
        }
        
        updateList(&compactWidgets)
        updateList(&expandedWidgets)
        updateList(&lockScreenWidgets)
    }
}

enum SelectionSlot {
    case none
    case leading
    case trailing
    case expanded
    case lockScreen
}

enum LiveActivityPreviewMode: Int, CaseIterable, Identifiable {
    case compact = 0
    case expanded = 1
    case lockScreen = 2
    
    var id: Int { rawValue }
    
    var title: String {
        switch self {
        case .compact: return "Small Pills"
        case .expanded: return "Expanded"
        case .lockScreen: return "Lock Screen"
        }
    }
    
    var assetName: String {
        switch self {
        case .compact: return "iphone-live-activity"
        case .expanded: return "iphone-live-activity-tapped"
        case .lockScreen: return "iphone-live-activity-tapped-below"
        }
    }
}

extension CompactWidgetModel {
    static var defaultGalleryPresets: [CompactWidgetModel] {
        return compactGalleryPresets
    }
    
    static var compactGalleryPresets: [CompactWidgetModel] {
        return [
            CompactWidgetModel(name: "Sun Event", iconName: "sun.max.fill", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: "18:00"),
            CompactWidgetModel(name: "Moon Event", iconName: "moon.fill", widgetColor: .purple, layout: .iconTopTextBottom, primaryText: "04:00"),
            CompactWidgetModel(name: "Temperature", iconName: "thermometer", widgetColor: .red, layout: .temperatureHighLow, primaryText: "32°", secondaryText: "18°"),
            CompactWidgetModel(name: "Weather", iconName: "cloud.sun.fill", widgetColor: .white, layout: .largeIcon),
            CompactWidgetModel(name: "Calories", iconName: "flame.fill", widgetColor: .red, layout: .caloriesStyle, primaryText: "173"),
            CompactWidgetModel(name: "Calendar", iconName: "calendar", widgetColor: .red, layout: .calendarSplit, primaryText: "Wed", secondaryText: "8"),
            CompactWidgetModel(name: "Steps", iconName: "figure.walk", widgetColor: .blue, layout: .textTopTextBottom, primaryText: "2.561"),
            CompactWidgetModel(name: "Temperature", iconName: "thermometer", widgetColor: .blue, layout: .largeTextSplit, primaryText: "32", secondaryText: "18"),
            CompactWidgetModel(name: "Steps", iconName: "shoeprints.fill", widgetColor: .blue, layout: .caloriesStyle, primaryText: "173"),
            CompactWidgetModel(name: "Stickers", iconName: "face.smiling.fill", widgetColor: .pink, layout: .largeIcon),
            CompactWidgetModel(name: "Storage", iconName: "externaldrive.fill", widgetColor: .cyan, layout: .storageStyle, primaryText: "54%"),
            CompactWidgetModel(name: "Sleep", iconName: "bed.double.fill", widgetColor: .indigo, layout: .circularProgress, primaryText: "4H", secondaryText: "18M", progress: 0.7),
            CompactWidgetModel(name: "Month", iconName: "calendar", widgetColor: .pink, layout: .largeTextSplit, primaryText: "Jul"),
            CompactWidgetModel(name: "Day", iconName: "calendar", widgetColor: .red, layout: .largeTextSplit, primaryText: "Wed"),
            CompactWidgetModel(name: "Date", iconName: "calendar", widgetColor: .white, layout: .largeTextSplit, primaryText: "08"),
            CompactWidgetModel(name: "Wind", iconName: "wind", widgetColor: .cyan, layout: .storageStyle, primaryText: "SE")
        ]
    }
    
    static var expandedGalleryPresets: [CompactWidgetModel] {
        return [
            CompactWidgetModel(name: "Media Playback", iconName: "play.fill", widgetColor: .blue, layout: .largeIcon),
            CompactWidgetModel(name: "Timer", iconName: "timer", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: "12:00"),
            CompactWidgetModel(name: "Fitness Tracker", iconName: "heart.fill", widgetColor: .red, layout: .caloriesStyle, primaryText: "72 bpm"),
            CompactWidgetModel(name: "Quick Alarm", iconName: "alarm.fill", widgetColor: .yellow, layout: .iconTopTextBottom, primaryText: "07:30"),
            CompactWidgetModel(name: "Weather Detail", iconName: "cloud.rain.fill", widgetColor: .cyan, layout: .largeTextSplit, primaryText: "Rainy"),
            CompactWidgetModel(name: "Battery Status", iconName: "battery.100", widgetColor: .green, layout: .storageStyle, primaryText: "88%")
        ]
    }
    
    static var lockScreenGalleryPresets: [CompactWidgetModel] {
        return [
            CompactWidgetModel(name: "Lock Battery", iconName: "battery.75", widgetColor: .white, layout: .storageStyle, primaryText: "75%"),
            CompactWidgetModel(name: "Lock Calendar", iconName: "calendar.badge.clock", widgetColor: .white, layout: .calendarSplit, primaryText: "Event", secondaryText: "12"),
            CompactWidgetModel(name: "Lock Alarm", iconName: "alarm", widgetColor: .white, layout: .iconTopTextBottom, primaryText: "08:00"),
            CompactWidgetModel(name: "Quick Launch", iconName: "bolt.fill", widgetColor: .white, layout: .largeIcon),
            CompactWidgetModel(name: "Lock Sleep", iconName: "bed.double", widgetColor: .white, layout: .circularProgress, primaryText: "7H", secondaryText: "30M", progress: 0.8)
        ]
    }
}

