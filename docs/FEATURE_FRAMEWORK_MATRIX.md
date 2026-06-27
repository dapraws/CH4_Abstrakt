# Feature Framework Matrix

This file is the canonical mapping between product features and Apple-native frameworks.

## Principles

- Every feature should have a single primary framework owner.
- Secondary frameworks are allowed when needed for permissions, formatting, or rendering support.
- Extension features should degrade gracefully when permissions are missing.

## Feature Map

| Feature | Primary Framework | Secondary Frameworks | Notes |
|---|---|---|---|
| Battery | `UIKit` (`UIDevice`), `WidgetKit` | `Combine` or shared observation helpers as needed | Device battery level/state can come from `UIDevice`; accessory battery may need future expansion paths. |
| Health Info | `HealthKit` | `WidgetKit`, `Swift Charts` if visual summaries are added | Use this as the umbrella for glanceable metrics such as steps, sleep summaries, calories, or heart rate snapshots. |
| Calendar | `EventKit` | `Foundation`, `WidgetKit` | Fetch upcoming events and calendar metadata through `EKEventStore`. |
| Reminder | `EventKit` | `Foundation`, `WidgetKit` | Reminders are still EventKit-backed, but should be modeled as a distinct feature family. |
| Location | `CoreLocation` | `MapKit` when map previews are needed | Use for current place, travel context, sunrise/sunset relevance, or location-aware widgets. |
| Health | `HealthKit` | `WidgetKit`, `Swift Charts` if needed | Keep this as a separate family only if the product distinguishes broader health dashboards from compact health info widgets. |
| Time | `Foundation` | `WidgetKit`, `ClockKit` is not needed for iOS widgets | Time zones, locale-aware formatting, calendars, and clocks can be handled with `Date`, `Calendar`, and `DateFormatter` or `Date.FormatStyle`. |
| Weather | `WeatherKit` | `CoreLocation`, `Foundation`, `WidgetKit` | Weather should rely on `WeatherKit`; location is a dependency, not the feature owner. |

## Clarifications

### Battery

- Primary source: `UIDevice.current`
- Required setup: `isBatteryMonitoringEnabled = true`
- Good fit for: small and medium widgets, lock screen status widgets

### Health Info / Health

- Primary source: `HealthKit`
- Suggested direction:
  - `Health Info` for compact single-metric widgets
  - `Health` for broader multi-metric summaries
- If the team prefers less overlap, merge both into one `Health` family later

### Calendar / Reminder

- Both rely on `EventKit`
- Keep them as separate user-facing features because the UI, configuration, and empty states differ significantly

### Time

- Prefer `Foundation` formatting APIs
- World clock and multi-timezone support should stay framework-light unless a future requirement proves otherwise

### Weather

- Primary source: `WeatherKit`
- Location can be user-selected or device-driven
- Cache aggressively and respect WidgetKit timeline behavior

## Permission Expectations

| Feature | Permission |
|---|---|
| Battery | No explicit user permission for device battery state |
| Health Info | Health data authorization via `HealthKit` |
| Calendar | Calendar access via `EventKit` |
| Reminder | Reminders access via `EventKit` |
| Location | Location authorization via `CoreLocation` |
| Health | Health data authorization via `HealthKit` |
| Time | No permission required |
| Weather | Usually depends on location authorization if using current location |

## Suggested Shared Provider Layout

```text
Shared/DataProviders/
├── Battery/
├── Calendar/
├── Health/
├── Location/
├── Reminder/
├── Time/
└── Weather/
```

Each provider should expose extension-safe view data instead of leaking framework-specific types deep into widget views.

