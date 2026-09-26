# Project Overview

## Summary

Abstrakt is a native SwiftUI iOS app designed to configure, preview, and manage custom widgets and ActivityKit surfaces. Users discover widget concepts across Apple frameworks, preview on-device styles, customize options, and save presets into their personal Library. On the Home Screen, WidgetKit's `Solid Widget` slots render those saved presets using live data cached in shared App Group storage. In parallel, Abstrakt provides a Dynamic Island & Lock Screen Live Activity control system featuring Smart Pills, expanded Dynamic Island widgets, and Glass/Solid Lock Screen presentations.

---

## Product Shape

- **Host App**: Discovery gallery, interactive customization sheets, saved library, Live Activity studio, permissions dashboard, and global settings.
- **Onboarding Gate**: Multi-stage first-launch experience (`WelcomeScreen` -> `TutorialScreen` -> `OnboardingPermissionScreen`) persisted via `hasCompletedOnboarding`.
- **WidgetKit Extension**: Exposes three generic size slots (`Small Widget`, `Medium Widget`, `Large Widget`) driven by App Intents (`SmallSolidWidgetIntent`, `MediumSolidWidgetIntent`, `LargeSolidWidgetIntent`) and dynamic queries (`SmallSavedWidgetQuery`, `MediumSavedWidgetQuery`, `LargeSavedWidgetQuery`).
- **Shared Render Architecture**: 13 widget renderers live in `Abstrakt/Widgets/` and are compiled directly into both the main app and `AbstraktWidgetsExtension`.
- **ActivityKit Architecture**: ActivityKit presentation code is partitioned under `Abstrakt/LiveActivities/` into `SmartPills` (compact leading/trailing), `Expanded` (expanded island), `LiveActivity` (Lock Screen banner), and `Shared` (renderers and typography).
- **App Group Store**: Live snapshots (`BatterySnapshot`, `HealthSummarySnapshot`, `SleepSnapshot`, `EventsSnapshot`, `WeatherSnapshot`, `DaylightSnapshot`, `PortalSnapshot`, `StorageSnapshot`, `HeartRateSnapshot`) are serialized by `SharedModelContainer` in the host app and read by `WidgetSharedStore` in extensions.
- **Simulator Compatibility**: Includes an automated fallback (`setSimulatorActivePreset` / `simulatorActivePresetID`) that routes active presets on iOS Simulators where system AppIntent pickers are broken.
- **Design System Tokens**: Semantic tokens in `DesignSystem/` (`AppColors`, `AppFonts`, `AppRadius`, `AppSpacing`, `WidgetSizeTokens`) ensure cohesive visual presentation.
- **Localization Support**: User-selectable in-app languages (`System`, `English`, `Bahasa Indonesia`, `Español`, `Português (Brasil)`) backed by `Localizable.xcstrings` and `LocalizationManager`.

---

## Core User Experience

```text
Onboarding (First Launch)
   │
   ▼
Main App Shell (BottomBar Navigation)
   ├─► Gallery Screen ──► Tap Widget Card ──► WidgetPreviewSheet
   │                                               │
   │                                               ├─► Appearance (System / Light / Dark)
   │                                               ├─► Widget-Specific Options (Mode, Font, Apps)
   │                                               ▼
   │                                          Save Preset (Validates/Prompts Permissions)
   │                                               │
   │                                               ▼
   │                                          SharedModelContainer (App Group Disk/Defaults)
   │                                               │
   │                                               ▼
   ├─► Library Screen ◄────────────────────────────┘
   │     (Grouped by Small, Medium, Large tabs; Edit / Delete presets)
   │
   ├─► Live Activity Screen ──► Smart Pills / Expanded / Live Activity Selector
   │                             │
   │                             ├─► LiveActivityPreviewSheet (Browse & Assign Widgets)
   │                             ├─► Glass / Solid Style Picker
   │                             ▼
   │                         LiveActivitiesState (ActivityKit start / update / end)
   │
   └─► Settings Screen (Appearance, Language, Fonts, Alternate Icons, Units, FAQ, Permissions)
```

---

## The 13 Widgets in Abstrakt

