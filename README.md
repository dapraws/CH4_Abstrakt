<p align="center">
  <img src="https://github.com/user-attachments/assets/df6cce3f-a7e6-4e98-aa50-0791b7aa8244" alt="Abstrakt Logo" width="120" height="120" />
</p>

<h1 align="center">Abstrakt</h1>

<p align="center">
  <strong>A library of beautifully customizable iPhone widgets.</strong>
</p>

<p align="center">
  Abstrakt is a native SwiftUI app for discovering, configuring, previewing, and saving widget presets before users place them on the iPhone Home Screen. It also explores ActivityKit-powered Dynamic Island and Lock Screen Live Activity surfaces, using the same provider-backed data and design-system foundations as the widget library.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17.0%2B-blue?style=flat-square" alt="iOS 17.0+" />
  <img src="https://img.shields.io/badge/Swift-5.9-orange?style=flat-square" alt="Swift 5.9" />
  <img src="https://img.shields.io/badge/SwiftUI-5-purple?style=flat-square" alt="SwiftUI" />
  <img src="https://img.shields.io/badge/Architecture-MVVM-green?style=flat-square" alt="MVVM" />
  <img src="https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square" alt="License" />
</p>

---

## Screenshots

<p align="center">
  <img src="https://github.com/user-attachments/assets/99cd077e-a1f4-4bc9-a745-b915c087693c" alt="Gallery" width="240" />
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/1cfd6db9-ac2b-4e86-97fe-39ec89f9b7eb" alt="Settings" width="240" />
  &nbsp;&nbsp;
  <img src="https://github.com/user-attachments/assets/49a7db6f-4e93-401e-a321-90add0b6f721" alt="Library" width="240" />
</p>

<p align="center">
  <sub><b>Gallery</b> — browse widgets by framework &nbsp;·&nbsp; <b>Settings</b> — language, font, icons, units, permissions &nbsp;·&nbsp; <b>Library</b> — saved presets by size</sub>
</p>

---

## Product Direction

| Pillar | Direction |
|---|---|
| Host app first | gallery, widget detail, customization sheets, saved library, Live Activities studio, and settings |
| WidgetKit first | iOS Home Screen widget experiences for `small`, `medium`, and `large` slots |
| ActivityKit ready | Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity previews backed by shared activity data |
| Native framework features | `HealthKit`, `WeatherKit`, `CoreLocation`, `EventKit`, `Foundation`, `UIKit`, `AppIntents` |
| Design-system-first | semantic light/dark theming, typography roles, spacing, surface styling, and widget size tokens |
| Localized experience | user-selectable app language backed by the string catalog and shared settings |

---

## Current Architecture

```text
Abstrakt/
├── App/
│   ├── AbstraktApp.swift
│   ├── ContentView.swift
│   ├── Screens/
│   │   ├── Gallery/
│   │   ├── Home/
│   │   ├── Library/
│   │   ├── LiveActivity/
│   │   ├── Onboarding/
│   │   └── Settings/
│   ├── Components/
│   └── Configuration/
│       ├── Components/
│       └── Sheets/
├── Core/
│   ├── Constants/
│   ├── Localization/
│   ├── Models/
│   ├── Services/
│   ├── Settings/
│   └── Storage/
├── DesignSystem/
│   ├── AppColors.swift
│   ├── AppFonts.swift
│   ├── AppRadius.swift
│   ├── AppSpacing.swift
│   ├── WidgetSizeTokens.swift
│   └── Fonts/
├── Widgets/
│   ├── SharedWidgetStyle.swift
│   ├── Activity/
│   ├── Battery/
│   ├── Calendar/
│   ├── Daylight/
│   ├── Events/
│   ├── HeartRate/
│   ├── Portal/
│   ├── Reminder/
│   ├── Sleep/
│   ├── Steps/
│   ├── Storage/
│   ├── Today/
│   └── Weather/
├── LiveActivities/
│   ├── DynamicIslandActivity.swift
│   ├── SmartPills/
│   ├── Expanded/
│   ├── LiveActivity/
│   └── Shared/
└── AbstraktWidgetsExtension/
    ├── AbstraktWidgetsBundle.swift
    ├── AbstraktNewWidgets.swift
    ├── SolidWidgetIntents.swift
    ├── SavedWidgetEntity.swift
    ├── Fonts/
    └── Shared/
```

---

