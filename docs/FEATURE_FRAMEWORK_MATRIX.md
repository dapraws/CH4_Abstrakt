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
| Calendar | Upcoming events and date context | `EventKit` | `Foundation`, `WidgetKit` | Requires explicit calendar permission and should render empty/denied states clearly. |
| Health | Steps, activity, sleep, and other personal metrics | `HealthKit` | `WidgetKit`, `Foundation` | Good candidate for per-widget goals, counters, progress styles, and metric selection. |
| Weather | Current conditions and short forecasts | `WeatherKit` | `CoreLocation`, `Foundation`, `WidgetKit` | Location is a dependency when using current-place weather. |
| Location | Place, commute, daylight, or contextual location widgets | `CoreLocation` | `MapKit`, `Foundation`, `WidgetKit` | Should minimize refresh frequency and clearly explain permission use. |
| Reminders | Task and completion widgets | `EventKit` | `Foundation`, `WidgetKit` | User-facing family stays separate from Calendar even though the API owner overlaps. |
| Battery | Device battery status widgets | `UIKit` (`UIDevice`) | `WidgetKit`, `Foundation` | Small, compact, and well suited to Home Screen utility widgets. |

## Customization Expectations By Family

| Widget Family | Common Customization Patterns |
|---|---|
| Clock | Font family, weight, numeral style, color theme, background style |
| Calendar | Layout density, date emphasis, icon set, event-count rules |
| Health | Metric selection, step goal, ring style, gradient, unit display |
| Weather | Icon style, temperature unit, background treatment, location mode |
| Location | Label style, map/no-map variant, icon set, accent treatment |
| Reminders | Count style, completion focus, category filter, typography |
| Battery | Style preset, threshold emphasis, accent color, compact/full presentation |

## Permission Expectations

| Widget Family | Permission |
|---|---|
| Clock | No permission required |
| Calendar | Calendar access via `EventKit` |
| Health | Health data authorization via `HealthKit` |
| Weather | Usually location authorization when using current location |
| Location | Location authorization via `CoreLocation` |
| Reminders | Reminders access via `EventKit` |
| Battery | No explicit user permission for device battery state |

## Suggested Service Layout

```text
Core/Services/
├── Calendar/
├── Clock/
├── Health/
├── Location/
├── Reminder/
├── Weather/
└── Battery/
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
App Library + WidgetExtension Rendering
```

The host app should be where preset composition happens. WidgetKit should mostly render what has already been decided and saved.
