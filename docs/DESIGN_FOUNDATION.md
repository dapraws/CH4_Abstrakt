# Design Foundation

This document defines the complete UI foundation for Abstrakt across the main iOS app, widget previews, the WidgetKit extension, and ActivityKit surfaces.

## Design Goals

- **Glanceable Hierarchy**: Immediate clarity at small and medium Home Screen widget dimensions.
- **Dynamic Contrast**: Seamless dark and light appearance adaptation using native SwiftUI semantics.
- **Component Parity**: Visual identity and proportions match 1:1 between in-app previews, WidgetKit widgets, and ActivityKit presentations.
- **Shared Tokens**: Semantic color roles, typography scales, layout metrics, and radii are shared between the app and extension targets.
- **Multilingual Support**: Layout containers adapt gracefully to varying string lengths across English, Indonesian, Spanish, and Brazilian Portuguese.

---

## Appearance Modes

Every configurable widget and preset supports three appearance modes:

- `System`: Matches the host device's active color scheme.
- `Light`: Forces light-mode background and foreground styling.
- `Dark`: Forces dark-mode background and foreground styling.

### Rules
- In-app preview sheets honor the widget preset's configured appearance mode even if the host app is running in a different mode.
- Global app theme is managed in **Settings > Appearance** (`System`, `Light`, `Dark`).
- `GradientWidget` uses dark atmospheric bases across all appearance modes (Ruby Aurora, Cyan Topographic Contours, Fractal Fluted Prism, Sunset Amber Bleed, Emerald Cyber Matrix, and Acid Bayer Dither) to maintain glowing incandescent contrast with white editorial typography.
- `ClockWidget` supports Light and Dark dial themes with Roman numeral indices, watermarked hour display, and accent red seconds needle.
- ActivityKit surfaces (Smart Pills, Expanded, Lock Screen Live Activity) are visually independent from the app appearance preference, using system-native black or glass materials.

---

## Semantic Color Tokens (`AppColors`)

`DesignSystem/AppColors.swift` provides dynamic color definitions that automatically resolve light and dark interface traits:

| Token Name | Light Hex | Dark Hex | Purpose / Placement |
|---|---|---|---|
| `appBackground` | `#F0F2FC` | `#17171D` | Primary app canvas and screen background |
| `topFade` | `#F0F2FC` | `#17171D` | Top navigation bar gradient overlay fade |
| `card` | `#F7F8FD` | `#1D1D24` | Primary elevated grouped surface (cards, sheets) |
| `cardSoft` | `#ECEEF7` | `#22222B` | Secondary soft surfaces, inactive controls, inner containers |
| `controlInactive` | `#E3E6F2` | `#353542` | Inactive segmented controls and toggles |
| `liveActivityCard` | `#FAFAFC` | `#22222B` | Live activity preview cards in sheets |
| `miniAppEmptySlot` | `#E2E5EF` | `#30303A` | Unfilled Portal mini-app slots |
| `miniAppEmptySlotBorder` | `#C9CEDC` | `#3B3B46` | Border for unfilled Portal mini-app slots |
| `chip` | `#FCFCFC` | `#070707` | Unselected category / filter chips |
| `chipSelected` | `#141414` | `#F4F4F4` | Selected category / filter chips |
| `chipBorder` | `#141414` (7%) | `#F4F4F4` (7%) | Subtle border for unselected chips |
| `chipBorderSelected` | `#141414` (12%) | `#F4F4F4` (12%) | Border for selected chips |
| `chipText` | `#141414` | `#F4F4F4` | Unselected chip label text |
| `chipTextSelected` | `#F0F2FC` | `#17171D` | Selected chip label text |
| `tabBar` | `#000000` | `#000000` | Floating bottom navigation bar background |
| `tabBarBorder` | `#161616` | `#161616` | Floating bottom navigation bar border stroke |
| `tabBarIcon` | `#FFFFFF` (42%) | `#FFFFFF` (42%) | Unselected tab item icon tint |
| `tabBarIconSelected` | `#FFFFFF` | `#FFFFFF` | Selected tab item icon tint |
| `separator` | `#FFFFFF` (12%) | `#FFFFFF` (12%) | Subtle row divider |
| `primaryText` | `#141414` | `#F4F4F4` | Primary titles, headlines, and prominent labels |
| `secondaryText` | `#141414` (62%) | `#F4F4F4` (62%) | Secondary labels, descriptions, and subtitles |
| `tertiaryText` | `#141414` (42%) | `#F4F4F4` (42%) | Captions, metadata, and timestamps |
| `accentBlue` | `rgb(0.29, 0.63, 1.0)` | Same | Informational highlights and Weather tags |
| `accentGreen` | `rgb(0.32, 0.89, 0.48)` | Same | Success badges, completion marks, step markers |
| `accentPurple` | `#615FFF` | `#615FFF` | Primary brand accent, CTA buttons, active state |
| `accentPink` | `rgb(0.97, 0.45, 0.63)` | Same | Portal ordinal highlights and special accents |
| `widgetBackground` | `#FDFDFD` | `#060606` | Native Home Screen widget canvas background |
| `widgetPrimaryText` | `#0A0A0A` | `#F4F4F4` | Primary widget metric and headline text |
| `widgetSecondaryText` | `#0A0A0A` (62%) | `#F4F4F4` (62%) | Secondary widget metric and label text |
| `widgetTertiaryText` | `#0A0A0A` (42%) | `#F4F4F4` (42%) | Low-emphasis widget metadata and units |
| `widgetStroke` | `#0A0A0A` (8%) | `#F4F4F4` (8%) | Outer widget border when required |

