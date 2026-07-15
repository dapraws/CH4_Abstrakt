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
| Host app first | gallery, widget detail, customization sheets, saved library, and settings |
| WidgetKit first | iOS Home Screen widget experiences for `small`, `medium`, and `large` |
| ActivityKit ready | Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity previews backed by shared activity data |
| Native framework features | `HealthKit`, `WeatherKit`, `CoreLocation`, `EventKit`, `Foundation`, and related Apple APIs |
| Design-system-first | semantic light/dark theming, typography roles, spacing, surface styling, and widget size tokens |
| Localized experience | user-selectable app language backed by the string catalog and shared settings |

---

## Current Architecture

```text
Abstrakt/
├── App/
│   ├── AbstraktApp.swift
│   ├── Screens/
│   ├── Components/
│   ├── ContentView.swift
│   └── Configuration/
├── Core/
│   ├── Models/
│   ├── Services/
│   ├── Storage/
│   ├── Constants/
│   ├── Localization/
│   └── Extensions/
├── DesignSystem/
├── Widgets/
│   ├── SharedWidgetStyle.swift
│   ├── Battery/
│   ├── Steps/
│   ├── Activity/
│   ├── Calendar/
│   ├── Events/
│   ├── Portal/
│   ├── Reminder/
│   ├── Sleep/
│   ├── Storage/
│   ├── Today/
│   ├── Weather/
│   ├── Daylight/
│   └── HeartRate/
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

1. Complete onboarding the first time the app launches.
2. Land in the main app shell and browse the widget gallery.
3. Choose a widget and open a customization sheet.
4. Preview the chosen widget size on-device style.
5. Adjust flexible options such as appearance mode, font, or widget-specific settings.
6. Save that configured widget preset into the Library page.
7. From the Home Screen, add a system widget and select the saved preset through the widget configuration flow.

This means the app library is the source of truth for saved widget presets, while WidgetKit is the renderer on the Home Screen.

---

## Current Implementation Snapshot

The current app foundation includes:

### Screens & UI

| Area | Details |
|---|---|
| Onboarding | First-launch flow with welcome, widget tutorial, and a permissions page for Health, Weather/Location, and Calendar access. |
| Home | Present in the tab shell as a lightweight placeholder screen. |
| Gallery | Widget cards with catalog-backed category chips and a preview sheet for the selected widget. |
| Preview sheet | Renders the selected widget, shows its display title, and keeps the bottom save action in a separate control layer. |
| Library | Grouped by `Small`, `Medium`, and `Large`, with swipeable size tabs, empty states, and cropped/scaled preview rows that hint at the saved widget surface. |
| Settings | Appearance, app language, app font, alternate app icon, temperature unit, temperature display, distance unit, access/permissions, FAQ, share sheet, and release notes. |
| Live Activity | Dynamic Island builder for Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity selections. |

### Widget rendering

- Shared widget renderers under `Abstrakt/Widgets/` that are compiled into both the host app and the WidgetKit extension.
- Runtime widget previews and WidgetKit timelines consume live provider data or App Group cached values for battery, Health, calendar/date, time, storage, and WeatherKit-backed weather. Sample numbers are reserved for Xcode canvas previews.
- Shared settings storage for widget-facing unit preferences and the selected widget font through the App Group.
- Shared appearance storage for `System`, `Light`, and `Dark` app theme preferences. Home Screen widgets follow widget appearance configuration and shared font settings; ActivityKit surfaces stay visually independent from the app theme.
- Shared localization storage for `System`, `English`, `Bahasa Indonesia`, `Español`, and `Português (Brasil)` language choices.
- Seamless rendering on iOS 17+ StandBy and iPad Lock Screens via the `containerBackground` API.

### Widget behavior

| Widget | Behavior |
|---|---|
| Activity | Shows either today or weekly exercise minutes, active energy, and sleep totals, with the mode shared to WidgetKit through App Group storage. |
| Calendar | Shows a compact month grid with today's date highlighted and responsive five/six-week month layout. |
| Events | Can prioritize upcoming events or currently running events, backed by EventKit refreshes cached into App Group storage. |
| Portal | Combines calendar date context, current-location WeatherKit temperature, configurable MiniApp launchers, and App Intent buttons for launching selected system apps. |
| Reminder | Reads Apple Reminders through EventKit, renders pending and completed tasks, supports empty state, and opens Reminders from the placed widget. |
| Sleep | Renders target bedtime, sleep duration, and sleep progress using Health-backed snapshots when available. |
| Weather & Daylight | Backed by host-app WeatherKit/CoreLocation refreshes and shared weather condition assets. |
| Storage | Device storage widgets using base-10 calculation math to perfectly match the iPhone's Settings > General > iPhone Storage metrics. |
| Heart Rate | Reads live background BPM data from the user's HealthKit datastore. |

### Live Activity rendering

- ActivityKit code lives under `Abstrakt/LiveActivities/` and is split by rendered state: `SmartPills`, `Expanded`, `LiveActivity`, and shared renderer/attribute files.
- The main app screen lives under `Abstrakt/App/Screens/LiveActivity/`, while the preview picker sheet lives in `Abstrakt/App/Configuration/Sheets/LiveActivityPreviewSheet.swift`.
- `Core/Services/LiveActivities/` owns selected activity state and maps provider/widget data into ActivityKit-safe view data.
- Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity can choose different activity items, but they are driven by one ActivityKit activity and one Dynamic Island enable toggle.
- Runtime ActivityKit rendering should use provider/cache values or the explicit add/empty state. Static demo numbers belong only in Xcode previews.
- Lock Screen Live Activity supports `Glass` and `Solid` visual modes. Live Activity surfaces intentionally do not inherit the app Appearance setting.

### Data & permissions

- Just-in-time data fetching: providers refresh only when at least one saved widget needs them, and always-on refresh loops stop when the Library is empty.
- Hybrid permission flow: onboarding now includes an optional permissions step with explicit request buttons for Health, Weather/Location, and Calendar access.
- Save-time fallback: if a required permission was skipped during onboarding or is still undetermined, the preview sheet requests it when the user saves a dependent widget, blocks the save on denial, and lets the user retry or open Settings. (Note: due to Apple privacy limits, HealthKit permissions are considered valid once they have been `.requested`, since read access cannot be explicitly verified).

The app font preference is written to shared storage so Home Screen widgets and in-app previews can render with matching typography. Widget views must stay extension-safe because the WidgetKit target also compiles the shared files under `Abstrakt/Widgets/`.

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
| 6 | [.codex/skills/abstrakt-codebase/SKILL.md](./.codex/skills/abstrakt-codebase/SKILL.md) | Repo-local working skill for agents touching Abstrakt |

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