| # | Widget | Category | Size | Primary Framework | Key Capabilities |
|---|---|---|---|---|---|
| 1 | **Reminder** | `.calendar` | `Small` | `EventKit` | Top 3 tasks, completion strike-through, `+N more` counter, deep link URL. |
| 2 | **Battery** | `.system` | `Small` | `UIKit` | Level percentage, charging state, remaining duration, 5-bar fill gauge. |
| 3 | **Steps** | `.health` | `Small` | `HealthKit` | Daily step count, formatted distance with user-selected unit (km/mi). |
| 4 | **Activity** | `.health` | `Small` | `HealthKit` | Exercise minutes, active calories, sleep time for Today or Weekly scope. |
| 5 | **Sleep** | `.health` | `Small` | `HealthKit` | Target bedtime, sleep duration pill, sleep efficiency percentage. |
| 6 | **Events** | `.calendar` | `Small` | `EventKit` | Upcoming or Current event prioritisation, time countdown, multi-event count. |
| 7 | **Portal** | `.portal` | `Small` | `AppIntents` | 6 interactive app launcher buttons, custom icon clipping, local weather & date. |
| 8 | **Today** | `.system` | `Medium` | `Foundation` | Multi-card layout: live time & condition header, temp with high/low, full month calendar grid. |
| 9 | **Calendar** | `.calendar` | `Small` | `EventKit` | Responsive month grid, weekday header, highlight for current date. |
| 10 | **Storage** | `.system` | `Small` | `Foundation` | Base-10 filesystem calculation (1 GB = 10^9 B), used/available striped gauge. |
| 11 | **Daylight** | `.weather` | `Small` | `WeatherKit` | Solar event calculations (sunrise/sunset time and icon), temperature range. |
| 12 | **Weather** | `.weather` | `Small` | `WeatherKit` | Reverse-geocoded place name, current condition symbol, temperature & bounds. |
| 13 | **Heart Rate** | `.health` | `Small` | `HealthKit` | Live background BPM reading from HealthKit, relative sample timestamp. |

---

## MVVM Architectural Layers

### 1. Model Layer (`Core/Models/`, Feature Snapshots)
- Domain data types (`WidgetCatalogItem`, `WidgetCategory`, `WidgetPreset`, `WidgetSize`, `WidgetAppearanceMode`, `AppIconOption`).
- Immutable render snapshots (`BatterySnapshotViewData`, `StepsSnapshot`, `ActivitySnapshot`, `EventsSnapshot`, `ReminderSnapshot`, `SleepSnapshot`, `PortalSnapshot`, `StorageUsageSnapshot`, `TodaySnapshot`, `WeatherSnapshot`, `DaylightSnapshot`, `HeartRateRenderSnapshot`).
- Shared ActivityKit models (`DynamicIslandActivityAttributes`, `LiveActivityWidget`, `LiveActivityWidgetLayout`).

### 2. View Layer (`App/`, `Widgets/`, `LiveActivities/`)
- Pure SwiftUI composition consuming pre-formatted view models or snapshots.
- Views never make direct network, CoreLocation, HealthKit, or EventKit calls.
- Extension renderers in `Widgets/` are lightweight and execute inside memory-constrained WidgetKit extension processes.

### 3. Service & Provider Layer (`Core/Services/`)
- Isolates system framework access behind clean, asynchronous interfaces.
- Implements background query delivery, request throttling, task coalescing, and reverse geocoding.
- Gated by active presets in `ContentView` to conserve battery and CPU resources.

### 4. Shared Storage Layer (`Core/Storage/`, `WidgetSharedStore.swift`)
- `SharedModelContainer`: Writes JSON payloads, disk thumbnails (`<presetID>.png`), and triggers debounced timeline reloads via `WidgetTimelineReloadScheduler`.
- `WidgetSharedStore`: Extension-safe reader with in-memory JSON decode caching (5-second TTL) to guarantee instantaneous WidgetKit timeline generation.

---

## Live Activity & Dynamic Island Matrix

Abstrakt manages a unified `DynamicIslandActivityAttributes` instance that drives 3 distinct presentation contexts:

1. **Smart Pills (Compact Dynamic Island)**: Leading and trailing capsules render independent compact widgets selected from 25 available layouts (e.g. gauges, clocks, compasses, dials, progress rings).
2. **Expanded Dynamic Island**: A centered 291x112pt canvas presenting rich cards such as `Today Info`, `Weather Info`, and `Calendar Info`.
3. **Lock Screen Live Activity**: Prominent banner on Lock Screen and Notification Center supporting **Glass** (Liquid Glass with light/dark adaptive text) and **Solid** (pure black with specular border) styling.
