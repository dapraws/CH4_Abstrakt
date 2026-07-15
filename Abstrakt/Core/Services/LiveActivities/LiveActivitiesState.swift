//
//  LiveActivitiesState.swift
//  Abstrakt
//
//  Created by Daffa Yuranizar Arrifi on 10/07/26.
//

import ActivityKit
import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class LiveActivitiesState {
    var isPickerExpanded = false
    var isLiveActivityEnabled = false
    var isUpdatingLiveActivity = false
    var liveActivityErrorMessage: String?
    var activeSelectionSlot: LiveActivitySelectionSlot = .leading
    var selectedMode: LiveActivityMode = .compact

    var selectedLeadingWidget: LiveActivityWidget?
    var selectedTrailingWidget: LiveActivityWidget?
    var selectedExpandedWidget: LiveActivityWidget?
    var selectedLockScreenWidget: LiveActivityWidget?
    var lockScreenBackgroundStyle: LiveActivityBackgroundStyle = .glass

    var compactWidgets = LiveActivityWidgetCatalog.placeholderCompactWidgets
    var expandedWidgets = LiveActivityWidgetCatalog.placeholderExpandedWidgets
    var lockScreenWidgets = LiveActivityWidgetCatalog.placeholderLockScreenWidgets

    private var hasAdoptedRunningActivitySelections = false

    private static var isRunningInXcodePreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    var currentWidgets: [LiveActivityWidget] {
        let surface = selectedMode.surface
        switch selectedMode {
        case .compact:
            return compactWidgets.filter { $0.isAvailable(on: surface) }
        case .expanded:
            return expandedWidgets.filter { $0.isAvailable(on: surface) }
        case .lockScreen:
            return lockScreenWidgets.filter { $0.isAvailable(on: surface) }
        }
    }

    var hasSelectionInCurrentMode: Bool {
        hasSelection(for: selectedMode)
    }

    func setPickerExpanded(_ isExpanded: Bool) {
        guard isPickerExpanded != isExpanded else { return }

        Haptics.selection.play()
        isPickerExpanded = isExpanded
    }

    func setSelectedMode(_ mode: LiveActivityMode) {
        guard selectedMode != mode else { return }

        Haptics.selection.play()
        selectedMode = mode
        activeSelectionSlot = defaultSelectionSlot(for: mode)
    }

    func setLockScreenBackgroundStyle(_ style: LiveActivityBackgroundStyle) {
        guard lockScreenBackgroundStyle != style else { return }

        Haptics.selection.play()
        lockScreenBackgroundStyle = style
        Task {
            await updateLiveActivityIfNeeded()
        }
    }

    func hasSelection(for mode: LiveActivityMode) -> Bool {
        switch mode {
        case .compact:
            selectedLeadingWidget != nil || selectedTrailingWidget != nil
        case .expanded:
            selectedExpandedWidget != nil
        case .lockScreen:
            selectedLockScreenWidget != nil
        }
    }

    func selectWidget(_ item: LiveActivityWidget) {
        let targetSlot = selectionSlotForCurrentPicker()

        guard targetSlot.belongs(to: selectedMode),
              item.isAvailable(on: selectedMode.surface) else {
            activeSelectionSlot = defaultSelectionSlot(for: selectedMode)
            return
        }

        if selectedWidget(for: targetSlot)?.id == item.id {
            clearSelection(for: targetSlot, keepsSlotActive: true)
            return
        }

        Haptics.selection.play()
        switch targetSlot {
        case .leading:
            selectedLeadingWidget = item
        case .trailing:
            selectedTrailingWidget = item
        case .expanded:
            selectedExpandedWidget = item
        case .lockScreen:
            selectedLockScreenWidget = item
        case .none:
            return
        }

        activeSelectionSlot = targetSlot
        Task {
            await updateLiveActivityIfNeeded()
        }
    }

    func toggleSelection(for slot: LiveActivitySelectionSlot) {
        guard slot.belongs(to: selectedMode) else { return }

        let targetSlot = slot == .none ? defaultSelectionSlot(for: selectedMode) : slot
        guard activeSelectionSlot != targetSlot else { return }

        Haptics.selection.play()
        activeSelectionSlot = targetSlot
    }

    func beginEditingCurrentSelection() {
        beginEditingSelection(for: selectedMode)
    }

    func beginEditingSelection(for mode: LiveActivityMode) {
        switch mode {
        case .compact:
            if selectedLeadingWidget != nil {
                activeSelectionSlot = .leading
            } else if selectedTrailingWidget != nil {
                activeSelectionSlot = .trailing
            }
        case .expanded:
            if selectedExpandedWidget != nil {
                activeSelectionSlot = .expanded
            }
        case .lockScreen:
            if selectedLockScreenWidget != nil {
                activeSelectionSlot = .lockScreen
            }
        }
    }

    func clearCurrentSelection() {
        clearSelection(for: selectedMode)
    }

    func clearSelection(for mode: LiveActivityMode) {
        guard hasSelection(for: mode) else { return }

        Haptics.selection.play()
        switch mode {
        case .compact:
            selectedLeadingWidget = nil
            selectedTrailingWidget = nil
        case .expanded:
            selectedExpandedWidget = nil
        case .lockScreen:
            selectedLockScreenWidget = nil
        }

        activeSelectionSlot = defaultSelectionSlot(for: mode)
        Task {
            await updateLiveActivityIfNeeded()
        }
    }

    func refreshWidgetData() async {
        guard !Self.isRunningInXcodePreview else {
            isLiveActivityEnabled = false
            liveActivityErrorMessage = nil
            return
        }

        let snapshot = await LiveActivityWidgetDataProvider.currentSnapshot()
        compactWidgets = snapshot.compactWidgets
        expandedWidgets = snapshot.expandedWidgets
        lockScreenWidgets = snapshot.lockScreenWidgets
        selectedLeadingWidget = refreshedSelection(selectedLeadingWidget, in: compactWidgets, surface: .smartPills)
        selectedTrailingWidget = refreshedSelection(selectedTrailingWidget, in: compactWidgets, surface: .smartPills)
        selectedExpandedWidget = refreshedSelection(selectedExpandedWidget, in: expandedWidgets, surface: .expanded)
        selectedLockScreenWidget = refreshedSelection(selectedLockScreenWidget, in: lockScreenWidgets, surface: .liveActivity)
        refreshLiveActivityStatus()
        adoptRunningActivitySelectionsIfNeeded()
        await updateLiveActivityIfNeeded()
    }

    func refreshLiveActivityStatus() {
        guard !Self.isRunningInXcodePreview else {
            isLiveActivityEnabled = false
            return
        }

        isLiveActivityEnabled = !Activity<DynamicIslandActivityAttributes>.activities.isEmpty
    }

    func setLiveActivityEnabled(_ isEnabled: Bool) async {
        guard isUpdatingLiveActivity == false else { return }

        guard !Self.isRunningInXcodePreview else {
            if isLiveActivityEnabled != isEnabled {
                Haptics.selection.play()
            }
            isLiveActivityEnabled = isEnabled
            liveActivityErrorMessage = nil
            return
        }

        if isLiveActivityEnabled != isEnabled {
            Haptics.selection.play()
        }
        isUpdatingLiveActivity = true
        liveActivityErrorMessage = nil

        defer {
            isUpdatingLiveActivity = false
            refreshLiveActivityStatus()
        }

        if isEnabled {
            await startLiveActivity()
        } else {
            await endLiveActivities()
        }
    }

    private func startLiveActivity() async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            liveActivityErrorMessage = "Live Activities are off in Settings."
            return
        }

        await endLiveActivities()

        let attributes = DynamicIslandActivityAttributes()

        do {
            let content = ActivityContent(
                state: currentActivityContentState(),
                staleDate: nil
            )
            _ = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            hasAdoptedRunningActivitySelections = true
        } catch {
            liveActivityErrorMessage = error.localizedDescription
        }
    }

    private func endLiveActivities() async {
        for activity in Activity<DynamicIslandActivityAttributes>.activities {
            await activity.end(nil, dismissalPolicy: .immediate)
        }
    }

    private func selectedWidget(
        for slot: LiveActivitySelectionSlot
    ) -> LiveActivityWidget? {
        switch slot {
        case .none:
            nil
        case .leading:
            selectedLeadingWidget
        case .trailing:
            selectedTrailingWidget
        case .expanded:
            selectedExpandedWidget
        case .lockScreen:
            selectedLockScreenWidget
        }
    }

    private func selectionSlotForCurrentPicker() -> LiveActivitySelectionSlot {
        switch (activeSelectionSlot, selectedMode) {
        case (.none, .compact):
            .leading
        case (.none, .expanded):
            .expanded
        case (.none, .lockScreen):
            .lockScreen
        default:
            activeSelectionSlot
        }
    }

    private func clearSelection(
        for slot: LiveActivitySelectionSlot,
        keepsSlotActive: Bool = false
    ) {
        guard selectedWidget(for: slot) != nil else { return }

        Haptics.selection.play()
        switch slot {
        case .none:
            break
        case .leading:
            selectedLeadingWidget = nil
        case .trailing:
            selectedTrailingWidget = nil
        case .expanded:
            selectedExpandedWidget = nil
        case .lockScreen:
            selectedLockScreenWidget = nil
        }

        activeSelectionSlot = keepsSlotActive
            ? slot
            : defaultSelectionSlot(for: selectedMode)
        Task {
            await updateLiveActivityIfNeeded()
        }
    }

    private func defaultSelectionSlot(for mode: LiveActivityMode) -> LiveActivitySelectionSlot {
        switch mode {
        case .compact:
            .leading
        case .expanded:
            .expanded
        case .lockScreen:
            .lockScreen
        }
    }

    private func refreshedSelection(
        _ selectedWidget: LiveActivityWidget?,
        in widgets: [LiveActivityWidget],
        surface: LiveActivitySurface
    ) -> LiveActivityWidget? {
        guard let selectedWidget else { return nil }
        let refreshedWidget = widgets.first { $0.id == selectedWidget.id } ?? selectedWidget
        return refreshedWidget.isAvailable(on: surface) ? refreshedWidget : nil
    }

    private func adoptRunningActivitySelectionsIfNeeded() {
        guard !Self.isRunningInXcodePreview else { return }

        guard !hasAdoptedRunningActivitySelections,
              let activity = Activity<DynamicIslandActivityAttributes>.activities.first
        else {
            return
        }

        hasAdoptedRunningActivitySelections = true

        let state = activity.content.state
        selectedLeadingWidget = selectedLeadingWidget
            ?? refreshedSelection(state.leadingWidget, in: compactWidgets, surface: .smartPills)
        selectedTrailingWidget = selectedTrailingWidget
            ?? refreshedSelection(state.trailingWidget, in: compactWidgets, surface: .smartPills)
        selectedExpandedWidget = selectedExpandedWidget
            ?? refreshedSelection(state.expandedWidget, in: expandedWidgets, surface: .expanded)
        selectedLockScreenWidget = selectedLockScreenWidget
            ?? refreshedSelection(state.lockScreenWidget, in: lockScreenWidgets, surface: .liveActivity)
        lockScreenBackgroundStyle = state.lockScreenBackgroundStyle
    }

    private func updateLiveActivityIfNeeded() async {
        guard !Self.isRunningInXcodePreview else { return }
        guard !isUpdatingLiveActivity else { return }

        let activities = Activity<DynamicIslandActivityAttributes>.activities
        guard !activities.isEmpty else {
            refreshLiveActivityStatus()
            return
        }

        let content = ActivityContent(
            state: currentActivityContentState(),
            staleDate: nil
        )

        for activity in activities {
            await activity.update(content)
        }

        refreshLiveActivityStatus()
    }

    private func currentActivityContentState() -> DynamicIslandActivityAttributes.ContentState {
        DynamicIslandActivityAttributes.ContentState(
            leadingWidget: selectedLeadingWidget,
            trailingWidget: selectedTrailingWidget,
            expandedWidget: selectedExpandedWidget,
            lockScreenWidget: selectedLockScreenWidget,
            lockScreenBackgroundStyle: lockScreenBackgroundStyle
        )
    }
}

