# Project Overview

## Summary

Abstrakt is a SwiftUI iOS app that helps users build a personal library of saved widget presets and configure ActivityKit-based Dynamic Island surfaces. On first launch, users move through onboarding, then browse a gallery, preview and save Home Screen widget presets, or open the Live Activity screen to choose Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity items.

## Product Shape

- Host app: discovery, previews, configuration sheets, saved library, permissions, and settings
- First-launch onboarding: welcome, widget tutorial, and an optional permissions step before entering the main app shell
- Widget extension: exposes three size-based `Solid Widget` renderers and renders saved presets on the Home Screen
- Shared render layer: widget visuals live under `Abstrakt/Widgets/` and are compiled into both the host app and WidgetKit extension
- ActivityKit layer: Live Activity visuals live under `Abstrakt/LiveActivities/` and are split by `SmartPills`, `Expanded`, `LiveActivity`, and `Shared`
- Runtime data flow: host-app providers refresh battery, Health, calendar/date, time, storage, and WeatherKit data into App Group storage for WidgetKit; in-app previews use provider/cache values instead of sample numbers
- Design system: app surfaces use the concrete `AppColors` roles documented in `DESIGN_FOUNDATION.md`, including filled `card`/`cardSoft` surfaces, app appearance preferences, and `accentPurple` (`#615FFF`) for primary branded actions
- Localization flow: app strings live in `Localizable.xcstrings`, while `LocalizationManager` lets users choose System, English, Indonesian, Spanish, or Portuguese-Brazil from Settings
- Future surfaces: richer Lock Screen widgets and StandBy variants once the core widget and ActivityKit flows are stable

## Near-Term Priorities

- Continue refining the app structure around screens under `App/Screens/`
- Keep widget entries cleanly separated under `Widgets/`
- Keep ActivityKit renderers cleanly separated under `LiveActivities/` by state, not by temporary UI implementation names
- Keep app-owned core models for saved widget presets and per-widget configuration
- Build service boundaries around Apple-native frameworks
- Keep static fixture values out of runtime widget rendering; use provider data, cached App Group values, or explicit empty/permission states instead
- Keep static fixture values out of runtime Live Activities; use `Core/Services/LiveActivities` data or explicit add/empty states instead
- Keep portal-style app launchers configurable through the host app, backed by App Intents, with framework data still fetched by host-app providers and cached for WidgetKit.
- Keep Weather and Daylight backed by WeatherKit/CoreLocation in the host app, with widget-safe snapshots cached into the shared App Group.
- Keep light, dark, and system appearance modes first-class in both previews and saved configuration
- Keep global app preferences, such as units and app font, separate from widget-specific saved preset styling
- Keep localization keys in the string catalog and route user-facing strings through the localization helpers rather than hard-coding screen copy
- Keep app-only personalization, such as alternate app icons, out of widget-extension code paths

## Core User Experience

The current core flow looks like this:

```text
Onboarding (first launch)
  ↓
Gallery / Main App Shell
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

- First launch is gated by onboarding through `hasCompletedOnboarding`.
- Users choose between `Small`, `Medium`, and `Large` for Home Screen placement.
- The iOS widget gallery exposes `Solid Widget` with `Small Widget`, `Medium Widget`, and `Large Widget` slots.
- The system saved-widget picker must filter saved presets by the selected slot's size.
- Not every widget needs the same settings.
- Some settings should be inline in the first sheet.
- Some settings should push or open a second sheet, such as font selection.
- The saved Library should group presets by widget size so users understand what is ready to place.
- Library tabs should be swipeable as well as tappable, with size counts kept visible in the tab chips.
- Gallery category chips should come from active `WidgetCatalog` categories, so framework-backed groups such as `HealthKit`, `WeatherKit`, `EventKit`, `Foundation`, `UIKit`, and `Portal` are discoverable without maintaining a separate chip list.
- Library rows should crop the widget preview under the row divider instead of shrinking the design into a tiny thumbnail.
- Preview sheets should use a full-width bottom sheet treatment with a drag indicator, title metadata below the rendered widget, and a bottom save action separated from the widget preview layer.
- Settings should expose app language, app font, alternate app icon, unit preferences, permissions, FAQ, sharing, and release notes without mixing those global preferences into per-widget configuration.
- Settings should expose Appearance as a first-class app preference, while Home Screen widget appearance and Live Activity glass/solid styling remain surface-specific.
- The main tab shell currently includes `Home`, `Gallery`, `Live Activity`, `Settings`, and an overlaid `Library`; Gallery, Library, Settings, and Live Activity carry the primary product flow.
- Unit preferences should use compact picker/menu controls from Settings and persist through shared storage for widget rendering.
- App font changes should persist to shared storage and reload WidgetKit timelines so in-app previews and Home Screen widgets use the same selected typography.
- App language changes should persist through shared settings, update visible strings, and reload timelines when widget-visible strings may change.
- Portal launcher MiniApp selection and icon clip style should persist to shared storage and reload WidgetKit timelines so the Home Screen renderer matches the in-app preview.
- Signing and App Group setup should remain config-driven through `Signing.xcconfig` plus optional local overrides, with app and extension entitlements sharing the same `APP_GROUP_ID`.

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
│   ├── Localization/
│   └── Extensions/
├── DesignSystem/
├── Widgets/
│   ├── SharedWidgetStyle.swift
│   └── <WidgetName>/
├── LiveActivities/
│   ├── DynamicIslandActivity.swift
│   ├── SmartPills/
│   ├── Expanded/
│   ├── LiveActivity/
│   └── Shared/
└── AbstraktWidgetsExtension/
```

