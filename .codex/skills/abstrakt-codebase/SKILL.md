# Abstrakt Codebase Skill

Use this skill when working inside the Abstrakt iOS app, especially when changing widgets, Live Activities, onboarding, settings, library/gallery flows, App Group data, or design-system styling.

## First Reads

Read these files before planning or editing:

- `AGENTS.md`
- `README.md`
- `docs/PROJECT_OVERVIEW.md`
- `docs/DESIGN_FOUNDATION.md`
- `docs/FEATURE_FRAMEWORK_MATRIX.md`
- `docs/architecture/FOLDER_STRUCTURE.md`
- `docs/product/WIDGET_LIBRARY_FLOW.md`
- `docs/product/FLOW.d2`

## Product Model

Abstrakt is a SwiftUI iOS app for discovering, configuring, saving, and previewing custom iPhone widget presets. The host app owns browsing, permission prompts, settings, saved presets, previews, and ActivityKit configuration. WidgetKit and ActivityKit extensions render prepared data; they should not become separate business-logic silos.

## Codebase Map

- `Abstrakt/App/`: app entry, tab shell, screens, shared components, and configuration sheets.
- `Abstrakt/Core/`: app-owned models, services, storage, settings, localization, constants, and extension helpers.
- `Abstrakt/DesignSystem/`: `AppColors`, `AppFonts`, spacing, radius, widget size tokens, and custom font files.
- `Abstrakt/Widgets/`: extension-safe widget renderers and `SharedWidgetStyle`.
- `Abstrakt/LiveActivities/`: ActivityKit renderers split by `SmartPills`, `Expanded`, `LiveActivity`, and `Shared`.
- `AbstraktWidgetsExtension/`: WidgetKit bundle, intents, timeline routing, AppEntity picker, shared extension storage, and extension fonts.

## Design Rules

- Use `AppColors` and `AppFonts` for host app UI. Do not introduce raw system colors or hard-coded font choices when a token exists.
- Use `SharedWidgetStyle` and widget color/text roles for Home Screen widgets.
- Use `LiveActivityTypography` and Live Activity metrics for ActivityKit surfaces.
- Keep Home Screen widgets localizable where supported, but do not localize visual-only widget labels unless the app already provides localized view data.
- ActivityKit surfaces stay independent from app Appearance; Smart Pills, expanded Dynamic Island, and Lock Screen Live Activity should not change just because Settings switches light/dark/system.
- Onboarding artwork fades should blend into `AppColors.appBackground`.
- Prefer filled card surfaces (`card`, `cardSoft`) over visible borders. Borders should be rare, quiet, and intentional.
- Haptics should fire on big/primary actions, bottom navigation, library/gallery sheets, Live Activity state changes, and item selection changes.

## Widget Rules

- Each widget folder owns a user-facing renderer and extension-safe render data.
- Provider access belongs in `Core/Services/`; WidgetKit reads App Group snapshots or saved preset data.
- In-app previews and placed widgets should share the same renderer whenever possible.
- Runtime widgets should render provider/cache values or explicit empty/permission/stale states. Static sample values are for Xcode previews only.
- New widgets must update `WidgetCatalog`, the feature matrix, design docs, and any extension asset target that actually needs the asset. Do not bulk-copy unused assets.

## Live Activity Rules

- `SmartPills` is compact Dynamic Island only.
- `Expanded` is expanded Dynamic Island only.
- `LiveActivity` is Lock Screen and notification Live Activity only.
- One ActivityKit activity owns all three states. If Dynamic Island is enabled but a state has no chosen item, show the explicit add/empty state for that state.
- `Glass`/`Solid` applies only to Lock Screen Live Activity preview and actual Lock Screen Live Activity.
- Glass should use Apple's Liquid Glass APIs where available and should not stack an opaque internal background over the native material.
- Preview items in sheets can show selected overlays (`checkmark.seal.fill`, `L`, `R`); frame previews and actual ActivityKit surfaces should not.
- Keep preview and actual ActivityKit dimensions aligned by using shared renderer sizing, not per-device magic numbers.

## Flow Rules

- First launch goes through onboarding, then the main app shell.
- Gallery opens widget preview/configuration sheets.
- Saved widget presets appear in Library by size and feed WidgetKit App Intent selection.
- Settings owns app Appearance, language, font, app icon, units, permissions, FAQ, share, and release notes.
- Live Activity screen configures Smart Pills, Expanded, and Live Activity selections without creating Library presets.

## Commit Hygiene

- Commit per feature when asked: examples include `feat: refine live activity surfaces`, `core: align onboarding artwork fades`, and `docs: refresh project knowledge base`.
- Do not push unless explicitly asked.
- Do not revert user changes without explicit approval.