## App Flow

The current main-app flow is:

1. Complete onboarding on first launch (`WelcomeScreen` -> `TutorialScreen` -> `OnboardingPermissionScreen`).
2. Land in the main app shell and browse the widget gallery.
3. Choose a widget card and open its interactive preview sheet.
4. Preview the chosen widget in real-time with on-device styling and actual provider data.
5. Adjust flexible options such as appearance mode (`System`, `Light`, `Dark`), font theme, or widget-specific options (e.g. Portal mini-apps).
6. Tap **Save** to persist the configured preset into the Library. If a framework permission is needed, the system prompt triggers automatically.
7. From the iOS Home Screen, add an Abstrakt `Solid Widget` and select the saved preset from the `Edit Widget` picker.

---

## Current Implementation Snapshot

### Screens & UI

| Area | Details |
|---|---|
| Onboarding | Multi-stage flow with welcome, widget tutorial, and permissions page for Health, Weather/Location, and Calendar. |
| Home | Lightweight placeholder screen in the bottom tab shell. |
| Gallery | Widget cards with catalog-backed category chips (`HealthKit`, `WeatherKit`, `EventKit`, `Foundation`, `UIKit`, `Portal`) and preview sheets. |
| Preview sheet | Renders the selected widget, display title, inline segmented controls, nested picker buttons, and pinned bottom save action. |
| Library | Grouped by `Small`, `Medium`, and `Large`, with swipeable size tabs, size counts, empty states, and cropped preview strips. |
| Settings | Appearance, app language, app font, alternate app icons, temperature unit, temperature display, distance unit, access/permissions, FAQ, share sheet, and release notes. |
| Live Activity | Dynamic Island studio for Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity configurations with Glass/Solid styling. |

### Widget Catalog (13 Widgets)

| Widget | Primary Framework | Size | Behavior |
|---|---|---|---|
| **Reminder** | `EventKit` | `Small` | Reads Reminders via EventKit; displays top 3 tasks with strike-through completion, plus `+N more` count. Deep-links to Reminders list. |
| **Battery** | `UIKit` (`UIDevice`) | `Small` | Reads live battery percentage, charging state, and remaining time calculation. Renders a 5-bar visual gauge. |
| **Steps** | `HealthKit` | `Small` | Queries step count and distance from HealthKit; converts distance to km or miles based on user preference. |
| **Activity** | `HealthKit` | `Small` | Displays exercise minutes, active calories, and sleep time for either `Today` or `Weekly` period. |
| **Sleep** | `HealthKit` | `Small` | Queries sleep analysis categories (`asleepUnspecified`, `asleepCore`, `asleepDeep`, `asleepREM`); shows target bedtime, duration, and efficiency. |
| **Events** | `EventKit` | `Small` | Queries calendar events; configurable for `Upcoming` (starts soon) or `Current` (in progress) priority mode. |
| **Portal** | `AppIntents` | `Small` | 6-app quick launcher with custom icon clip styles (`Default`, `Circle`, `Bloom`), accompanied by live date context and local weather. |
| **Today** | `Foundation` | `Medium` | Multi-card layout: live time & condition header, temp with high/low, full month calendar grid. |
| **Calendar** | `EventKit` | `Small` | Compact month grid with weekday headers, responsive 5/6-week rows, and prominent today highlight. |
| **Storage** | `Foundation` | `Small` | Computes aggregate disk space using base-10 math (1 GB = 10^9 B) matching iOS Settings > General > iPhone Storage. Renders striped progress bar. |
| **Daylight** | `WeatherKit` | `Small` | Computes sunrise and sunset times from solar events; shows next daylight event time, icon, and temperature bounds. |
| **Weather** | `WeatherKit` | `Small` | Reverse geocoded city name, WeatherKit temperature, high/low, and customized weather condition iconography. |
| **Heart Rate** | `HealthKit` | `Small` | Queries the latest heart rate sample (`HKQuantityTypeIdentifier.heartRate`); displays BPM, heart icon, and relative timestamp. |

### Live Activity Rendering

