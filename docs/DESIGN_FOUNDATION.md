# Design Foundation

This document defines the initial UI foundation for Abstrakt across the main app and Apple extension surfaces.

## Design Goals

- Glanceable at small sizes
- Strong visual hierarchy with minimal text
- High contrast in both light and dark mode
- Easy to theme without breaking readability
- Consistent between app previews and real widget rendering

## Color System

Define semantic color roles first, then map those roles to concrete light and dark values.

### Core Roles

- `background.primary`
- `background.secondary`
- `surface.primary`
- `surface.elevated`
- `content.primary`
- `content.secondary`
- `content.tertiary`
- `accent.primary`
- `accent.secondary`
- `positive`
- `warning`
- `critical`
- `border.subtle`
- `border.strong`

### Light Mode Direction

- Backgrounds should stay bright but not pure white-heavy.
- Elevated surfaces can use soft neutral tinting to avoid a sterile look.
- Accent colors should remain saturated enough to survive widget blur and wallpaper noise.

### Dark Mode Direction

- Prefer layered charcoal and graphite surfaces over flat black everywhere.
- Maintain stronger separation between background, card, and accent elements.
- Avoid low-contrast gray-on-gray text for glanceable content.

## Typography Roles

Prefer semantic roles over one-off font calls.

- `display`
- `title`
- `headline`
- `body`
- `caption`
- `metric`
- `micro`

## Layout Principles

- Prioritize one focal metric or message per widget.
- Use stacked information density: primary metric first, secondary context second, decoration last.
- Keep padding generous enough for rounded-corner clipping and wallpaper noise.
- Avoid relying on long labels in small and accessory widgets.
- Design empty, loading, and permission-denied states as first-class layouts.

## Widget Sizes

Use these sizes as the default design reference.

### Home Screen Widgets

| Size | Points |
|---|---|
| Small | `170 x 170` |
| Medium | `360 x 170` |
| Large | `360 x 376` |

### Lock Screen / Accessory Widgets

| Type | Guidance |
|---|---|
| Inline | Single-line text, status, or compact summary |
| Circular | One metric, ring, icon, or time-centric presentation |
| Rectangular | Two-level hierarchy with title plus key data |

### Future Activity Surfaces

| Surface | Guidance |
|---|---|
| Live Activity | Compact status + evolving progress/state |
| Dynamic Island Compact | Extremely condensed icon + metric |
| Dynamic Island Minimal | Single symbol or single value |
| Dynamic Island Expanded | Multi-region summary using ActivityKit regions |

## Widget Composition Pattern

Every widget layout should define:

- Primary content
- Supporting content
- Accent treatment
- Background treatment
- Empty state
- Permission-denied state

## Best Practices

- Use semantic colors, not hard-coded per-widget colors in view bodies.
- Build widget-specific layout presets on top of shared spacing and radius tokens.
- Keep text count low in small sizes.
- Test every design in light mode, dark mode, and tinted wallpaper conditions.
- Prefer vector-safe SF Symbols and minimal ornamentation in accessory sizes.
- Ensure health, weather, and calendar widgets all remain useful with stale or partial data.

## Recommended Token Families

```text
Shared/Theme/
├── Colors.swift
├── Typography.swift
├── Spacing.swift
├── Radius.swift
├── Shadows.swift
└── WidgetLayoutTokens.swift
```

## Preview Requirements

Every new widget or extension surface should be previewed in:

- Light mode
- Dark mode
- Smallest supported size
- Largest supported size
- Empty state
- Denied permission state

## Extension-Specific Notes

- Widget layouts should avoid deep navigation assumptions.
- Lock screen and future Dynamic Island views must be even more compact than Home Screen widgets.
- Live Activity designs should reuse the same color and type roles, but optimize for continuous status updates rather than static snapshots.

