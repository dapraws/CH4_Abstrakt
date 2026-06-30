# Project Overview

## Summary

Abstrakt is a SwiftUI iOS app that helps users build a personal library of saved widget presets. Users browse a gallery, open a widget detail/customization flow, preview the widget in a selected Home Screen size, then save that preset into a Library page that later feeds WidgetKit configuration.

## Product Shape

- Host app: discovery, previews, configuration sheets, saved library, permissions, and settings
- Widget extension: exposes three size-based `Solid Widget` renderers and renders saved presets on the Home Screen
- Shared render layer: widget visuals live under `Abstrakt/Widgets/` and are compiled into both the host app and WidgetKit extension
- Future surfaces: Lock Screen widgets, StandBy, Live Activities, and Dynamic Island

## Near-Term Priorities

- Continue refining the app structure around screens under `App/Screens/`
- Keep widget entries cleanly separated under `Widgets/`
- Keep app-owned core models for saved widget presets and per-widget configuration
- Build service boundaries around Apple-native frameworks
- Keep portal-style app launchers backed by App Intents, with framework data still fetched by host-app providers and cached for WidgetKit.
- Keep light, dark, and system appearance modes first-class in both previews and saved configuration
- Keep global app preferences, such as units and app font, separate from widget-specific saved preset styling

## Core User Experience

The core flow should look like this:

```text
Gallery
  ↓
Widget Detail / Preview Sheet
  ↓
Optional Nested Customization Sheet(s)
  ↓
Save Preset To Library
  ↓
WidgetKit Selection On Home Screen
```

Important UX constraints:

- Users choose between `Small`, `Medium`, and `Large` for Home Screen placement.
- The iOS widget gallery exposes `Solid Widget` with `Small Widget`, `Medium Widget`, and `Large Widget` slots.
- The system `Current Widget` picker must filter saved presets by the selected slot's size.
- Not every widget needs the same settings.
- Some settings should be inline in the first sheet.
- Some settings should push or open a second sheet, such as font selection.
- The saved Library should group presets by widget size so users understand what is ready to place.
- Library tabs should be swipeable as well as tappable, with size counts kept visible in the tab chips.
- Library rows should crop the widget preview under the row divider instead of shrinking the design into a tiny thumbnail.
- Preview sheets should use a full-width bottom sheet treatment with a drag indicator, title metadata below the rendered widget, and a bottom save action separated from the widget preview layer.
- Unit preferences should use compact picker/menu controls from Settings and persist through shared storage for widget rendering.
- App font changes should persist to shared storage and reload WidgetKit timelines so in-app previews and Home Screen widgets use the same selected typography.

## Recommended Module Direction

```text
Abstrakt/
├── App/
│   ├── AbstraktApp.swift
│   └── ContentView.swift
│   ├── Screens/
│   ├── Components/
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
│   └── <WidgetName>/
└── WidgetExtension/
```

## Shared Data Ownership

- The host app owns gallery state, customization state, permission messaging, and saved widget presets.
- `Core/Storage/` should hold saved preset storage abstractions.
- `Core/Settings/` should hold shared preference types for app and widget surfaces, such as temperature unit, temperature display, and distance unit.
- `WidgetExtension/` should consume saved configuration data and route WidgetKit entries into shared widget renderers rather than owning duplicate visual implementations.
- Widget-specific folders should define their render snapshots and SwiftUI views in an extension-safe way. App-only provider adapters can live beside those views behind `#if !WIDGET_EXTENSION`.
- Interactive widget buttons should use App Intents available to the widget extension. Framework-backed data such as WeatherKit still flows through the host app and App Group storage.

## MVVM Architecture

### Model

- Widget metadata
- Saved preset payloads
- Per-widget configuration values
- Permission and availability states
- Preview payloads that are safe for both app and widget surfaces

These shared types belong in `Core/Models/`. They are closer to TypeScript domain/types files than widget-local screen models.

### ViewModel

- Coordinates services, configuration state, validation, formatting, and preview updates
- Decides which customization controls are visible for a given widget
- Maps framework-backed data into widget-preview-ready state

Not every widget needs a dedicated view model. Add one only when the widget has enough unique state or transformation logic to justify it.

### View

- Renders the gallery, preview sheets, customization components, and library lists
- Remains focused on layout, state rendering, and design tokens
- Does not directly fetch `HealthKit`, `WeatherKit`, `CoreLocation`, or `EventKit`
- Widget render views under `Abstrakt/Widgets/` must avoid app-only dependencies unless guarded, because the extension target compiles those files too.

### Service Layer

- Wraps Apple frameworks behind extension-safe models
- Handles permissions, freshness, caching, and framework-specific translation

## Future Surface Direction

Once the Home Screen widget flow is stable, the same feature and preset system should expand to:

- Lock Screen widget variants
- StandBy-appropriate layouts
- Live Activities backed by `ActivityKit`
- Dynamic Island compact and expanded states

That expansion should reuse the same preset, theme, and service foundations wherever possible.