- ActivityKit code lives under `Abstrakt/LiveActivities/` and is split by rendered state: `SmartPills`, `Expanded`, `LiveActivity`, and shared renderer/attribute files.
- The main app screen lives under `Abstrakt/App/Screens/LiveActivity/`, while the preview picker sheet lives in `Abstrakt/App/Configuration/Sheets/LiveActivityPreviewSheet.swift`.
- `Core/Services/LiveActivitiesState.swift` and `LiveActivityWidgetDataProvider.swift` own selected activity state and map provider/widget data into ActivityKit-safe view data.
- Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity can choose different activity items, driven by one ActivityKit activity and one Dynamic Island enable toggle.
- Lock Screen Live Activity supports `Glass` (Liquid Glass / native material with light/dark adaptive text) and `Solid` (pure black with specular border) visual modes.
- Smart Pills active-side feedback is an overlay contour on the phone-frame island preview that animates smoothly when switching slots.

### Data & Permissions

- **Just-in-time data fetching**: Providers refresh only when at least one saved widget requires them; always-on refresh loops stop when the Library is empty.
- **Hybrid permission flow**: Onboarding includes an optional permissions step with explicit request buttons for Health, Weather/Location, and Calendar.
- **Save-time fallback**: If a required permission was skipped or undetermined, saving a dependent widget requests it, blocking the save on denial.
- **HealthKit privacy exception**: Health widgets treat `.requested` as the highest verifiable permission state and permit saving once requested.
- **WeatherKit coalescing**: `WeatherProvider` coalesces concurrent fetches and caches results for 30s to prevent token rejection.

---

## Signing And App Group Configuration

Signing is driven by `Abstrakt/Config/Signing.xcconfig`, with optional local overrides in `Abstrakt/Config/Signing.local.xcconfig`. Copy `Signing.local.xcconfig.example` when a developer needs a personal `DEVELOPMENT_TEAM` or `APP_GROUP_ID`.

The app and widget extension entitlements both read `$(APP_GROUP_ID)`, and the same value is injected into `Info.plist` as `AppGroupID` so host-app providers and WidgetKit read from one shared App Group suite.

---

## System Widget Flow

The iOS widget gallery should expose only the generic `Solid Widget` renderer for the current app direction. It has three supported selections:

- `Small Widget`
- `Medium Widget`
- `Large Widget`

After a user adds one of these widgets to the Home Screen, the system `Edit Widget` sheet exposes a saved widget picker backed by App Intents. That picker must show only saved library presets matching the selected widget size, with thumbnails when the app has generated them.

---

## Widget Size Direction

For now the app should focus on iPhone Home Screen sizes only:

| Size | Default preview target |
|---|---|
| `Small` | `170 x 170` |
| `Medium` | `364 x 170` |
| `Large` | `364 x 382` |

These values are measured fallback sizes and aspect-ratio baselines, not a device-by-device sizing table. In-app previews should fit the available container width while preserving the widget family's measured aspect ratio; WidgetKit widgets should render into the size supplied by the system.

Lock Screen widgets and richer StandBy variants remain follow-up surfaces. Dynamic Island and Lock Screen Live Activity previews are active product surfaces and should continue to reuse provider-backed data instead of static fixtures.

---

## Customization Model

Customization is intentionally flexible:

- Some widgets expose only a few toggles.
- Some widgets open nested sheets such as font pickers.
- Some widgets use inline segmented controls or checkbox-style rows.
- Some widgets support metric-specific settings such as step goals or counters.

Per-widget customization examples:

| Widget | Customization |
|---|---|
| Portal | Six-app MiniApps picker and icon clip styles, shared with WidgetKit through App Group storage. |
| Activity | Today/Weekly display mode, shared with WidgetKit through App Group storage. |
| Events | Upcoming/Current priority mode, shared with WidgetKit through App Group storage. |

Because of that, customization belongs to `App/Configuration/` plus widget-specific configuration sheets inside each widget folder.

Global settings such as temperature unit, temperature display, and distance unit belong to `Core/Settings/` and should be read by both the host app and WidgetKit through extension-safe shared storage. Widget-specific visual choices remain part of the saved preset configuration.

Appearance is also a global app setting. It controls the host app's preferred color scheme and should be persisted through shared settings. Home Screen widget previews still honor each widget's saved appearance behavior, and Live Activity/Dynamic Island surfaces keep their own glass/solid styling.

Language selection is also a global app setting. The string catalog lives at `Abstrakt/Resources/Localizable.xcstrings`, runtime language switching is coordinated by `Core/Localization/LocalizationManager.swift`, and the selected language is persisted with the other shared settings so app text can update without hard-coding strings in screens.