---

## Radius & Spacing Tokens

### `AppRadius` (`DesignSystem/AppRadius.swift`)
- `AppRadius.card`: **22 pt** (Widget cards, library items, modal sheets)
- `AppRadius.chip`: **13 pt** (Category chips, filter pills)
- `AppRadius.bottomBar`: **30 pt** (Floating bottom tab bar)

### `AppSpacing` (`DesignSystem/AppSpacing.swift`)
- `AppSpacing.screenHorizontal`: **20 pt** (Standard horizontal screen margin)
- `AppSpacing.sectionGap`: **24 pt** (Vertical spacing between major sections)
- `AppSpacing.cardGap`: **16 pt** (Spacing between consecutive cards)
- `AppSpacing.chipGap`: **10 pt** (Spacing between category chips)
- `AppSpacing.bottomBarInset`: **30 pt** (Bottom inset for floating bar clearance)

### `WidgetSizeTokens` (`DesignSystem/WidgetSizeTokens.swift`)
- `WidgetSizeTokens.defaultHomeSmall`: **CGSize(170, 170)** (1:1 square)
- `WidgetSizeTokens.defaultHomeMedium`: **CGSize(364, 170)** (2.14:1 ratio)
- `WidgetSizeTokens.defaultHomeLarge`: **CGSize(364, 382)** (0.95:1 ratio)

---

## Typography System

### 1. Host App Semantic Font Roles (`AppFonts.swift`)

| Role | Base Size | Weight | Line Spacing |
|---|---|---|---|
| `homeDisplay` | 44 pt | Bold | -2 |
| `display` | 34 pt | Bold | -1 |
| `title` | 28 pt | Bold | -1 |
| `heading1` | 24 pt | Black | -1 |
| `heading2` | 20 pt | Bold | 0 |
| `heading3` | 17 pt | Bold | 0 |
| `heading4` | 15 pt | Bold | 0 |
| `body` | 15 pt | Medium | +2 |
| `subBody` | 14 pt | Medium | +2 |
| `subHeading` | 15 pt | Bold | +2 |
| `caption` | 13 pt | SemiBold | +1 |
| `meta` | 10 pt | Bold | 0 |
| `chip` | 12 pt | Bold | 0 |
| `tab` | 14 pt | Bold | 0 |
| `iconBadge` | 10 pt | Black | 0 |
| `liveActivityTitle` | 18 pt | Bold | 0 |
| `liveActivitySection` | 16 pt | Bold | 0 |
| `liveActivityLabel` | 9 pt | SemiBold | 0 |
| `liveActivityHelper` | 11 pt | Medium | 0 |
| `liveActivityControl` | 10 pt | SemiBold | 0 |

