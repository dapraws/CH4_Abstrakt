# Feature Framework Matrix

This file is the canonical mapping between Abstrakt feature surfaces and Apple-native frameworks.

## Principles

- Each widget family should have one primary framework owner.
- Secondary frameworks may support permissions, formatting, caching, or rendering.
- Widgets must degrade gracefully when permissions are missing or data is stale.
- Configuration capabilities belong to the app experience even when the data itself comes from system frameworks.
- ActivityKit surfaces should reuse the same provider-backed feature data as widgets whenever possible.

## Widget Family Map

| Widget Family | User Purpose | Primary Framework | Secondary Frameworks | Notes |
|---|---|---|---|---|
| Clock | Glanceable time and date widgets | `Foundation` | `WidgetKit` | Supports typography, theme, style variants, and size-specific layouts. |
| Calendar | Upcoming events and date context | `EventKit` | `Foundation`, `WidgetKit` | Requires explicit calendar permission and should render empty/denied states clearly. Events renders upcoming starts-soon events or prioritizes currently running events based on its saved mode. |
| Health | Steps, activity, sleep, and other personal metrics | `HealthKit` | `WidgetKit`, `Foundation` | Requests steps, walking/running distance, exercise time, active energy, and sleep-analysis read access. Steps renders today's steps and distance. Activity renders configurable today/weekly exercise minutes, active energy, and sleep totals. Unavailable HealthKit data renders as zero/empty rather than sample activity. |
| Weather | Current conditions, short forecasts, and daylight widgets | `WeatherKit` | `CoreLocation`, `MapKit`, `Foundation`, `WidgetKit` | Uses when-in-use location authorization for current-place weather and MapKit reverse geocoding for display names, then writes temperature, high/low, condition symbol, and weather snapshots to shared widget storage. Current saved presets include `Weather` and `Daylight`. |
| Location | Place, commute, daylight, or contextual location widgets | `CoreLocation` | `MapKit`, `Foundation`, `WidgetKit` | Should minimize refresh frequency and clearly explain permission use. |
| Portal | App-icon launcher widgets with contextual date and place weather | `AppIntents` | `WeatherKit`, `CoreLocation`, `MapKit`, `Foundation`, `WidgetKit` | Portal uses App Intent buttons to open selected apps and host-app WeatherKit/CoreLocation data for current-place temperature and display name. |
| Reminders | Task and completion widgets | `EventKit` | `Foundation`, `WidgetKit` | User-facing family stays separate from Calendar even though the API owner overlaps. |
| Battery | Device battery status widgets | `UIKit` (`UIDevice`) | `WidgetKit`, `Foundation` | Uses `UIDevice` battery monitoring in the host app and writes level/charging state to shared widget storage. No explicit permission required. |
| Storage | Device storage widgets | `Foundation` (`FileManager`) | `WidgetKit` | Reads file-system capacity and available bytes from the host app and writes them to shared widget storage. |
| Sleep | Target bedtime, sleep duration, and sleep progress widgets | `HealthKit` | `WidgetKit`, `Foundation` | Uses sleep-analysis/Health snapshots when available and renders explicit empty states when Health data is unavailable. |
| App Preferences | Appearance, app language, app font, app icon, temperature unit, temperature display, distance unit | `Foundation` | `SwiftUI`, `UIKit`, `WidgetKit` | Stored through app/shared preferences where extension-safe. Appearance controls host-app theme; app language, app font, and unit preferences are shared; alternate app icons are app-only UIKit customization. |
| Live Activities | Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity states | `ActivityKit` | `WidgetKit`, `Foundation`, feature providers | Uses `Core/Services/LiveActivities` to map provider/widget snapshots into ActivityKit-safe view data. Live Activity glass/solid styling does not follow the app Appearance setting. |

## Customization Expectations By Family

