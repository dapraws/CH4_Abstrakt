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
- `heading1`
- `heading2`
- `heading3`
- `body`
- `subBody`
- `caption`
- `meta`
- `chip`
- `tab`
- `iconBadge`

### Widget Style Roles

Widgets use the same semantic sizing model, but each widget chooses its own font theme explicitly instead of inheriting the app preference. This keeps app settings from unexpectedly changing installed widget layouts.

- `widgetDisplay`
- `widgetTitle`
- `widgetHeading`
- `widgetBody`
- `widgetCaption`
- `widgetMeta`

The app font picker currently exposes `SF Pro`, `SF Pro Rounded`, `Quicksand`, and `Fusion Pixel`. Pixel fonts use smaller token sizes and tighter line spacing so multiline layouts remain visually comparable across font themes.

Rules:

- Use `AppFonts` token roles for host-app UI instead of static font sizes.
- Use `WidgetFonts` or explicit widget font themes for WidgetKit and rendered widget previews.
- Bottom bar icon sizing should stay stable and must not change based on the selected app font.
- App font changes should update visible app rows immediately without requiring a screen refresh.

## Layout Foundation

### iOS Widget Dimension Matrix

Abstrakt is currently focused on iPhone widget design. Use these point sizes as the canonical dimensions for app previews, WidgetKit rendering checks, and size-specific layout decisions.

| Screen Size (Portrait, pt) | Small (pt) | Medium (pt) | Large (pt) | Circular (pt) | Rectangular (pt) | Inline (pt) |
| -------------------------: | ---------: | ----------: | ---------: | ------------: | ---------------: | ----------: |
|                    430x932 |    170x170 |     364x170 |    364x382 |         76x76 |           172x76 |      257x26 |
|                    428x926 |    170x170 |     364x170 |    364x382 |         76x76 |           172x76 |      257x26 |
|                    414x896 |    169x169 |     360x169 |    360x379 |         76x76 |           160x72 |      248x26 |
|                    414x736 |    159x159 |     348x157 |    348x357 |         76x76 |           170x76 |      248x26 |
|                    393x852 |    158x158 |     338x158 |    338x354 |         72x72 |           160x72 |      234x26 |
|                    390x844 |    158x158 |     338x158 |    338x354 |         72x72 |           160x72 |      234x26 |
|                    375x812 |    155x155 |     329x155 |    329x345 |         72x72 |           157x72 |      225x26 |
|                    375x667 |    148x148 |     321x148 |    321x324 |         68x68 |           153x68 |      225x26 |
|                    360x780 |    155x155 |     329x155 |    329x345 |         72x72 |           157x72 |      225x26 |
|                    320x568 |    141x141 |     292x141 |    292x311 |           N/A |              N/A |         N/A |

Rules:

- The default app preview baseline is the modern large iPhone size: `Small` 170x170, `Medium` 364x170, and `Large` 364x382.
- App preview cards must preserve the canonical widget aspect ratio and cap their width from the widget size tokens so previews do not stretch or compress inside flexible gallery layouts.
- Widget preview titles should sit outside the widget surface with enough separation to read as metadata, not as part of the widget itself.
- Widget layouts must remain responsive down to the 320x568 row.
- Lock Screen `Circular`, `Rectangular`, and `Inline` dimensions are documented here for future iOS widget expansion, but the shipping app flow remains Home Screen first.
- Do not invent custom preview dimensions when one of these rows applies.

### Home Screen Sizes

| Size | Use |
|---|---|
| `Small` | One focal metric or compact message |
| `Medium` | One main metric plus supporting context |
| `Large` | Multi-block composition or richer supporting content |

For now these are the core shipping sizes for the app flow and library organization. The design default is `170x170`, `364x170`, and `364x382`, with smaller device rows handled through scaling and responsive layout.

### Customization Sheet Pattern

The app customization experience should support:

- A top widget preview
- A display title below the rendered widget preview
- Inline segmented choices such as appearance mode
- Tap-to-open rows for nested pickers such as font selection
- Checkbox or tile-style choices for style presets
- A primary save or try action at the bottom

This is intentionally a flexible pattern, because not every widget needs the same control set.

Preview sheet rules:

- The sheet should read as a full-width bottom sheet with rounded top corners and no side or bottom gap.
- The drag indicator sits at the top center.
- The widget render, future form controls, and bottom save button live in separate visual layers.
- The bottom save button should sit above the phone bottom with padding comparable to the app bottom bar.
- Opening and closing should use subtle movement and backdrop fading without a visible dark band following the sheet.

### Settings Picker Pattern

Settings rows may use compact system menus/dropdowns for small value sets such as:

- Temperature unit
- Temperature display
- Distance unit

Rules:

- The row title must remain visible while the picker is open.
- Menus should be anchored near the tapped row/value, not centered on the screen.
- App font selection uses a sheet because it is a visual tile picker, not a compact value menu.
- The font picker sheet uses a compact header and two-column font tiles. The active tile should be visually distinct through an outline or dashed border treatment rather than relying only on text.

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

Library layout rules:

- Size tabs must be tappable and horizontally swipeable through `Small`, `Medium`, and `Large`.
- Empty states should appear for sizes with no saved presets.
- Row metadata should have a stable left column and the widget preview should occupy the right side.
- Small and medium rows should scale the widget preview down while preserving its canonical aspect ratio.
- Preview rows may intentionally crop the bottom of the widget under the row divider so the list reads like a preview strip instead of a fully shrunken gallery card.
- Light and dark appearances must use matching overlay/fade behavior; dark overlays should not leak into light mode.

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
- `AppFonts.swift` owns app font roles and selectable app font themes. Current themes are `SF Pro`, `SF Pro Rounded`, `Quicksand`, and `Fusion Pixel`; custom font files live in `DesignSystem/Fonts` and are registered at app launch.
- `WidgetFonts.swift` owns extension-safe widget font roles and explicit per-widget font themes.
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
