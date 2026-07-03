# Feature Framework Matrix

This file is the canonical mapping between widget features and Apple-native frameworks.

## Principles

- Each widget family should have one primary framework owner.
- Secondary frameworks may support permissions, formatting, caching, or rendering.
- Widgets must degrade gracefully when permissions are missing or data is stale.
- Configuration capabilities belong to the app experience even when the data itself comes from system frameworks.

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
| Battery | Device battery status widgets | `UIKit` (`UIDevice`) | `WidgetKit`, `Foundation` | Uses `UIDevice` battery monitoring in the host app and writes level/charging state to shared widget storage. |
| Storage | Device storage widgets | `Foundation` (`FileManager`) | `WidgetKit` | Reads file-system capacity and available bytes from the host app and writes them to shared widget storage. |
| App Preferences | App font, temperature unit, temperature display, distance unit | `Foundation` | `SwiftUI`, `WidgetKit` | Stored through app/shared preferences. App font and unit preferences are shared with widget rendering. |

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
| App Preferences | App font theme, temperature unit, temperature display mode, distance unit |

## Permission Expectations

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
| App Preferences | No permission required |

## Current Live Data Refresh

The host app refreshes widget-facing data on launch and whenever the scene becomes active:

- Health: requests `HealthKit` read access for step count, walking/running distance, exercise time, active energy, and sleep analysis, then stores today's step/distance totals plus today and weekly exercise minutes, active energy, and sleep totals for health widgets.
- Battery: enables `UIDevice` battery monitoring, stores percentage and charging state, and estimates remaining hours when discharging.
- Calendar: requests EventKit calendar access, stores today's weekday plus the next remaining event for legacy consumers, and stores a richer same-day event snapshot for widgets that need to distinguish upcoming and current events.
- Storage: reads total and available file-system capacity, then stores aggregate byte counts.
- Weather: requests when-in-use location authorization, fetches local WeatherKit conditions, and stores current temperature, today's high/low, condition symbols, and weather widget snapshots.
- Portal: fetches WeatherKit conditions for the current location in the host app and stores the current temperature/place name for the widget renderer.

The WidgetKit extension reads these values from the App Group. It should not request HealthKit, CoreLocation, or WeatherKit access directly.

Runtime widget rendering should use provider/App Group values or explicit empty/permission-denied states. Static sample numbers belong only in Xcode previews.

Shared unit preferences are also read from the App Group:

- App font theme: `SF Pro`, `SF Pro Rounded`, `Quicksand`, or `Fusion Pixel`
- Temperature unit: `Celsius` or `Fahrenheit`
- Temperature display: `Actual` or `Feels Like`
- Distance unit: `Kilometers` or `Miles`

These preferences affect widget typography and formatted widget values. They should not be modeled as per-widget visual style unless a specific widget later needs an override.

For active development, the app also runs a one-second host-app refresh loop while the scene is active and registers HealthKit observer queries for step/distance changes. The WidgetKit extension requests a one-second timeline reload, but iOS may throttle normal Home Screen widget reloads. True per-second background behavior should move to Live Activities or another system surface designed for live updates.

## Suggested Service Layout

```text
Core/Services/
├── Calendar/
├── Clock/
├── Health/
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
App Library + WidgetExtension Slots
```

The host app should be where preset composition happens. WidgetKit should mostly route timeline data and saved configuration into shared renderers under `Abstrakt/Widgets/`.

For the current iOS Home Screen scope, WidgetKit exposes only three system-visible `Solid Widget` slots: `Small Widget`, `Medium Widget`, and `Large Widget`. Individual feature presets such as Battery, Health, or Dashboard should appear in the app library and in the WidgetKit `Current Widget` picker only when their saved size matches the selected slot.