| Widget Family | Common Customization Patterns |
|---|---|
| Clock | Font family, weight, numeral style, color theme, background style |
| Calendar | Layout density, date emphasis, icon set, event-count rules, upcoming/current priority |
| Health | Metric selection, today/weekly period, step goal, ring style, gradient, unit display |
| Weather | Icon style, temperature unit, background treatment, location mode |
| Location | Label style, map/no-map variant, icon set, accent treatment |
| Portal | Selected MiniApps, icon clip style, launcher destinations, date/place header styling, weather location |
| Reminders | Count style, completion focus, category filter, typography |
| Battery | Style preset, threshold emphasis, accent color, compact/full presentation |
| Storage | Compact/full storage presentation, actual used/available emphasis |
| Sleep | Target bedtime emphasis, duration pill style, sleep progress metric |
| App Preferences | App language, app font theme, alternate app icon, temperature unit, temperature display mode, distance unit |
| Live Activities | Smart Pill left/right placement, expanded item, Lock Screen Live Activity item, glass/solid Lock Screen treatment |

## Permission Expectations

- **Onboarding-first requests**: The first-launch onboarding flow now includes an optional permissions page with explicit request actions for Health, Weather/Location, and Calendar access.
- **Save-time fallback**: The preview sheet still requests any required permission that remains undetermined when the user saves a dependent widget. For most frameworks (like CoreLocation or EventKit), if the user declines the system prompt, saving is blocked and an alert is shown; a later Save tap shows the alert again and offers to open Settings, since iOS will not re-show the system prompt after a denial.
- **HealthKit Privacy Exception**: Due to Apple privacy rules, the system never exposes whether a user granted or denied read access to Health data. HealthKit read queries only return `.notDetermined`. Because of this, Health widgets treat `.requested` as the highest verifiable permission state and allow saving if the prompt was requested. Blocking `.requested` would permanently prevent all users from saving Health widgets.

| Widget Family | Permission |
|---|---|
| Clock | No permission required |
| Calendar | Calendar access via `EventKit` |
| Health | Health data authorization via `HealthKit` |
| Weather | Usually location authorization when using current location |
| Location | Location authorization via `CoreLocation` |
| Portal | No permission for the buttons; WeatherKit-powered place data depends on WeatherKit availability and cached host-app refreshes. |
| Reminders | Reminders access via `EventKit` |
| Battery | No explicit user permission for device battery state |
| Storage | No explicit user permission for aggregate file-system capacity |
| Sleep | Health data authorization via `HealthKit` |
| App Preferences | No permission required. Alternate app icons use `UIApplication.setAlternateIconName` and stay in the host app only. |
| Live Activities | No separate data permission. It inherits the permission requirements of the selected activity item and requires ActivityKit availability. |

## Current Live Data Refresh

The host app refreshes widget-facing data on a just-in-time basis:

- **Gated refresh**: Data fetches are gated by the saved widget presets. On scene-active, `ContentView` computes which framework categories are needed by saved presets and refreshes only those providers. A fresh install with no presets does not start HealthKit observers, WeatherKit fetches, calendar fetches, or the always-on refresh loops.
- **Hybrid permission flow**: HealthKit, CoreLocation, and EventKit permission requests can happen during onboarding or, if skipped there, when the user saves the first widget that requires them. After a successful save, the relevant provider runs immediately to populate the shared store.
- **Lazy loops**: The 1-second clock loop and 60-second battery/storage loop only run while the scene is active and at least one preset exists; they stop when the library is empty.
- **Pre-warming**: App Groups, custom fonts, `HKHealthStore`, and `EKEventStore` are pre-warmed at app launch to avoid first-tap stalls in the Gallery and save sheets.

Per-framework refresh behavior remains the same once triggered (Health observer queries, WeatherKit bundle with coalescing, EventKit snapshots, battery/storage reads, etc.). WidgetKit extension reads only from the App Group and must not request HealthKit, CoreLocation, or WeatherKit access directly.

