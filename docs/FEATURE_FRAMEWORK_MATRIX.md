# Feature Framework Matrix

This document defines the canonical mapping between Abstrakt feature surfaces, Apple-native frameworks, host-app service providers, and shared App Group storage.

## Principles

- **Single Framework Owner**: Each widget family maps to a clear primary framework owner.
- **Graceful Degradation**: Widgets must degrade gracefully to explicit empty, loading, or permission-needed states rather than breaking or showing fabricated metrics.
- **Extension Safety**: App extensions (`AbstraktWidgetsExtension` and `DynamicIslandActivity`) read serialized data snapshots from App Group storage without initiating network or framework queries directly.
- **Provider Centralization**: Framework access, background delivery, throttling, and coalescing are isolated behind service providers in `Core/Services/`.
- **Shared Activity Foundation**: ActivityKit surfaces consume the same provider-backed feature data as widgets.

---

## Complete Widget Catalog & Framework Mapping

The catalog contains **13 widgets** spanning 5 distinct catalog categories:

| Widget Name | Category | Primary Framework | Supporting Frameworks | Host Provider | Supported Sizes | User-Facing Purpose |
|---|---|---|---|---|---|---|
| **Reminder** | `.calendar` | `EventKit` | `Foundation`, `WidgetKit` | `ReminderProvider` | `Small` | Reads Reminders via EventKit; displays top 3 tasks with strike-through completion, plus `+N more` count. Deep-links to Reminders list. |
| **Battery** | `.system` | `UIKit` (`UIDevice`) | `WidgetKit`, `Foundation` | `BatteryStatusProvider` | `Small` | Reads live battery percentage, charging status, and remaining time calculation. Renders a 5-bar visual gauge. |
| **Steps** | `.health` | `HealthKit` | `WidgetKit`, `Foundation` | `HealthSummaryProvider` | `Small` | Queries step count and distance from HealthKit; converts distance to km or miles based on user preference. |
| **Activity** | `.health` | `HealthKit` | `WidgetKit`, `Foundation` | `HealthSummaryProvider` | `Small` | Displays exercise minutes, active calories, and sleep time for either `Today` or `Weekly` period. |
| **Sleep** | `.health` | `HealthKit` | `WidgetKit`, `Foundation` | `HealthSummaryProvider` | `Small` | Queries sleep analysis categories (`asleepUnspecified`, `asleepCore`, `asleepDeep`, `asleepREM`); shows target bedtime, duration, and efficiency. |
| **Events** | `.calendar` | `EventKit` | `Foundation`, `WidgetKit` | `EventKitProvider` | `Small` | Queries calendar events; configurable for `Upcoming` (starts soon) or `Current` (in progress) priority mode. |
| **Portal** | `.portal` | `AppIntents` | `WeatherKit`, `CoreLocation`, `MapKit`, `WidgetKit` | `WeatherProvider`, `LocationProvider` | `Small` | 6-app quick launcher with custom icon clip styles (`Default`, `Circle`, `Bloom`), accompanied by live date context and local weather. |
| **Today** | `.system` | `Foundation` | `WeatherKit`, `EventKit`, `CoreLocation`, `WidgetKit` | `WeatherProvider`, `ClockDataProvider`, `EventKitProvider` | `Medium` | Multi-pane dashboard combining live clock time with condition header, current temperature with high/low, and a full monthly calendar grid with today highlighted. |
| **Calendar** | `.calendar` | `EventKit` | `Foundation`, `WidgetKit` | `EventKitProvider`, `ClockDataProvider` | `Small` | Compact month grid with weekday headers, responsive 5/6-week rows, and prominent today highlight. |
| **Storage** | `.system` | `Foundation` (`FileManager`) | `WidgetKit` | `StorageProvider` | `Small` | Computes aggregate disk space using base-10 math (1 GB = 1,000,000,000 bytes) matching iOS Settings > General > iPhone Storage. Renders striped progress bar. |
| **Daylight** | `.weather` | `WeatherKit` | `CoreLocation`, `Foundation`, `WidgetKit` | `WeatherProvider`, `LocationProvider` | `Small` | Computes sunrise and sunset times from solar events; shows next daylight event time, icon, and temperature bounds. |
| **Weather** | `.weather` | `WeatherKit` | `CoreLocation`, `MapKit`, `Foundation`, `WidgetKit` | `WeatherProvider`, `LocationProvider` | `Small` | Reverse geocoded city name, WeatherKit temperature, high/low, and customized weather condition iconography. |
| **Heart Rate** | `.health` | `HealthKit` | `WidgetKit`, `Foundation` | `HealthSummaryProvider` | `Small` | Queries the latest heart rate sample (`HKQuantityTypeIdentifier.heartRate`); displays BPM, heart icon, and relative timestamp (e.g. `47s ago`). |
| **Clock** | `.foundation` | `Foundation` | `WidgetKit` | `ClockDataProvider` | `Small` | Analog Roman numeral dial with center hour watermark, accurate hour/minute hands, and red second needle with Dark/Light theme support. |
| **Gradient** | `.weather` | `WeatherKit` | `CoreLocation`, `Foundation`, `WidgetKit` | `WeatherProvider`, `LocationProvider` | `Small`, `Medium` | Natural editorial weather summary sentences on 4 selectable styles (Ruby aurora, Cyan aurora, Fractal pleated prism, and Amber bottom contour light) with unified dark atmospheric contrast across light/dark appearances. |

