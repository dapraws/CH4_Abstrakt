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
│   │   └── WidgetDetails/
│   ├── Components/
│   └── Configuration/
│       ├── Components/
│       └── Sheets/
├── Core/
│   ├── Models/
│   ├── Services/
│   ├── Storage/
│   ├── Constants/
│   └── Extensions/
├── DesignSystem/
│   ├── AppColors.swift
│   └── AppFonts.swift
├── Widgets/
│   ├── ClassicClock/
│   │   ├── ClassicClockWidget.swift
│   │   ├── ClassicClockPreview.swift
│   │   └── ClassicClockConfigSheet.swift
│   └── TodayMinimal/
│       ├── TodayMinimalWidget.swift
│       ├── TodayMinimalPreview.swift
│       └── TodayMinimalConfigSheet.swift
└── WidgetExtension/
    ├── WidgetBundle.swift
    ├── Widgets/
    └── Providers/
```

## Why This Shape

- `App/` stays small and owns only app entry/composition.
- `App/` also owns app screens and shared configuration UI.
- `Core/` owns data-facing concerns such as models, services, storage, constants, and extensions.
- `DesignSystem/` holds app-wide design tokens without burying them under another shared layer.
- `Widgets/` owns widget-entry-specific UI and configuration sheets.
- `WidgetExtension/` stays focused on WidgetKit registration and rendering.

## Naming Rules

- Put app screens in `App/Screens/`, not in a top-level `Features/` bucket.
- Name widget folders after user-facing widget entries such as `ClassicClock` or `TodayMinimal`, not raw data sources like `Clock` or `Calendar`.
- Keep per-widget files flat inside each widget folder until a widget becomes large enough to need subfolders.
- Put shared domain/config/catalog types in `Core/Models/`, not in every widget folder.
- Add a widget-local view model only when that widget has truly unique presentation logic.
