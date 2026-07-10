# Design Foundation

This document defines the UI foundation for Abstrakt across the main app, widget previews, and the Home Screen widget extension.

## Design Goals

- Glanceable in widget sizes
- High contrast in both light and dark environments
- Flexible enough for widget-specific customization
- Consistent between app previews and actual WidgetKit rendering
- Strong enough to support a library of saved presets rather than one-off widget screens
- Localized enough that screen copy, picker labels, permission messages, and settings rows can switch language without layout breakage

## Appearance Modes

Every configurable widget should support appearance choices where relevant:

- `System`
- `Light`
- `Dark`

Rules:

- `System` follows the current device context.
- `Light` and `Dark` must preview deterministically inside the app sheet even if the app itself is running in another appearance.
- Saved presets should persist the appearance choice as part of widget configuration when the widget supports it.

## Color Tokens

`AppColors` is the canonical source for app color roles. Start from these roles instead of hard-coded values in feature code or docs.

| Token | Light | Dark | Use |
|---|---|---|---|
| `appBackground` | `#F0F2FC` | `#17171D` | Main app background |
| `topFade` | `#F0F2FC` | `#17171D` | Top navigation fade background |
| `card` | `#F7F8FD` | `#1D1D24` | Primary grouped surface |
| `cardSoft` | `#ECEEF7` | `#22222B` | Softer controls, empty slots, secondary grouped surfaces |
| `miniAppEmptySlot` | `#E2E5EF` | `#30303A` | Empty Portal mini-app slots |
| `miniAppEmptySlotBorder` | `#C9CEDC` | `#3B3B46` | Empty Portal slot boundary when a boundary is required |
| `chip` | `#FCFCFC` | `#070707` | Unselected chips |
| `chipSelected` | `#141414` | `#F4F4F4` | Selected chips |
| `chipBorder` | `#141414` at 7% | `#F4F4F4` at 7% | Subtle chip boundary |
| `chipBorderSelected` | `#141414` at 12% | `#F4F4F4` at 12% | Selected chip boundary |
| `chipText` | `#141414` | `#F4F4F4` | Unselected chip text |
| `chipTextSelected` | `#F0F2FC` | `#17171D` | Selected chip text |
| `tabBar` | `#000000` | `#000000` | Bottom tab bar base |
| `tabBarBorder` | `#161616` | `#161616` | Bottom tab bar divider |
| `tabBarIcon` | `#FFFFFF` at 42% | `#FFFFFF` at 42% | Unselected tab icon |
| `tabBarIconSelected` | `#FFFFFF` | `#FFFFFF` | Selected tab icon |
| `separator` | `#FFFFFF` at 12% | `#FFFFFF` at 12% | Lightweight separators |
| `primaryText` | `#141414` | `#F4F4F4` | Primary labels and headings |
| `secondaryText` | `#141414` at 62% | `#F4F4F4` at 62% | Secondary copy |
| `tertiaryText` | `#141414` at 42% | `#F4F4F4` at 42% | Metadata and low-emphasis copy |
| `accentBlue` | `rgb(0.29, 0.63, 1.0)` | Same | Blue feature accents |
| `accentGreen` | `rgb(0.32, 0.89, 0.48)` | Same | Green feature accents |
| `accentPurple` | `#615FFF` | `#615FFF` | Primary brand/action purple |
| `accentPink` | `rgb(0.97, 0.45, 0.63)` | Same | Pink feature accents |
| `widgetBackground` | `#FDFDFD` | `#060606` | Widget canvas background |
| `widgetPrimaryText` | `#0A0A0A` | `#F4F4F4` | Widget primary text |
| `widgetSecondaryText` | `#0A0A0A` at 62% | `#F4F4F4` at 62% | Widget secondary text |
| `widgetTertiaryText` | `#0A0A0A` at 42% | `#F4F4F4` at 42% | Widget metadata text |
| `widgetStroke` | `#0A0A0A` at 8% | `#F4F4F4` at 8% | Widget boundaries when a stroke is needed |

Rules:

- Prefer `card` and `cardSoft` filled surfaces over visible borders. Borders should be rare and quiet.
- Use `accentPurple` (`#615FFF`) for primary onboarding actions, selected permission toggles, and prominent branded controls.
- Keep widget colors separate from app colors. Runtime widgets should use the `widget*` roles instead of app screen text/background roles.
- Use opacity roles exactly as defined above; do not replace them with nearby opaque grays.

## Typography Roles

The app needs two kinds of typography tokens:

### Semantic UI Roles

- `display`
- `homeDisplay`
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

Widgets use the same semantic sizing model, and the selected app font theme is shared with WidgetKit so Home Screen widgets and in-app previews stay visually aligned. Per-widget font overrides can still be added later as explicit saved-preset configuration.

- `widgetDisplay`
- `widgetTitle`
- `widgetHeading`
- `widgetBody`
- `widgetCaption`
- `widgetMeta`

The app font picker currently exposes `SF Pro`, `SF Rounded`, `Quicksand`, and `Fusion Pixel`, with `Quicksand` as the default app font. Pixel fonts use smaller token sizes and tighter line spacing so multiline layouts remain visually comparable across font themes.

