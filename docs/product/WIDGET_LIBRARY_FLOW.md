# Widget Library Flow

This document captures the intended user flow for widget selection, customization, and saving.

## Primary Flow

1. The user opens the gallery and browses available widgets.
2. The user can filter by category chips based on style or content.
3. The user taps a widget card.
4. A customization sheet opens with a large live preview of the chosen widget.
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

## Library Rules

- The Library page should group presets by size tab.
- The count shown in each tab should reflect saved presets in that size.
- A library card should show a realistic preview and enough metadata to distinguish one preset from another.
- The app library should represent saved presets, not the system-installed widget instances themselves.

## System Widget Relationship

The Home Screen still uses the native iOS widget placement flow:

1. User adds the Abstrakt widget from the system widget gallery.
2. User chooses the widget size on the Home Screen.
3. User edits that widget and selects one of the saved presets from Abstrakt.

Abstrakt therefore needs to manage saved preset identity and extension-readable configuration cleanly.
