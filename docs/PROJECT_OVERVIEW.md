# Project Overview

## Summary

Abstrakt is a SwiftUI iOS app that manages a collection of usable Apple system extensions, starting with widgets and expanding toward Live Activities and Dynamic Island. The main app exists to configure, personalize, preview, and permission-gate those surfaces.

## Product Shape

- Host app: the control center for setup, data permissions, previews, and style customization
- Widget extension: the first shipping extension target
- Future extension targets: Live Activities and Dynamic Island

## Near-Term Priorities

- Establish a stable shared design system for extension-friendly layouts
- Build feature modules for Apple-native information surfaces
- Define permission and framework boundaries early
- Keep data providers reusable across widgets and future ActivityKit surfaces

## Feature Families

- Battery
- Health Info
- Calendar
- Reminder
- Location
- Health
- Time
- Weather

More feature families can be added later if they fit the same "usable glanceable system info" direction.

## Recommended Module Direction

```text
Abstrakt/
├── App/
│   ├── Launch/
│   ├── Onboarding/
│   ├── Permissions/
│   ├── Gallery/
│   ├── Customization/
│   └── Settings/
├── Features/
│   ├── Battery/
│   ├── Calendar/
│   ├── Health/
│   ├── Location/
│   ├── Reminder/
│   ├── Time/
│   └── Weather/
├── Shared/
│   ├── Constants/
│   ├── DataProviders/
│   ├── Persistence/
│   ├── Theme/
│   └── Utilities/
└── WidgetExtension/
```

## Data Ownership Direction

- The main app should own permission flows, feature setup, previews, and user customization.
- Shared providers should wrap Apple frameworks and expose extension-safe models.
- Widgets should render lightweight timeline entries from shared or precomputed data.
- Future Live Activities should reuse the same feature models where possible, with ActivityKit-specific state layered on top.

## Shared Systems To Establish Early

- Design tokens for color, typography, spacing, radius, stroke, shadows, and materials
- A shared widget layout vocabulary for small, medium, large, and accessory sizes
- App Group-backed storage for extension-readable configuration
- A permissions strategy per framework
- Placeholder and empty-state rules for data-denied or data-unavailable scenarios

## Risk Areas

- HealthKit and WeatherKit require extra entitlement and permission planning
- EventKit behavior differs between calendars and reminders, even though both live in EventKit
- Core Location should be minimized in widgets to protect battery and timeline performance
- Widget layouts must stay legible across size classes, lock screen contexts, and color schemes

