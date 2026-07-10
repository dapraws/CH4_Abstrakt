# Folder Structure

This file is the canonical folder blueprint for the current Abstrakt app.

## Repository Structure

```text
Abstrakt/
├── App/
│   ├── AbstraktApp.swift
│   ├── ContentView.swift
│   ├── Screens/
│   │   ├── Gallery/
│   │   ├── Library/
│   │   ├── Onboarding/
│   │   ├── Settings/
│   │   │   ├── AppIcon/
│   │   │   ├── FAQ/
│   │   │   ├── Language/
│   │   │   ├── Permissions/
│   │   │   └── WhatsNew/
│   │   ├── Home/
│   │   └── WIP/
│   ├── Components/
│   └── Configuration/
│       ├── Components/
│       └── Sheets/
├── Core/
│   ├── Models/
│   ├── Services/
│   │   ├── Calendar/
│   │   ├── Clock/
│   │   ├── Health/
│   │   ├── System/
│   │   └── Weather/
│   ├── Settings/
│   ├── Storage/
│   ├── Constants/
│   ├── Localization/
│   └── Extensions/
├── DesignSystem/
│   ├── AppColors.swift
│   ├── AppFonts.swift
│   ├── Fonts/
│   └── WidgetSizeTokens.swift
├── Widgets/
│   ├── SharedWidgetStyle.swift
│   ├── Battery/
│   ├── Steps/
│   ├── Activity/
│   ├── Events/
│   ├── Portal/
│   ├── Storage/
│   ├── Today/
│   ├── Weather/
│   ├── Daylight/
│   └── HeartRate/
└── AbstraktWidgetsExtension/
    ├── AbstraktWidgetsBundle.swift
    ├── AbstraktNewWidgets.swift
    ├── SavedWidgetEntity.swift
    ├── SolidWidgetIntents.swift
    ├── Fonts/
    └── Shared/
        ├── SavedWidgetPreset.swift
        └── WidgetSharedStore.swift
```

## Why This Shape

- `App/` stays small and owns only app entry/composition.
- `App/` also owns app screens and shared configuration UI.
- `Core/` owns data-facing concerns such as models, services, storage, constants, and extensions.
- `Core/Settings/` owns shared preference enums and storage keys that both the app and widgets need.
- `Core/Localization/` owns runtime language selection and localized bundle helpers for the host app.
- `DesignSystem/` holds app-wide design tokens without burying them under another shared layer.
- `DesignSystem/Fonts/` stores host-app custom font files and should mirror any extension-needed font files under `AbstraktWidgetsExtension/Fonts/`.
- `Widgets/` owns widget-entry-specific UI, extension-safe render snapshots, and shared widget styling used by both the app and WidgetKit extension.
- `AbstraktWidgetsExtension/` stays focused on WidgetKit registration, timeline entries, App Intents, AppEntity picker data, and size-slot routing. It should not duplicate widget visual implementations.

## Naming Rules

- Put app screens in `App/Screens/`, not in a top-level `Features/` bucket.
- Name widget folders after concise user-facing widget entries such as `Battery`, `Steps`, `Activity`, `Events`, `Portal`, `Storage`, `Today`, `Weather`, `Daylight`, and `HeartRate`.
- Avoid style-only names, and avoid baking Home Screen size labels into feature names.
- Keep per-widget files flat inside each widget folder until a widget becomes large enough to need subfolders.
- Put shared domain/config/catalog types in `Core/Models/`, not in every widget folder.
- Put shared app/widget preference types in `Core/Settings/`, not in screen files.
- Put runtime localization helpers in `Core/Localization/`, and put translated strings in `Abstrakt/Resources/Localizable.xcstrings`.
- Add a widget-local view model only when that widget has truly unique presentation logic.
- Keep shared widget renderers extension-safe. Guard app-only provider adapters with `#if !WIDGET_EXTENSION`.
- Share app font preferences with WidgetKit through App Group storage; use explicit saved-preset configuration only when a widget needs its own override.
- Keep UIKit-only app personalization, such as alternate icon switching, inside app screens/models and out of widget-extension targets.
