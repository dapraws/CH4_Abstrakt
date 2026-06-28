# Design Foundation

This document defines the UI foundation for Abstrakt across the main app, widget previews, and the Home Screen widget extension.

## Design Goals

- Glanceable in widget sizes
- High contrast in both light and dark environments
- Flexible enough for widget-specific customization
- Consistent between app previews and actual WidgetKit rendering
- Strong enough to support a library of saved presets rather than one-off widget screens

## Appearance Modes

Every configurable widget should support appearance choices where relevant:

- `System`
- `Light`
- `Dark`

Rules:

- `System` follows the current device context.
- `Light` and `Dark` must preview deterministically inside the app sheet even if the app itself is running in another appearance.
- Saved presets should persist the appearance choice as part of widget configuration when the widget supports it.

## Semantic Color Roles

Start from roles, not hard-coded values.

- `background.app`
- `background.sheet`
- `background.preview`
- `surface.primary`
- `surface.secondary`
- `surface.selected`
- `content.primary`
- `content.secondary`
- `content.tertiary`
- `accent.primary`
- `accent.secondary`
- `border.subtle`
- `border.focus`
- `state.positive`
- `state.warning`
- `state.critical`

## Typography Roles

The app needs two kinds of typography tokens:

### Semantic UI Roles

- `display`
- `title`
- `headline`
- `body`
- `caption`
- `micro`

### Widget Style Roles

These represent user-selectable visual families when a widget supports font customization:

- `Default`
- `Round`
- `Serif`
- `Mono`
- `Pixel`
- Additional families can be added later per widget or globally

User-selected font families should map back into shared typography tokens instead of being scattered in view code.

## Layout Foundation

### Home Screen Sizes

| Size | Use |
|---|---|
| `Small` | One focal metric or compact message |
| `Medium` | One main metric plus supporting context |
| `Large` | Multi-block composition or richer supporting content |

For now these are the core shipping sizes for the app flow and library organization.

### Customization Sheet Pattern

The app customization experience should support:

- A top widget preview
- Inline segmented choices such as appearance mode
- Tap-to-open rows for nested pickers such as font selection
- Checkbox or tile-style choices for style presets
- A primary save or try action at the bottom

This is intentionally a flexible pattern, because not every widget needs the same control set.

## Library Page Pattern

Saved presets should be grouped by widget size:

- `Small`
- `Medium`
- `Large`

Each library item should clearly communicate:

- Widget family
- Style or preset name
- Optional badge such as `Pro`, category, or configuration variant
- A preview that resembles the actual Home Screen widget

## Widget State Rules

Every widget family should plan for:

- Loaded state
- Empty state
- Permission denied state
- Stale-data state

These should be designed at the same level as the happy path, especially for framework-backed widgets.

## Recommended Token Families

```text
DesignSystem/
├── AppColors.swift
├── AppFonts.swift
├── AppSpacing.swift
├── AppRadius.swift
└── WidgetAppearanceTokens.swift
```

Likely concrete files over time:

- `AppColors.swift`
- `WidgetAppearanceTokens.swift`
- `AppFonts.swift`
- `WidgetFontCatalog.swift`
- `AppSpacing.swift`
- `AppRadius.swift`
- `WidgetSizeTokens.swift`
- `SurfaceStyles.swift`

## Preview Requirements

Each widget preview should be validated in:

- `Small`, `Medium`, and `Large` where supported
- `System`, `Light`, and `Dark` appearance variants where supported
- Empty and permission-denied states for framework-backed widgets
- At least one saved-library card presentation
