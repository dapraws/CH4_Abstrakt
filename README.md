# Abstrakt

Abstrakt is a native SwiftUI app for discovering, configuring, previewing, and saving widget presets before users place them on the iPhone Home Screen. The product is inspired by widget-first apps such as Koco, but it is built around Apple-native frameworks, a simple data layer, and an extension-safe architecture that can grow into Live Activities later.

## Product Direction

- Host app first: gallery, widget detail, customization sheets, saved library, and settings
- WidgetKit first: iOS Home Screen widget experiences for `small`, `medium`, and `large`
- Native framework features: `HealthKit`, `WeatherKit`, `CoreLocation`, `EventKit`, `Foundation`, and related Apple APIs
- Design-system-first: semantic light/dark theming, typography roles, spacing, surface styling, and widget size tokens

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
│   └── Extensions/
├── DesignSystem/
├── Widgets/
│   ├── SharedWidgetStyle.swift
│   ├── BatteryBars/
│   ├── StepHealth/
│   ├── PortalWidget/
│   └── DailyDashboard/
└── AbstraktWidgetsExtension/
    ├── AbstraktWidgetsBundle.swift
    ├── AbstraktNewWidgets.swift
    └── Shared/
```

## App Flow

The intended main-app flow is:

1. Browse the widget gallery.
2. Choose a widget and open a customization sheet.
3. Preview the chosen widget size on-device style.
4. Adjust flexible options such as theme mode, font, font weight, gradient, icon set, counters, or per-widget settings.
5. Save that configured widget preset into the Library page.
6. From the Home Screen, the user adds a system widget and selects the saved preset through the widget configuration flow.

This means the app library is the source of truth for saved widget presets, while WidgetKit is the renderer on the Home Screen.

## Current Implementation Snapshot

The current app foundation includes:

- Gallery widget cards with category chips and a preview sheet for the selected widget.
- Preview sheets that render the selected widget, show its display title, and keep the bottom save action in a separate control layer.
- A Library screen grouped by `Small`, `Medium`, and `Large`, with swipeable size tabs, empty states, and cropped/scaled preview rows that hint at the saved widget surface.
- Settings for app font selection, temperature unit, temperature display, distance unit, access/permissions, FAQ, change icon, and release notes.
- Shared settings storage for widget-facing unit preferences and the selected widget font through the App Group.
- Shared widget renderers under `Abstrakt/Widgets/` that are compiled into both the host app and the WidgetKit extension.
- A small Portal Widget preset that combines calendar date context, Denpasar WeatherKit temperature, configurable MiniApp launchers, and App Intent buttons for launching selected system apps.

The app font preference is written to shared storage so Home Screen widgets and in-app previews can render with matching typography. Widget views must stay extension-safe because the WidgetKit target also compiles the shared files under `Abstrakt/Widgets/`.

## System Widget Flow

The iOS widget gallery should expose only the generic `Solid Widget` renderer for the current app direction. It has three supported selections:

- `Small Widget`
- `Medium Widget`
- `Large Widget`

After a user adds one of these widgets to the Home Screen, the system `Edit Widget` sheet exposes a `Current Widget` parameter. That picker must show only saved library presets matching the selected widget size.

## Widget Size Direction

For now the app should focus on iPhone Home Screen sizes only:

- `Small`: default preview target `170x170`
- `Medium`: default preview target `364x170`
- `Large`: default preview target `364x382`

These values are measured fallback sizes and aspect-ratio baselines, not a device-by-device sizing table. In-app previews should fit the available container width while preserving the widget family's measured aspect ratio; WidgetKit widgets should render into the size supplied by the system.

Lock Screen widgets, StandBy layouts, Live Activities, and Dynamic Island remain planned follow-up surfaces, but they are not the primary app flow yet.

## Customization Model

Customization is intentionally flexible:

- Some widgets expose only a few toggles.
- Some widgets open nested sheets such as font pickers.
- Some widgets use inline segmented controls or checkbox-style rows.
- Some widgets support metric-specific settings such as step goals or counters.
- Portal launcher widgets support a six-app MiniApps picker and icon clip styles that are shared with WidgetKit through App Group storage.

Because of that, customization belongs to `App/Configuration/` plus widget-specific configuration sheets inside each widget folder.

Global settings such as temperature unit, temperature display, and distance unit belong to `Core/Settings/` and should be read by both the host app and WidgetKit through extension-safe shared storage. Widget-specific visual choices remain part of the saved preset configuration.

## Widget Naming Direction

- Widget folders should be named after the actual widget entry users browse in the gallery.
- Good names: `ClassicClock`, `TodayMinimal`, `BentoGridOne`, `GradientClock`
- Avoid naming widget folders after raw framework/data sources such as `Clock` or `Calendar`

The underlying data source still belongs in `Core/Services/`, but the widget itself should be named by the user-facing design/preset identity.

## Shared Widget Rendering

Widget visuals should be implemented once under `Abstrakt/Widgets/` and reused by both the host app and `AbstraktWidgetsExtension`.

- `Abstrakt/Widgets/<WidgetName>/` owns the SwiftUI renderer and any render snapshots that are safe for both targets.
- `Abstrakt/Widgets/SharedWidgetStyle.swift` owns extension-safe widget typography, palette, and custom font registration.
- `AbstraktWidgetsExtension/AbstraktNewWidgets.swift` owns WidgetKit timelines, entries, size-slot routing, and App Intent configuration only.
- App-only provider adapters or preview conveniences inside shared widget files must be guarded with `#if !WIDGET_EXTENSION`.

## Core Model Direction

`Core/Models/` is the shared model layer for the app. That is where common types such as widget presets, widget sizes, appearance modes, catalog items, and categories should live.

Not every widget needs its own `Model` or `ViewModel` file. A widget folder should only add local types when it truly has unique configuration or presentation logic that is not shared.

## Documentation Map

Start here when making architecture or product changes:

1. [docs/PROJECT_OVERVIEW.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/PROJECT_OVERVIEW.md)
2. [docs/FEATURE_FRAMEWORK_MATRIX.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/FEATURE_FRAMEWORK_MATRIX.md)
3. [docs/DESIGN_FOUNDATION.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/DESIGN_FOUNDATION.md)
4. [docs/architecture/FOLDER_STRUCTURE.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/architecture/FOLDER_STRUCTURE.md)
5. [docs/product/WIDGET_LIBRARY_FLOW.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/product/WIDGET_LIBRARY_FLOW.md)