## Shared Data Ownership

- The host app owns gallery state, customization state, permission messaging, and saved widget presets.
- `Core/Storage/` should hold saved preset storage abstractions.
- `Core/Settings/` should hold shared preference types for app and widget surfaces, such as temperature unit, temperature display, and distance unit.
- `Core/Localization/` should hold runtime localization helpers and language state; screens should use localized keys rather than hard-coded user-facing strings.
- `AbstraktWidgetsExtension/` should consume saved configuration data and route WidgetKit entries into shared widget renderers rather than owning duplicate visual implementations.
- Widget-specific folders should define their render snapshots and SwiftUI views in an extension-safe way. App-only provider adapters can live beside those views behind `#if !WIDGET_EXTENSION`.
- `LiveActivities/` should consume activity view data from `Core/Services/LiveActivities/` and shared feature providers. ActivityKit views should not invent static runtime values.
- Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity can choose different items, but they share one ActivityKit activity and one enabled toggle because iOS does not expose independent enablement per ActivityKit state.
- Interactive widget buttons should use App Intents available to the widget extension. Framework-backed data such as WeatherKit still flows through the host app and App Group storage.

## Implementation Contract

- Provider-backed data is the default. The app should map framework snapshots into render-safe widget and activity data before extension surfaces consume it.
- Preview and runtime surfaces should share renderers. If the app preview and the actual phone surface drift, fix the shared renderer/metrics rather than adding one-off preview-only values.
- ActivityKit has three user-visible states: Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity. These states can choose different items, but unselected states render the explicit add/empty state instead of falling back to another state's chosen item.
- Lock Screen Live Activity visual mode is either `Glass` or `Solid`. That mode is independent from Settings Appearance and should not affect Smart Pills, expanded Dynamic Island, or Home Screen widgets.
- Settings Appearance controls the host app's preferred color scheme. Home Screen widget appearance remains widget/preset specific, and ActivityKit surfaces keep their own black/glass treatment.
- Haptics are part of the interaction contract for primary buttons, bottom navigation, library/gallery sheets, Live Activity mode changes, and item selection.
- Onboarding/tutorial illustration fades should use `AppColors.appBackground` so light and dark modes blend into the real app canvas.

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

## Data & Permission Strategy

- The host app keeps framework-backed refresh work gated by saved presets. `ContentView` refreshes only the providers whose frameworks appear in the saved widget presets and starts always-on refresh loops only when at least one preset exists.
- The first-launch onboarding flow now includes an optional permissions page with dedicated request actions for Health, Weather/Location, and Calendar access.
- The preview sheet still acts as the save-time fallback. If a required permission was skipped during onboarding or remains undetermined, the Save action requests it before writing the preset.
- Widgets are expected to render explicit empty, denied, and loading states while they wait for cached App Group data.

## Surface Direction

The same feature and provider system now supports:

- Home Screen widgets through WidgetKit
- Smart Pills through ActivityKit compact Dynamic Island regions
- Expanded Dynamic Island activity surfaces
- Lock Screen and notification Live Activities

Future expansion should focus on:

- Lock Screen widget variants
- StandBy-appropriate layouts

Every expansion should reuse the same preset, theme, and service foundations wherever possible.