enum LiveActivitySelectionSlot {
    case none
    case leading
    case trailing
    case expanded
    case lockScreen

    func belongs(to mode: LiveActivityMode) -> Bool {
        switch (self, mode) {
        case (.leading, .compact), (.trailing, .compact):
            true
        case (.expanded, .expanded):
            true
        case (.lockScreen, .lockScreen):
            true
        case (.none, _):
            true
        default:
            false
        }
    }
}

enum LiveActivityMode: Int, CaseIterable, Identifiable {
    case compact
    case expanded
    case lockScreen

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .compact:
            "Smart Pills"
        case .expanded:
            "Expanded"
        case .lockScreen:
            "Live Activity"
        }
    }

    var previewSheetTitle: String {
        switch self {
        case .compact:
            "Smart Pills"
        case .expanded:
            "Expanded Mode"
        case .lockScreen:
            "Live Activity"
        }
    }

    var assetName: String {
        switch self {
        case .compact:
            "top"
        case .expanded:
            "top"
        case .lockScreen:
            "bottom"
        }
    }

    var iconAssetName: String {
        switch self {
        case .compact:
            "compact"
        case .expanded:
            "expanded"
        case .lockScreen:
            "live-activity"
        }
    }

    var surface: LiveActivitySurface {
        switch self {
        case .compact:
            .smartPills
        case .expanded:
            .expanded
        case .lockScreen:
            .liveActivity
        }
    }
}