---

## ActivityKit (Live Activities & Dynamic Island)

| Presentation State | Surface Target | Supported Widget Layouts | Framework Owner | Provider Source | Notes |
|---|---|---|---|---|---|
| **Smart Pills** | Compact Dynamic Island (`compactLeading`, `compactTrailing`, `minimal`) | 25 compact layouts (`iconTopTextBottom`, `textTopTextBottom`, `temperatureHighLow`, `ringGauge`, `windCompass`, `analogClock`, `stopwatchDial`, `secondsValue`, `dateFraction`, `calendarStack`, etc.) | `ActivityKit` | `LiveActivitiesState`, `LiveActivityWidgetDataProvider` | Leading and trailing regions can host independent compact widgets. Single enable toggle manages activity lifecycle. |
| **Expanded** | Expanded Dynamic Island (`expandedRegion(.center)`) | `Today Info`, `Weather Info`, `Calendar Info`, plus scaled compact widgets | `ActivityKit` | `LiveActivitiesState`, `LiveActivityWidgetDataProvider` | Centered expanded surface (width: 291pt, corner radius: 20pt). Unselected state renders explicit add/empty capsule. |
| **Live Activity** | Lock Screen & Notification Center banner | `Today Info`, `Weather Info`, `Calendar Info`, plus compact widgets | `ActivityKit` | `LiveActivitiesState`, `LiveActivityWidgetDataProvider` | Supports `Glass` (Liquid Glass / system material) and `Solid` (black) visual modes. Independent from app Appearance. |

---

## Service Providers & Framework Access

All Apple framework integrations are located in `Core/Services/`:

```text
Core/Services/
├── BatteryStatusProvider.swift       # UIDevice battery monitoring & time-to-full estimation
├── ClockDataProvider.swift          # 1-second interval clock and date snapshots
├── EventKitManager.swift            # EKEventStore singleton & permission state tracking
├── EventKitProvider.swift           # Calendar event queries, sorting, and upcoming/current filtering
├── Haptics.swift                    # UIImpactFeedbackGenerator / UINotificationFeedbackGenerator helpers
├── HealthSummaryProvider.swift      # HealthKit queries: steps, distance, active calories, sleep, heart rate
├── LiveActivitiesState.swift        # ActivityKit lifecycle: Activity<DynamicIslandActivityAttributes> start/update/end
├── LiveActivityWidgetDataProvider.swift # Transforms provider snapshots into ActivityKit view data
├── LocationProvider.swift           # CLLocationManager & CLGeocoder reverse geocoding
├── ReminderProvider.swift           # EKReminder queries, completion filtering, and snapshot creation
├── StorageProvider.swift            # FileManager filesystem capacity & available byte calculation
└── WeatherProvider.swift            # WeatherKit client with in-flight task coalescing & 30s cache TTL
```

---

## Permission Handling & Apple Privacy Guidelines

### 1. Hybrid Permission Flow
- **Onboarding Step**: First launch includes an onboarding permissions screen with explicit prompt buttons for Health, Weather/Location, and Calendar.
- **Save-Time Fallback**: If a permission is skipped or undetermined, tapping "Save" in `WidgetPreviewSheet` requests the required permission before saving the preset.
- **Declined Handling**: If a user denies permission, saving is blocked and an alert is shown directing the user to iOS Settings.

### 2. HealthKit Privacy Exception
- Due to Apple privacy rules, `HKHealthStore.authorizationStatus(for:)` for read data always returns `.notDetermined` unless explicitly requested.
- Health-dependent widgets treat `.requested` as the highest verifiable authorization state and permit saving once requested.
- Blocking `.requested` would permanently lock users out of saving Health widgets.

### 3. WeatherKit Request Storm Prevention
- `WeatherProvider` maintains an in-flight `Task<WeatherSnapshot, Error>` cache and a 30-second snapshot cache.
- Prevents rapid concurrent widget previews or background tasks from spamming WeatherKit and triggering Apple JWT token rejection.

---

## Data Synchronization via App Groups

All shared runtime data is persisted to the App Group (`APP_GROUP_ID`) via `SharedModelContainer` in the host app and read via `WidgetSharedStore` in the extension:

```text
Host App (Providers)
       │
       ▼
SharedModelContainer (UserDefaults + Disk Thumbnails)
       │  App Group Suite ("group.com.abstrakt.shared")
       ▼
WidgetSharedStore (Extension Cache with 5s JSON TTL)
       │
       ├─► WidgetKit Timeline Providers (SmallSolidWidgetProvider, etc.)
       │         │
       │         ▼
       │   SolidWidget (Small, Medium, Large)
       │
       └─► DynamicIslandActivity (SmartPills, Expanded, LockScreenActivity)
```

### Timeline Reload Coordination
When a preset is saved, removed, or app font/preferences change, `WidgetTimelineReloadScheduler.schedule(after: .milliseconds(450))` debounces reload requests to prevent WidgetKit reload throttling.
