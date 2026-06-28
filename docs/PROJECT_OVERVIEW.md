# Project Overview

## Summary

Abstrakt is a SwiftUI iOS app that helps users build a personal library of saved widget presets. Users browse a gallery, open a widget detail/customization flow, preview the widget in a selected Home Screen size, then save that preset into a Library page that later feeds WidgetKit configuration.

## Product Shape

- Host app: discovery, previews, configuration sheets, saved library, permissions, and settings
- Widget extension: renders the actual Home Screen widget surfaces
- Future surfaces: Lock Screen widgets, StandBy, Live Activities, and Dynamic Island

## Near-Term Priorities

- Refine the app structure around screens under `App/Screens/`
- Keep widget entries cleanly separated under `Widgets/`
- Establish app-owned core models for saved widget presets and per-widget configuration
- Build service boundaries around Apple-native frameworks
- Make light, dark, and system appearance modes first-class in both previews and saved configuration

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
- Not every widget needs the same settings.
- Some settings should be inline in the first sheet.
- Some settings should push or open a second sheet, such as font selection.
- The saved Library should group presets by widget size so users understand what is ready to place.

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
│   └── <WidgetName>/
└── WidgetExtension/
```

## Shared Data Ownership

- The host app owns gallery state, customization state, permission messaging, and saved widget presets.
- `Core/Storage/` should hold saved preset storage abstractions.
- `WidgetExtension/` should consume saved configuration data rather than inventing its own parallel model layer.
- Widget-specific folders should define their own configurable views only when needed, but serialize into app-owned preset models.

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