Rules:

- Use `AppFonts` token roles for host-app UI instead of static font sizes.
- Use `AbstraktWidgetFonts` and `AbstraktWidgetFontTheme` for shared widget renderers that compile into both the app and WidgetKit extension.
- Bottom bar icon sizing should stay stable and must not change based on the selected app font.
- App font changes should update visible app rows immediately without requiring a screen refresh.
- App font changes should also be written to App Group storage and trigger a WidgetKit timeline reload.

## Localization Roles

The app supports a user-selectable language setting with these options:

- `System`
- `English`
- `Bahasa Indonesia`
- `Español`
- `Português (Brasil)`

Rules:

- User-facing strings belong in `Localizable.xcstrings`; SwiftUI screens should call the localization helpers instead of embedding fixed English text.
- Language changes should visibly update Settings, onboarding, Gallery, Library, preview sheets, picker sheets, permission alerts, and other app copy.
- Text containers should allow realistic expansion for Spanish, Portuguese-Brazil, and Indonesian strings through wrapping, line limits, or minimum scale factors where needed.
- Widget-visible strings should be sourced from localized keys or prelocalized view data, then refreshed through WidgetKit when the language changes.

## Layout Foundation

### iOS Widget Size Baselines

Abstrakt is currently focused on iPhone widget design. Use these point sizes as measured fallbacks and aspect-ratio baselines for app previews, WidgetKit rendering checks, and size-specific layout decisions. Do not maintain a device-by-device Apple hardware table in app code; WidgetKit supplies the real widget container size at render time, and in-app previews should fit available width while preserving the family ratio.

| Family | Baseline Size (pt) | Ratio | Use |
|---|---:|---:|---|
| `Small` | 170x170 | 1.00 | One focal metric or compact message |
| `Medium` | 364x170 | 2.14 | One main metric plus supporting context |
| `Large` | 364x382 | 0.95 | Multi-block composition or richer supporting content |

Rules:

- The default app preview baseline is the modern large iPhone size: `Small` 170x170, `Medium` 364x170, and `Large` 364x382.
- App preview cards must preserve the measured widget aspect ratio and fit the available container width instead of requiring a hardcoded table entry for every Apple device.
- Widget preview titles should sit outside the widget surface with enough separation to read as metadata, not as part of the widget itself.
- Widget layouts must remain responsive when preview width is constrained below the baseline width.
- Small portal launcher widgets may use overlapping app-icon clusters when each tappable icon remains visually distinct and the header has a single-line fallback scale.
- Portal launcher customization uses a compact MiniApps opener for the selected six apps and a menu-only icon clip control for `Default`, `Circle`, and `Bloom`.
- Activity widgets may use a minimal title, one SF Symbol status mark, and stacked metric rows with lighter unit labels. The Today/Weekly choice belongs in the preview sheet and must stay shared with WidgetKit.
- Events widgets use compact date context, a status badge such as `Starts soon` or `Now`, and stacked event text. The Upcoming/Current priority choice belongs in the preview sheet and must stay shared with WidgetKit.
- Weather widgets may use custom condition assets when the asset name maps directly from the WeatherKit condition snapshot, while still rendering a legible fallback for unknown conditions.
- Storage widgets should render used and available portions inside a quiet rounded container. Use `widgetStroke` only when separation cannot be achieved with fill, spacing, or contrast.
- Lock Screen `Circular`, `Rectangular`, and `Inline` dimensions are documented here for future iOS widget expansion, but the shipping app flow remains Home Screen first.
- Do not invent custom preview aspect ratios when one of these rows applies.

### Home Screen Sizes

| Size | Use |
|---|---|
| `Small` | One focal metric or compact message |
| `Medium` | One main metric plus supporting context |
| `Large` | Multi-block composition or richer supporting content |

For now these are the core shipping sizes for the app flow and library organization. The design default is `170x170`, `364x170`, and `364x382`, with smaller device rows handled through measured-ratio scaling and responsive layout.

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
- The font picker sheet uses a compact header and two-column font tiles. The active tile should be visually distinct through selected fill, contrast, or a very quiet focus treatment rather than relying only on text.
- Language selection uses a dedicated tile screen so each language can appear in its own display name.
- App icon selection uses a dedicated two-column visual picker with preview art for `Default`, `Glass`, `Purple`, and `Blue` icons. This is app-only UI and should not be mirrored in the widget extension.

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

Runtime widget surfaces should not use static sample metrics as fallbacks. Use provider data, App Group cached values, or explicit empty/permission-denied copy; keep fixed sample values limited to Xcode canvas previews.

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
- `AppFonts.swift` owns app font roles and selectable app font themes. Current themes are `SF Pro`, `SF Rounded`, `Quicksand`, and `Fusion Pixel`; custom font files live in `DesignSystem/Fonts` and are registered at app launch.
- `Core/Localization/LocalizationManager.swift` owns the selected app language and localized bundle.
- `Abstrakt/Resources/Localizable.xcstrings` owns app copy for supported languages.
- `Abstrakt/Widgets/SharedWidgetStyle.swift` owns extension-safe widget font roles, shared widget palettes, and custom font registration for both the host app and WidgetKit extension.
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