Alternate app icons are app-only customization. The picker uses `Core/Models/AppIconOption.swift`, preview images under `Assets.xcassets/AppIcons/`, and the alternate icon entries registered in `Info.plist`; widget extension code should not call app-icon APIs.

---

## Widget Naming Direction

- Widget folders should be named after the actual widget entry users browse in the gallery.
- Use concise feature names such as `Battery`, `Steps`, `Activity`, `Calendar`, `Events`, `Portal`, `Reminder`, `Sleep`, `Storage`, `Today`, `Weather`, `Daylight`, and `HeartRate`.
- Avoid style-only names or names that only describe the Home Screen size.

The underlying data source still belongs in `Core/Services/`, but the widget itself should be named by the user-facing design/preset identity.

---

## Shared Widget Rendering

Widget visuals should be implemented once under `Abstrakt/Widgets/` and reused by both the host app and `AbstraktWidgetsExtension`.

| Location | Owns |
|---|---|
| `Abstrakt/Widgets/<WidgetName>/` | SwiftUI renderer and any render snapshots that are safe for both targets. |
| `Abstrakt/Widgets/SharedWidgetStyle.swift` | Extension-safe widget typography, palette, and custom font registration. |
| `AbstraktWidgetsExtension/AbstraktNewWidgets.swift` | WidgetKit timelines, entries, size-slot routing, and App Intent configuration only. |

App-only provider adapters or preview conveniences inside shared widget files must be guarded with `#if !WIDGET_EXTENSION`.

## Shared Live Activity Rendering

ActivityKit visuals should follow the same "implement once, reuse everywhere" rule as widgets.

| Location | Owns |
|---|---|
| `Abstrakt/LiveActivities/SmartPills/` | Compact Dynamic Island Smart Pill regions only. |
| `Abstrakt/LiveActivities/Expanded/` | Expanded Dynamic Island activity surfaces. |
| `Abstrakt/LiveActivities/LiveActivity/` | Lock Screen and notification Live Activity surfaces. |
| `Abstrakt/LiveActivities/Shared/` | Activity attributes, typography, empty states, and reusable item renderers. |
| `Abstrakt/Core/Services/LiveActivities/` | Selection state, ActivityKit lifecycle coordination, and provider-to-activity mapping. |

Activity files should use `Activity` naming, screen files should use `Screen`, and configuration sheets should stay under `App/Configuration/Sheets/`.

Live Activity implementation contract:

- `SmartPills` renders only compact Dynamic Island left/right regions. It must never leak a selected compact item into expanded Dynamic Island or Lock Screen Live Activity state.
- `Expanded` renders only expanded Dynamic Island items. If Dynamic Island is enabled and no expanded item is selected, render the explicit add/empty state rather than borrowing another state.
- `LiveActivity` renders only Lock Screen and notification Live Activity items. It owns the `Glass`/`Solid` visual mode and should not inherit the host app Appearance setting.
- `Core/Services/LiveActivities/LiveActivitiesState.swift` is the source of truth for selected activity items, side selection, visual mode, haptics, and ActivityKit start/update/end behavior.
- Activity previews in the app should use the same renderer, typography, sizing intent, and corner-radius language as ActivityKit. If a preview needs to fit a sheet, scale the preview container instead of changing internal layout math.
- Shared controls such as `Glass`/`Solid` and `Edit | Delete` should use the same subtle glass treatment across Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity previews.
- Runtime activity data must come from provider/cache-backed snapshots or a deliberate add/empty state. Static fixtures belong only in Xcode previews.
- `Edit | Delete`, `Glass/Solid`, selected badges, and side badges are controls around the preview. Selected badges (`checkmark.seal.fill`, `L`, `R`) should overlay sheet preview items only, not the actual island or lockscreen activity.

---

## Core Model Direction

`Core/Models/` is the shared model layer for the app. That is where common types such as widget presets, widget sizes, appearance modes, catalog items, and categories should live.

Not every widget needs its own `Model` or `ViewModel` file. A widget folder should only add local types when it truly has unique configuration or presentation logic that is not shared.

---

## Team

Built by a team from **Apple Developer Academy @ BINUS Bali** as part of an App Extension challenge.

