# Abstrakt

Abstrakt is a native SwiftUI app for building and managing usable Apple extension experiences, starting with widgets and expanding toward Live Activities and Dynamic Island.

## What This Project Is

- A SwiftUI iOS app
- A WidgetKit-based extension ecosystem
- A design-system-first foundation for glanceable utility surfaces
- Not a reusable Swift package or library

## Current Focus

The repository is currently laying down the product foundation:

- Main app shell
- Widget extension structure
- Early `Clock` and `Calendar` widget modules
- Shared theme and data-provider placeholders
- Documentation that defines the intended architecture and design system

## Planned Feature Families

Each feature should map cleanly to a native Apple framework.

| Feature | Primary Framework |
|---|---|
| Battery | `UIKit` (`UIDevice`) |
| Health Info | `HealthKit` |
| Calendar | `EventKit` |
| Reminder | `EventKit` |
| Location | `CoreLocation` |
| Health | `HealthKit` |
| Time | `Foundation` |
| Weather | `WeatherKit` |

See [docs/FEATURE_FRAMEWORK_MATRIX.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/FEATURE_FRAMEWORK_MATRIX.md) for the full framework map, permission expectations, and implementation notes.

## Surfaces

### Shipping Now

- Home Screen widgets
- Lock Screen widgets
- Main app configuration and preview experience

### Planned

- Live Activities via `ActivityKit`
- Dynamic Island experiences for supported devices
- Additional extension surfaces as the product grows

## Widget Size Foundation

Current reference sizes for Home Screen widgets:

| Size | Points |
|---|---|
| Small | `170 x 170` |
| Medium | `360 x 170` |
| Large | `360 x 376` |

Lock Screen and future activity surfaces are documented in [docs/DESIGN_FOUNDATION.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/DESIGN_FOUNDATION.md).

## Architecture Direction

```text
Abstrakt/
├── App/                  App entry and future app flows
├── Features/             Feature modules and widget views
├── Shared/               Theme, providers, persistence, constants
└── WidgetExtension/      WidgetKit bundle and widget registration
```

Guiding principles:

- Keep feature data access behind shared framework-specific providers
- Use App Groups for extension-readable shared state
- Keep widgets lightweight and rendering-focused
- Reuse feature models later for Live Activities and Dynamic Island

## Design Foundation

Abstrakt should ship with a shared design language across app and extensions:

- Semantic colors for light and dark mode
- Shared typography roles
- Reusable widget layout tokens
- Clear empty, loading, and denied-permission states

See [docs/DESIGN_FOUNDATION.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/DESIGN_FOUNDATION.md) for the initial design rules.

## Agent-Friendly Documentation

If you are onboarding into the repository, start with:

1. [AGENTS.md](/Users/msafdev/Code/swift/CH4_Abstrakt/AGENTS.md)
2. [docs/PROJECT_OVERVIEW.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/PROJECT_OVERVIEW.md)
3. [docs/FEATURE_FRAMEWORK_MATRIX.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/FEATURE_FRAMEWORK_MATRIX.md)
4. [docs/DESIGN_FOUNDATION.md](/Users/msafdev/Code/swift/CH4_Abstrakt/docs/DESIGN_FOUNDATION.md)

## Getting Started

1. Open `Abstrakt.xcodeproj` in Xcode.
2. Set up signing in [Abstrakt/Config/Signing.xcconfig](/Users/msafdev/Code/swift/CH4_Abstrakt/Abstrakt/Config/Signing.xcconfig).
3. Build the app target and widget extension target together.
4. Use the documentation above as the current source of truth for architecture and feature direction.

## Recommended Next Implementation Steps

1. Establish shared theme tokens in `Shared/Theme/`.
2. Add provider modules for the planned Apple frameworks.
3. Flesh out the widget bundle registration.
4. Replace the placeholder `ContentView` with a feature gallery or extension dashboard.
5. Add preview coverage for widget sizes, color schemes, and permission states.
