# Abstrakt

Abstrakt is a native SwiftUI app for discovering, configuring, previewing, and saving widget presets before users place them on the iPhone Home Screen. The product is inspired by widget-first apps such as Koco, but it is built around Apple-native frameworks, a simple data layer, and an extension-safe architecture that can grow into Live Activities later.

## Product Direction

- Host app first: gallery, widget detail, customization sheets, saved library, and settings
- WidgetKit first: Home Screen widget experiences for `small`, `medium`, and `large`
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
│   ├── ClassicClock/
│   └── TodayMinimal/
└── WidgetExtension/
    ├── WidgetBundle.swift
    ├── Widgets/
    └── Providers/
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

## Widget Size Direction

For now the app should focus on iPhone Home Screen sizes only:

- `Small`
- `Medium`
- `Large`

Lock Screen widgets, StandBy layouts, Live Activities, and Dynamic Island remain planned follow-up surfaces, but they are not the primary app flow yet.

## Customization Model

Customization is intentionally flexible:

- Some widgets expose only a few toggles.
- Some widgets open nested sheets such as font pickers.
- Some widgets use inline segmented controls or checkbox-style rows.
- Some widgets support metric-specific settings such as step goals or counters.

Because of that, customization belongs to `App/Configuration/` plus widget-specific configuration sheets inside each widget folder.

## Widget Naming Direction

- Widget folders should be named after the actual widget entry users browse in the gallery.
- Good names: `ClassicClock`, `TodayMinimal`, `BentoGridOne`, `GradientClock`
- Avoid naming widget folders after raw framework/data sources such as `Clock` or `Calendar`

The underlying data source still belongs in `Core/Services/`, but the widget itself should be named by the user-facing design/preset identity.

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
