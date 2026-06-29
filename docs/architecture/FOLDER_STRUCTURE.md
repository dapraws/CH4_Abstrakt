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
│   │   └── WidgetDetails/
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
│   └── Extensions/
├── DesignSystem/
│   ├── AppColors.swift
│   ├── AppFonts.swift
│   ├── Fonts/
│   ├── WidgetFonts.swift
│   ├── WidgetFontCatalog.swift
│   └── WidgetSizeTokens.swift
├── Widgets/
│   ├── BatteryBars/
│   ├── StepHealth/
│   └── DailyDashboard/
└── AbstraktWidgetsExtension/
    ├── AbstraktWidgetsBundle.swift
    ├── AbstraktNewWidgets.swift
    ├── SolidWidgetIntents.swift
    ├── Fonts/
    └── Shared/
        ├── SavedWidgetPreset.swift
        ├── WidgetFonts.swift
        └── WidgetSharedStore.swift
```

## Why This Shape

- `App/` stays small and owns only app entry/composition.
- `App/` also owns app screens and shared configuration UI.
- `Core/` owns data-facing concerns such as models, services, storage, constants, and extensions.
- `Core/Settings/` owns shared preference enums and storage keys that both the app and widgets need.
- `DesignSystem/` holds app-wide design tokens without burying them under another shared layer.
- `DesignSystem/Fonts/` stores host-app custom font files and should mirror any extension-needed font files under `AbstraktWidgetsExtension/Fonts/`.
- `Widgets/` owns widget-entry-specific UI and configuration sheets.
- `WidgetExtension/` stays focused on WidgetKit registration and rendering.

## Naming Rules

- Put app screens in `App/Screens/`, not in a top-level `Features/` bucket.
- Name widget folders after user-facing widget entries such as `ClassicClock` or `TodayMinimal`, not raw data sources like `Clock` or `Calendar`.
- Keep per-widget files flat inside each widget folder until a widget becomes large enough to need subfolders.
- Put shared domain/config/catalog types in `Core/Models/`, not in every widget folder.
- Put shared app/widget preference types in `Core/Settings/`, not in screen files.
- Add a widget-local view model only when that widget has truly unique presentation logic.
- Keep app font preferences in the app design system; widgets should use explicit widget font themes so installed widget layouts remain stable.
