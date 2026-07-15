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
- A widget may support only appearance mode and size.
- Another widget may support font family, font weight, icon set, and gradient styles.
- Health widgets may additionally support a goal, counter, metric, or progress style.
- Gallery categories should support framework-backed discovery such as `HealthKit`, `WeatherKit`, `EventKit`, `Foundation`, `UIKit`, and `Portal`.
- Gallery category chips should be generated from catalog categories that have at least one widget, and filtering should use the same catalog metadata that drives widget cards.
- The preview sheet should show the rendered widget and its display title before any future form controls.
- The save action stays pinned in its own bottom layer, separate from both the rendered widget and future form content.
- App-wide settings such as temperature unit, temperature display, and distance unit should live in Settings rather than inside every widget customization sheet unless a widget explicitly supports an override.
- App language, app font, and alternate app icon choices should also live in Settings. Language and font changes can affect widget-visible text or typography through shared storage; alternate icons are host-app-only personalization.
- Saving should be blocked when a widget's required permission is unavailable, with HealthKit treated specially because iOS does not expose read-authorization status after the prompt.

## Library Rules

- The Library page should group presets by size tab.
- The count shown in each tab should reflect saved presets in that size.
- A library card should show a realistic preview and enough metadata to distinguish one preset from another.
- The app library should represent saved presets, not the system-installed widget instances themselves.
- Saved presets should be written to the App Group so the WidgetKit extension and AppEntity picker can read them.
- Saved widget thumbnails should be written beside shared preset data when available, so the system picker can display visual choices.
- Size tabs should support both direct chip taps and horizontal swiping.
- Empty states should communicate when a size has no saved presets.
- Library row previews should preserve widget aspect ratio, scale down to fit the row, and may crop the bottom under the divider to keep the list dense and preview-like.

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
- Expanded and Lock Screen Live Activity items stay selected until the selected item is tapped again.
- The Lock Screen Live Activity visual menu defaults to `Glass`; `Solid` is the fallback for users who prefer a black surface.
- In the phone-frame preview, an unselected expanded or lockscreen state shows only the black/add island surface. The richer "Add Activity" copy is reserved for the actual phone ActivityKit surface when Dynamic Island is on.