<table align="center">
  <tr>
    <td align="center" width="260">
      <img src="https://github.com/msafdev.png" width="120" height="120" style="border-radius: 50%;" alt="Salman's Profile" /><br/><br/>
      <strong>M. Salman Alfarisi</strong><br/>
      <sub>Developer</sub><br/><br/>
      <a href="https://github.com/msafdev"><img src="https://img.shields.io/badge/-GitHub-181717?style=flat-square&logo=github" alt="Salman's GitHub" /></a>
      <a href="https://linkedin.com/in/msafdev"><img src="https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="Salman's LinkedIn" /></a>
    </td>
    <td align="center" width="260">
      <img src="https://github.com/dapraws.png" width="120" height="120" style="border-radius: 50%;" alt="Darrel's Profile" /><br/><br/>
      <strong>M. Darrel Prawira</strong><br/>
      <sub>Developer</sub><br/><br/>
      <a href="https://github.com/dapraws"><img src="https://img.shields.io/badge/-GitHub-181717?style=flat-square&logo=github" alt="Darrel's Github" /></a>
      <a href="https://www.linkedin.com/in/dapraws/"><img src="https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="Darrel's LinkedIn" /></a>
    </td>
  </tr>
  <tr>
    <td align="center" width="260">
      <img src="https://media.licdn.com/dms/image/v2/D5603AQFyte7BRlP91A/profile-displayphoto-crop_800_800/B56ZmypVQtJ0AI-/0/1759638804206?e=1784764800&v=beta&t=_3BSTiPiIebe2vLP3SG7HGD1V5Fv3mgrnUJ5Y1qXbX4" width="120" height="120" style="border-radius: 50%;" alt="Daffa's Profile" /><br/><br/>
      <strong>Daffa Yusranizar A.</strong><br/>
      <sub>Developer</sub><br/><br/>
      <a href="https://github.com/daffayusranizar"><img src="https://img.shields.io/badge/-GitHub-181717?style=flat-square&logo=github" alt="GitHub" /></a>
      <a href="https://www.linkedin.com/in/daffayusranizar/"><img src="https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="Daffa's LinkedIn" /></a>
    </td>
    <td align="center" width="260">
      <img src="https://media.licdn.com/dms/image/v2/D4E03AQGFg_vR4EQvew/profile-displayphoto-crop_800_800/B4EZ8m_UPBJMAI-/0/1783065560959?e=1784764800&v=beta&t=ppxF1_RxTXHrb2ADbAZLTWXzMkR3f77l0dX4R1Xj-7g" width="120" height="120" style="border-radius: 50%;" alt="Syafiq's Profile" /><br/><br/>
      <strong>Syafiq Fii Dzilaalin</strong><br/>
      <sub>Designer</sub><br/><br/>
      <a href="https://www.linkedin.com/in/syafiq-fii-dzilaalin-5a5200265/"><img src="https://img.shields.io/badge/-LinkedIn-0A66C2?style=flat-square&logo=linkedin&logoColor=white" alt="Syafiq's LinkedIn" /></a>
    </td>
  </tr>
</table>

---

## Documentation Map

Start here when making architecture or product changes:

| # | Document | Purpose |
|---|---|---|
| 1 | [docs/PROJECT_OVERVIEW.md](./docs/PROJECT_OVERVIEW.md) | Product shape, core UX, module direction |
| 2 | [docs/FEATURE_FRAMEWORK_MATRIX.md](./docs/FEATURE_FRAMEWORK_MATRIX.md) | Widget-to-framework mapping, permissions, services |
| 3 | [docs/DESIGN_FOUNDATION.md](./docs/DESIGN_FOUNDATION.md) | Design tokens, appearance modes, layout rules, typography |
| 4 | [docs/architecture/FOLDER_STRUCTURE.md](./docs/architecture/FOLDER_STRUCTURE.md) | Canonical folder blueprint, naming rules |
| 5 | [docs/product/WIDGET_LIBRARY_FLOW.md](./docs/product/WIDGET_LIBRARY_FLOW.md) | User flow, customization rules, library rules |
| 6 | [docs/product/FLOW.d2](./docs/product/FLOW.d2) | Architecture and user/data flow diagram |
| 7 | [docs/TECH_REPORT.md](./docs/TECH_REPORT.md) | Engineering highlights, team, decisions, platform learnings |
| 8 | [.codex/skills/abstrakt-codebase/SKILL.md](./.codex/skills/abstrakt-codebase/SKILL.md) | Repo-local working skill for agents touching Abstrakt |

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