### 2. Shared Extension Widget Font Roles (`SharedWidgetStyle.swift`)

Used by both host app widget previews and `AbstraktWidgetsExtension`:

| Widget Role | Base Size | Weight | Line Spacing |
|---|---|---|---|
| `display` | 41 pt | Bold | -2 |
| `displayCompact` | 32 pt | Bold | -2 |
| `subDisplay` | 12 pt | SemiBold | -2 |
| `title` | 30 pt | Bold | -1 |
| `heading` | 18 pt | Bold | 0 |
| `body` | 13 pt | Medium | +2 |
| `bodyBold` | 12 pt | SemiBold | +2 |
| `caption` | 10 pt | Medium | 0 |
| `meta` | 9 pt | SemiBold | 0 |
| `iconBadge` | 7 pt | Black | 0 |

### 3. Selectable Font Themes (`AppFontTheme` / `AbstraktWidgetFontTheme`)

Users can choose their active typography theme in **Settings > Font**:

- **Quicksand** (Default): Bundled custom rounded sans-serif (`Quicksand-Light`, `Quicksand-Regular`, `Quicksand-Medium`, `Quicksand-SemiBold`, `Quicksand-Bold`). Scale: 1.0.
- **SF Pro**: System clean sans-serif. Scale: 0.89 - 0.92 depending on role.
- **SF Rounded**: System rounded design. Scale: 0.89 - 0.92.
- **Fusion Pixel**: Bundled proportional pixel font (`Fusion-Pixel-Regular.ttf`). Scale: 0.74 - 0.82 with negative line spacing adjustments for balanced density.

---

## Live Activity & Dynamic Island Design Language

### Sizing & Geometric Constants (`LiveActivityWidgetMetrics`)
- `islandWidth`: **328 pt**
- `lockScreenActivityWidth`: **328 pt**
- `expandedIslandCornerRadius`: **38 pt**
- `lockScreenActivityCornerRadius`: **28 pt**
- `expandedPreviewCornerRadius`: **38 pt**
- `activityPreviewCornerRadius`: **30 pt**
- `expandedIslandHeight`: **132 pt**
- `lockScreenIslandHeight`: **136 pt**
- `lockScreenEmptyStateHeight`: **136 pt**
- `liveActivityTodayInfoSurfaceHeight`: **136 pt**
- `liveActivityWeatherInfoSurfaceHeight`: **136 pt**
- `expandedTodayInfoSurfaceHeight`: **132 pt**
- `expandedWeatherInfoSurfaceHeight`: **132 pt**
- `liveActivityCalendarInfoSurfaceHeight`: **124 pt**
- `expandedCalendarInfoSurfaceHeight`: **120 pt**

### Visual Modes for Lock Screen
- **Glass**: Utilizes SwiftUI Liquid Glass (`glassEffect(.regular, in: shape)`) with a multi-stop specular gradient border. In light mode, text automatically shifts to dark primary text (`#141414`) for high-contrast readability.
- **Solid**: High-contrast pure black background (`#000000`) with subtle specular stroke border.

### Smart Pill Design Rules
- Left and right pills render in compact Dynamic Island leading and trailing slots.
- Active pill selection feedback is represented as a smooth contour highlight in the phone frame preview, not by expanding the island or using heavy badge overlays.
- Minimal presentation (`minimal`) collapses to a single icon with the widget's thematic accent color.
