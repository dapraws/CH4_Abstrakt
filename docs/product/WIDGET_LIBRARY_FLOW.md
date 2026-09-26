# Widget Library Flow

This document captures the intended user flow for widget selection, customization, and saving.

## Primary Flow

1. The user opens the gallery and browses available widgets.
2. The user can filter by category chips based on the primary framework or feature surface.
3. The user taps a widget card.
4. A full-width preview/customization sheet opens with a live preview of the chosen widget.
5. The widget's catalog size determines whether it saves as `Small`, `Medium`, or `Large`.
6. The user adjusts any supported options for that widget.
7. Some options stay inline in the first sheet.
8. Some options open a secondary sheet, such as Portal app selection.
9. The user saves or removes the configured widget preset.
10. Saved presets appear in the Library page under their widget size tab.

## Customization Rules

- Not all widgets need the same fields.
- Appearance mode (`System`, `Light`, `Dark`) is universally available across all configurable widgets.
- Specific widgets support bespoke configuration options:
  - **Portal**: 6-slot app launcher configuration via `AppsPickerSheet`, plus icon clip styles (`Default`, `Circle`, `Bloom`).
  - **Activity**: Time scope toggle (`Today` vs `Weekly`).
  - **Events**: Event prioritization mode (`Upcoming` vs `Current`).
- Gallery categories support framework-backed discovery: `HealthKit`, `WeatherKit`, `EventKit`, `Foundation`, `UIKit`, and `Portal`.
- Gallery category chips are generated from catalog categories that have at least one widget, and filtering uses the same catalog metadata that drives widget cards.
- The preview sheet displays the rendered widget and its display title before any form controls.
- The save action stays pinned in its own bottom layer, separate from both the rendered widget and form content.
- App-wide settings such as temperature unit (`Celsius` / `Fahrenheit`), temperature display (`Standard` / `Feels Like`), distance unit (`Kilometers` / `Miles`), typography theme (`Quicksand`, `SF Pro`, `SF Rounded`, `Fusion Pixel`), app language, and alternate app icons live in Settings.
- Saving is blocked when a widget's required framework permission is unavailable, with HealthKit treated specially via `.requested` state verification because iOS does not expose read-authorization status after prompting.

## Preset Persistence & Thumbnail Architecture

- **App Group JSON Store**: When saved, presets are serialized to App Group storage under `presets.json` and in `UserDefaults` (`savedWidgetPresets`).
- **Disk Thumbnails**: A rendered snapshot of the widget is captured and saved as `<presetID>.png` in the shared App Group container directory, allowing the iOS system widget picker to render visual preview cards for each preset.
- **Debounced Timeline Invalidation**: Saving or removing a preset schedules a debounced timeline reload (`WidgetTimelineReloadScheduler.schedule(after: .milliseconds(450))`) to notify WidgetKit without exhausting reload budgets.
- **Simulator Testing Bypass**: In Xcode iOS Simulator environments where AppIntent configuration sheets fail to deliver entity pickers, `SharedModelContainer.setSimulatorActivePreset(presetID)` and `WidgetSharedStore.simulatorActivePresetID` ensure the active preset automatically renders in simulator widgets.

## Library Rules

- The Library page groups presets by size tab (`Small`, `Medium`, `Large`).
- The count badge shown in each tab reflects saved presets in that size.
- A library card shows a realistic preview and enough metadata to distinguish one preset from another.
- The app library represents saved presets, not system-installed widget instances.
- Saved presets are written to the App Group so the WidgetKit extension and `SavedWidgetEntity` AppIntent query can read them.
- Size tabs support both direct chip taps and horizontal swiping gestures.
- Empty states communicate clearly when a size has no saved presets.
- Library row previews preserve widget aspect ratio, scale down to fit the row, and crop the bottom under the divider to keep the list dense and preview-like.

## System Widget Relationship

The Home Screen still uses the native iOS widget placement flow:

1. User adds `Solid Widget` from the system widget gallery.
2. User chooses one of the three WidgetKit slots: `Small Widget`, `Medium Widget`, or `Large Widget`.
3. User touches and holds the placed widget, taps `Edit Widget`, then opens the saved widget picker.
4. The picker shows only saved presets from Abstrakt that match that slot's size.
5. User selects a saved preset and taps `Done`.

Abstrakt therefore needs to manage saved preset identity and extension-readable configuration cleanly.

The WidgetKit extension should not expose one system widget per feature such as Battery, Steps, or Dashboard. Feature widgets are saved as library presets inside the app; WidgetKit exposes size-based Solid Widget renderers that consume those presets.

## Live Activity Relationship

Live Activities are configured outside the saved Home Screen widget library.

1. User opens the Live Activity tab/screen.
2. User chooses the ActivityKit state they want to configure: Smart Pills, expanded Dynamic Island, or Lock Screen Live Activity.
3. User selects an activity item backed by existing widget/provider data.
4. The Dynamic Island toggle starts or updates the single ActivityKit activity.
5. If a state has no selected item while the toggle is on, that state renders the explicit add/empty activity instead of borrowing another state's selected item.

Live Activity selections should not create Library presets, and saved Home Screen widgets should not automatically affect ActivityKit state.

Live Activity configuration rules:

- Changing mode between Smart Pills, Expanded, and Live Activity should animate with fade/blur movement and fire selection haptics.
- Selecting or clearing an item should update the preview immediately and update a running ActivityKit activity without requiring the user to toggle Dynamic Island off and on.
- Smart Pills selection can choose left or right placement; one side stays selected until the user changes sides or taps the selected item again to clear.
- Smart Pills active state in the phone-frame preview is a subtle contour overlay around the selected side of the island. It should not resize the island, draw a heavy pill background, or appear as a selected badge inside the actual ActivityKit region.
- Expanded and Lock Screen Live Activity items stay selected until the selected item is tapped again.
- The Lock Screen Live Activity visual menu defaults to `Glass`; `Solid` is the fallback for users who prefer a black surface.
- `Glass`/`Solid` and `Edit | Delete` controls should share the same subtle glass control styling and stay close to the selected island content.
- In the phone-frame preview, an unselected expanded or lockscreen state shows only the black/add island surface. The richer "Add Activity" copy is reserved for the actual phone ActivityKit surface when Dynamic Island is on.
- Preview sheets should scroll normally. Collapsed sheets expand on upward content intent before list scrolling; expanded sheets collapse only from a downward pull when the preview list is already at its top.
