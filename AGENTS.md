# Abstrakt Agent Guide

This repository is a native SwiftUI app, not a reusable library. The product goal is to ship a polished Apple-platform widget ecosystem centered on a main iOS app plus app extensions.

## What Abstrakt Is

- A SwiftUI iOS app used to configure, preview, and manage extensions.
- A WidgetKit extension for Home Screen, Lock Screen, and StandBy widget surfaces.
- An ActivityKit host for Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity experiences.
- A design-driven product where reusable layout and theme foundations matter as much as data access.

## Current State

- The codebase is in active product iteration.
- Existing widget folders include `Battery`, `Steps`, `Activity`, `Calendar`, `Events`, `Portal`, `Reminder`, `Sleep`, `Storage`, `Today`, `Weather`, `Daylight`, and `HeartRate`.
- Live Activity code is split by ActivityKit state under `Abstrakt/LiveActivities/SmartPills`, `Expanded`, `LiveActivity`, and `Shared`.
- Shared theme, persistence, constants, services, widget-size tokens, and activity typography are part of the product contract.
- Documentation should stay current with implementation whenever a feature or structure changes.

## Read This First

1. [README.md](/Users/msafdev/Code/swift/Abstrakt/README.md)
2. [docs/PROJECT_OVERVIEW.md](/Users/msafdev/Code/swift/Abstrakt/docs/PROJECT_OVERVIEW.md)
3. [docs/FEATURE_FRAMEWORK_MATRIX.md](/Users/msafdev/Code/swift/Abstrakt/docs/FEATURE_FRAMEWORK_MATRIX.md)
4. [docs/DESIGN_FOUNDATION.md](/Users/msafdev/Code/swift/Abstrakt/docs/DESIGN_FOUNDATION.md)
5. [docs/architecture/FOLDER_STRUCTURE.md](/Users/msafdev/Code/swift/Abstrakt/docs/architecture/FOLDER_STRUCTURE.md)

## Product Direction

- Start with widgets powered by native Apple frameworks.
- Keep feature boundaries clean so each widget family maps to a clear framework owner.
- Build shared design tokens first: color roles, typography roles, spacing, corner radius, and surface styling.
- Reuse provider-backed data across widgets, Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity surfaces.

## Supported Surfaces

- Main app: onboarding, permissions, feature gallery, customization, previews, settings.
- WidgetKit: Home Screen widgets, Lock Screen widgets, StandBy-compatible layouts.
- ActivityKit: Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity states.

## Feature Rule

Each feature should clearly document:

- User-facing purpose
- Backing Apple framework(s)
- Permission requirements
- Data freshness expectations
- Supported surfaces and sizes
- Fallback behavior when permission or data is unavailable

Use the feature matrix in `docs/FEATURE_FRAMEWORK_MATRIX.md` as the canonical mapping.

## Architectural Expectations

- Prefer modern SwiftUI patterns and native frameworks.
- Keep UI code in SwiftUI, feature logic in feature folders, and framework access behind shared providers.
- Use App Groups for extension-safe shared data.
- Treat widgets and Live Activities as consumers of shared feature data, not as independent business-logic silos.
- Keep screens consistent with the existing app structure. Avoid adding screen-local `ViewModel` files unless that pattern already exists for the same area and the state is too complex for a focused screen/service split.
- Runtime widgets and in-app widget previews should use provider data, App Group cached values, or explicit empty/permission states. Keep static sample metrics limited to Xcode canvas previews.
- Runtime Live Activities should use `Core/Services/LiveActivities` view data or explicit add/empty states. Keep static ActivityKit sample metrics limited to Xcode canvas previews.
- Live Activity files use `Activity` naming; app screens use `Screen`; bottom-sheet pickers live in `App/Configuration/Sheets`.
- Signing and App Group setup is config-driven. Keep `APP_GROUP_ID` in `Signing.xcconfig`/local overrides aligned with both app and widget extension entitlements.

## MVVM Rules

### Model

- Own domain data, configuration data, timeline payloads, and persistence-friendly structures.
- Keep framework-specific types near the provider layer; prefer app-owned models in feature code.
- Represent empty, denied, loading, and stale states explicitly when a widget can render in those conditions.

### View

- SwiftUI views should focus on composition, styling, and state rendering.
- Views should not talk directly to `EventKit`, `HealthKit`, `CoreLocation`, `WeatherKit`, or persistence APIs.
- Widget views should stay especially lightweight and render precomputed view data whenever possible.

### Screen State / ViewModel

- Coordinate providers, permission state, formatting, filtering, and view-ready transformation.
- Expose values that are already tailored for rendering, instead of making views assemble business logic.
- Own screen-level and widget-customization behavior, but avoid becoming a dumping ground for persistence and framework code.
- Prefer shared services for cross-surface state such as live activity selections and App Group-backed settings.

### Provider / Service Support

- Shared providers wrap Apple frameworks and feed feature view models.
- Providers are not a replacement for MVVM; they support the ViewModel layer by isolating framework access.
- Permission requests, data fetches, and entitlement-sensitive code should stay behind provider abstractions.

## Permission Handling

- Saving a widget in the app's Gallery triggers the associated system permission prompt (HealthKit, CoreLocation, EventKit) only when the user chooses to save.
- If the user accepts the prompt, the widget is saved and its data is fetched immediately.
- If the user declines the prompt, saving is blocked and a warning alert is shown; tapping Save again attempts the system prompt again where iOS allows it, or opens Settings for permanently denied permissions.
- **HealthKit Privacy Exception**: Due to Apple's privacy guidelines for HealthKit, apps cannot programmatically verify if a user granted or denied read access (it always appears as `.notDetermined` unless explicitly requested). Therefore, Health-dependent widgets treat `.requested` as the highest verifiable permission level, and allow saving if the prompt was requested. Blocking `.requested` would permanently prevent users from ever saving a Health widget.

## Folder Intent

```text
Abstrakt/
├── App/                       Main app entry, screens, components, and configuration
├── Core/                      App-owned models, services, storage, and constants
├── DesignSystem/              Cross-feature tokens for color, type, spacing, radius, and widget sizes
├── Widgets/                   User-facing widget preview/rendering folders
├── LiveActivities/            ActivityKit renderers split by SmartPills, Expanded, LiveActivity, and Shared
└── AbstraktWidgetsExtension/  WidgetKit bundle, widget registrations, intents, and shared extension data
```

Recommended feature structure:

```text
Widgets/
└── <FeatureName>/
    ├── Models/
    ├── ViewModels/
    ├── Views/
    └── Mappers/          Optional, for complex provider-to-view transformations
```

Recommended Live Activity structure:

```text
LiveActivities/
├── DynamicIslandActivity.swift
├── SmartPills/
├── Expanded/
├── LiveActivity/
└── Shared/
```

`SmartPills`, `Expanded`, and `LiveActivity` represent ActivityKit states, not generic screens. Avoid names like `WIP`, `Page`, or `View` for these renderers when `Screen` or `Activity` is the real role.

## Documentation Rule

When adding a new feature or extension surface, update:

1. `README.md`
2. `docs/FEATURE_FRAMEWORK_MATRIX.md`
3. `docs/DESIGN_FOUNDATION.md` if the feature introduces a new size, layout rule, or styling pattern
4. `docs/architecture/FOLDER_STRUCTURE.md` if files, folders, or naming rules changed
5. `docs/PROJECT_OVERVIEW.md` when product flow or supported surfaces change