Runtime widget rendering should use provider/App Group values or explicit empty/permission-denied states. Static sample numbers belong only in Xcode previews.

Shared app preferences are also read from the App Group:

- App font theme: `SF Pro`, `SF Rounded`, `Quicksand`, or `Fusion Pixel`
- App language: `System`, `English`, `Bahasa Indonesia`, `Español`, or `Português (Brasil)`
- Temperature unit: `Celsius` or `Fahrenheit`
- Temperature display: `Actual` or `Feels Like`
- Distance unit: `Kilometers` or `Miles`

These preferences affect widget typography and formatted widget values. They should not be modeled as per-widget visual style unless a specific widget later needs an override.

Localization strings live in `Abstrakt/Resources/Localizable.xcstrings`. Runtime app language selection is owned by `Core/Localization/LocalizationManager.swift` and should be used by screens, sheets, permission messages, and settings labels instead of hard-coded user-facing strings.

For active development, the app keeps a one-second clock refresh loop while the scene is active, refreshes slower-changing battery and storage data about once per minute, and registers HealthKit observer queries for step/distance changes. The WidgetKit extension currently requests timeline refreshes about once per minute, but iOS may still throttle normal Home Screen widget reloads. True per-second background behavior should move to Live Activities or another system surface designed for live updates.

Live Activities use a single ActivityKit activity for Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity states. The app can choose different content for each state, but iOS does not provide independent enable toggles per state. If a state has no selected item while Dynamic Island is enabled, render the explicit add/empty state instead of an accidental empty capsule.

ActivityKit implementation notes:

- Smart Pill data is compact-only and should never populate expanded or Lock Screen surfaces by fallback.
- Expanded and Lock Screen items should reuse feature-provider snapshots through `Core/Services/LiveActivities/LiveActivityWidgetDataProvider.swift`.
- `Glass` mode should use Liquid Glass/native material where supported and avoid opaque inner containers that obscure the system material.
- `Solid` mode may use a black activity surface, but should still avoid an extra native-background-looking wrapper around the renderer.
- Updating selections should update the running ActivityKit activity immediately; users should not need to toggle Dynamic Island off and on to refresh content.

## Suggested Service Layout

```text
Core/Services/
├── Calendar/
├── Clock/
├── Health/
├── LiveActivities/
├── Location/
├── Reminder/
├── Weather/
├── Battery/
└── Storage/
```

These service folders are data-source-oriented. Widget folders do not need to mirror them one-to-one.

Example:

- `Core/Services/Calendar/` can support multiple widget entries.
- `Core/Services/Weather/` can support both a minimal forecast widget and a more decorative portal-style widget.

## Saved Preset Relationship

Framework ownership does not change the saved-preset architecture:

```text
Apple Framework
    ↓
Core Service
    ↓
Feature Model
    ↓
Customization ViewModel
    ↓
Saved Widget Preset
    ↓
Shared Widget Renderer
    ↓
App Library + WidgetKit Slots
```

The host app should be where preset composition happens. Saving from the gallery writes App Group preset data and a thumbnail image for the system picker. WidgetKit should mostly route timeline data and saved configuration into shared renderers under `Abstrakt/Widgets/`.

ActivityKit should route selected state and provider-backed snapshots into shared renderers under `Abstrakt/LiveActivities/`:

```text
Feature Provider / App Group Cache
    ↓
Core/Services/LiveActivities
    ↓
DynamicIslandActivityAttributes.ContentState
    ↓
LiveActivities/<State> renderer
    ↓
ActivityKit Smart Pills / Expanded / Lock Screen Live Activity
```

For the current iOS Home Screen scope, WidgetKit exposes only three system-visible `Solid Widget` slots: `Small Widget`, `Medium Widget`, and `Large Widget`. Individual feature presets such as Battery, Health, or Dashboard should appear in the app library and in the WidgetKit saved-widget picker only when their saved size matches the selected slot.
