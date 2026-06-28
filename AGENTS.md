# Abstrakt Agent Guide

This repository is a native SwiftUI app, not a reusable library. The product goal is to ship a polished Apple-platform widget ecosystem centered on a main iOS app plus app extensions.

## What Abstrakt Is

- A SwiftUI iOS app used to configure, preview, and manage extensions.
- A WidgetKit extension for Home Screen, Lock Screen, and StandBy widget surfaces.
- A future host for Live Activities and Dynamic Island experiences.
- A design-driven product where reusable layout and theme foundations matter as much as data access.

## Current State

- The codebase is in early foundation stage.
- Existing widget feature folders currently include `Clock` and `Calendar`.
- Shared theme, persistence, and constants files exist but are mostly placeholders.
- Documentation should be treated as the source of intent until implementation catches up.

## Read This First

1. [README.md](/Users/msafdev/Code/swift/CH4_Abstrakt/README.md)
2. [docs/PROJECT_OVERVIEW.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/PROJECT_OVERVIEW.md)
3. [docs/FEATURE_FRAMEWORK_MATRIX.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/FEATURE_FRAMEWORK_MATRIX.md)
4. [docs/DESIGN_FOUNDATION.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/DESIGN_FOUNDATION.md)

## Product Direction

- Start with widgets powered by native Apple frameworks.
- Keep feature boundaries clean so each widget family maps to a clear framework owner.
- Build shared design tokens first: color roles, typography roles, spacing, corner radius, and surface styling.
- Prepare the architecture so Live Activities and Dynamic Island can reuse feature providers and theme primitives later.

## Planned Surfaces

- Main app: onboarding, permissions, feature gallery, customization, previews, settings.
- WidgetKit: Home Screen widgets, Lock Screen widgets, StandBy-compatible layouts.
- ActivityKit: Live Activities and Dynamic Island, planned for a later phase.

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
- Treat widgets and future Live Activities as consumers of shared feature data, not as independent business-logic silos.
- Follow MVVM consistently across the app and extension-facing features.

## MVVM Rules

### Model

- Own domain data, configuration data, timeline payloads, and persistence-friendly structures.
- Keep framework-specific types near the provider layer; prefer app-owned models in feature code.
- Represent empty, denied, loading, and stale states explicitly when a widget can render in those conditions.

### View

- SwiftUI views should focus on composition, styling, and state rendering.
- Views should not talk directly to `EventKit`, `HealthKit`, `CoreLocation`, `WeatherKit`, or persistence APIs.
- Widget views should stay especially lightweight and render precomputed view data whenever possible.

### ViewModel

- Coordinate providers, permission state, formatting, filtering, and view-ready transformation.
- Expose values that are already tailored for rendering, instead of making views assemble business logic.
- Own screen-level and widget-customization behavior, but avoid becoming a dumping ground for persistence and framework code.

### Provider / Service Support

- Shared providers wrap Apple frameworks and feed feature view models.
- Providers are not a replacement for MVVM; they support the ViewModel layer by isolating framework access.
- Permission requests, data fetches, and entitlement-sensitive code should stay behind provider abstractions.

## Folder Intent

```text
Abstrakt/
├── App/                  Main app entry and app-level composition
├── Features/             Product feature modules grouped by surface/use case
├── Shared/               Cross-feature tokens, providers, persistence, constants
└── WidgetExtension/      WidgetKit bundle and widget registrations
```

Recommended feature structure:

```text
Features/
└── <FeatureName>/
    ├── Models/
    ├── ViewModels/
    ├── Views/
    └── Mappers/          Optional, for complex provider-to-view transformations
```

## Documentation Rule

When adding a new feature or extension surface, update:

1. `README.md`
2. `docs/FEATURE_FRAMEWORK_MATRIX.md`
3. `docs/DESIGN_FOUNDATION.md` if the feature introduces a new size, layout rule, or styling pattern
