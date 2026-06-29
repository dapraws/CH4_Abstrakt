# Widget Library Flow

This document captures the intended user flow for widget selection, customization, and saving.

## Primary Flow

1. The user opens the gallery and browses available widgets.
2. The user can filter by category chips based on style or content.
3. The user taps a widget card.
4. A full-width preview/customization sheet opens with a live preview of the chosen widget.
5. The user chooses the target Home Screen size: `Small`, `Medium`, or `Large`.
6. The user adjusts any supported options for that widget.
7. Some options stay inline in the first sheet.
8. Some options open a secondary sheet, such as font selection.
9. The user saves the configured widget preset.
10. The saved preset appears in the Library page under its widget size tab.

## Customization Rules

- Not all widgets need the same fields.
- A widget may support only appearance mode and size.
- Another widget may support font family, font weight, icon set, and gradient styles.
- Health widgets may additionally support a goal, counter, metric, or progress style.
- Gallery categories should support both content-based discovery such as `Health` and `Weather`, and style-based discovery such as `Classic`, `Portal`, or `Minimalism`.
- The preview sheet should show the rendered widget and its display title before any future form controls.
- The save action stays pinned in its own bottom layer, separate from both the rendered widget and future form content.
- App-wide settings such as temperature unit, temperature display, and distance unit should live in Settings rather than inside every widget customization sheet unless a widget explicitly supports an override.

## Library Rules

- The Library page should group presets by size tab.
- The count shown in each tab should reflect saved presets in that size.
- A library card should show a realistic preview and enough metadata to distinguish one preset from another.
- The app library should represent saved presets, not the system-installed widget instances themselves.
- Size tabs should support both direct chip taps and horizontal swiping.
- Empty states should communicate when a size has no saved presets.
- Library row previews should preserve widget aspect ratio, scale down to fit the row, and may crop the bottom under the divider to keep the list dense and preview-like.

## System Widget Relationship

The Home Screen still uses the native iOS widget placement flow:

1. User adds `Solid Widget` from the system widget gallery.
2. User chooses one of the three WidgetKit slots: `Small Widget`, `Medium Widget`, or `Large Widget`.
3. User touches and holds the placed widget, taps `Edit Widget`, then opens `Current Widget`.
4. `Current Widget` shows only saved presets from Abstrakt that match that slot's size.
5. User selects a saved preset and taps `Done`.

Abstrakt therefore needs to manage saved preset identity and extension-readable configuration cleanly.

The WidgetKit extension should not expose one system widget per feature such as Battery, Steps, or Dashboard. Feature widgets are saved as library presets inside the app; WidgetKit exposes size-based Solid Widget renderers that consume those presets.
