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
│   │   │   └── GalleryScreen.swift
│   │   ├── Home/
│   │   │   └── HomeScreen.swift
│   │   ├── Library/
│   │   │   └── LibraryScreen.swift
│   │   ├── LiveActivity/
│   │   │   ├── Components/
│   │   │   │   ├── LiveActivityFrame.swift
│   │   │   │   └── LiveActivitySlot.swift
│   │   │   └── LiveActivityScreen.swift
│   │   ├── Onboarding/
│   │   │   ├── OnboardingComponents.swift
│   │   │   ├── OnboardingScreen.swift
│   │   │   ├── Welcome/
│   │   │   │   └── WelcomeScreen.swift
│   │   │   ├── Tutorial/
│   │   │   │   └── TutorialScreen.swift
│   │   │   └── Permission/
│   │   │       └── OnboardingPermissionScreen.swift
│   │   └── Settings/
│   │       ├── SettingsScreen.swift
│   │       ├── SettingsSubscreenSupport.swift
│   │       ├── AppIcon/
│   │       │   └── AppIconScreen.swift
│   │       ├── FAQ/
│   │       │   └── FAQScreen.swift
│   │       ├── Language/
│   │       │   └── LanguageScreen.swift
│   │       ├── Permissions/
│   │       │   └── PermissionsScreen.swift
│   │       └── WhatsNew/
│   │           └── WhatsNewScreen.swift
│   ├── Components/
│   │   ├── BottomBar.swift
│   │   ├── BottomBarTab.swift
│   │   ├── BrandCreditFooter.swift
│   │   ├── CategoryChip.swift
│   │   ├── CenterTextScreen.swift
│   │   ├── FadingNavigationBar.swift
│   │   ├── ScreenSectionTitle.swift
│   │   ├── ScrollFadeView.swift
│   │   └── WidgetCard.swift
│   └── Configuration/
│       ├── Components/
│       │   └── ConfigRow.swift
│       └── Sheets/
│           ├── AppsPickerSheet.swift
│           ├── FontPickerSheet.swift
│           ├── LiveActivityPreviewSheet.swift
│           ├── ShareAppSheet.swift
│           └── WidgetPreviewSheet.swift
├── Core/
│   ├── Constants/
│   │   ├── AppGroupConstants.swift
│   │   ├── AppShareContent.swift
│   │   └── WidgetCatalog.swift
│   ├── Localization/
│   │   ├── Bundle+Localized.swift
│   │   ├── LocalizationManager.swift
│   │   └── String+L10n.swift
│   ├── Models/
│   │   ├── AppIconOption.swift
│   │   ├── WidgetAppearanceMode.swift
│   │   ├── WidgetCatalogItem.swift
│   │   ├── WidgetCategory.swift
│   │   ├── WidgetPreset.swift
│   │   └── WidgetSize.swift
│   ├── Services/
│   │   ├── BatteryStatusProvider.swift
│   │   ├── ClockDataProvider.swift
│   │   ├── EventKitManager.swift
│   │   ├── EventKitProvider.swift
│   │   ├── Haptics.swift
│   │   ├── HealthSummaryProvider.swift
│   │   ├── LiveActivitiesState.swift
│   │   ├── LiveActivityWidgetDataProvider.swift
│   │   ├── LocationProvider.swift
│   │   ├── ReminderProvider.swift
│   │   ├── StorageProvider.swift
│   │   └── WeatherProvider.swift
│   ├── Settings/
│   │   └── AppSettingsPreference.swift
│   └── Storage/
│       └── SharedModelContainer.swift
├── DesignSystem/
│   ├── AppColors.swift
│   ├── AppFonts.swift
│   ├── AppRadius.swift
│   ├── AppSpacing.swift
│   ├── WidgetSizeTokens.swift
│   └── Fonts/
│       ├── Quicksand-Light.ttf
│       ├── Quicksand-Regular.ttf
│       ├── Quicksand-Medium.ttf
│       ├── Quicksand-SemiBold.ttf
│       ├── Quicksand-Bold.ttf
│       └── Fusion-Pixel-Regular.ttf
├── Widgets/
│   ├── SharedWidgetStyle.swift
│   ├── Activity/
│   │   └── ActivityWidget.swift
│   ├── Battery/
│   │   └── BatteryWidget.swift
│   ├── Calendar/
│   │   └── CalendarWidget.swift
│   ├── Clock/
│   │   └── ClockWidget.swift
│   ├── Daylight/
│   │   └── DaylightWidget.swift
│   ├── Events/
│   │   └── EventsWidget.swift
│   ├── HeartRate/
│   │   └── HeartRateWidget.swift
│   ├── Portal/
│   │   └── Portal.swift
│   ├── Reminder/
│   │   ├── ReminderModels.swift
│   │   └── ReminderWidget.swift
│   ├── Sleep/
│   │   └── SleepWidget.swift
│   ├── Steps/
│   │   └── StepsWidget.swift
│   ├── Storage/
│   │   └── StorageWidget.swift
│   ├── Today/
│   │   └── TodayWidget.swift
│   ├── Weather/
│   │   └── WeatherWidget.swift
│   └── Gradient/
│       ├── GradientTheme.swift
│       └── GradientWidget.swift
├── LiveActivities/
│   ├── DynamicIslandActivity.swift
│   ├── SmartPills/
│   │   └── SmartPillIslandRegion.swift
│   ├── Expanded/
│   │   └── ExpandedActivity.swift
│   ├── LiveActivity/
│   │   └── LockScreenActivity.swift
│   └── Shared/
│       ├── DynamicIslandActivityAttributes.swift
│       ├── LiveActivityEmptyState.swift
│       ├── LiveActivityItemRenderer.swift
│       ├── LiveActivityTypography.swift
│       └── LiveActivityWidget.swift
├── Config/
│   ├── Signing.xcconfig
│   ├── Signing.local.xcconfig.example
│   └── Signing.local.xcconfig (optional, gitignored)
├── Resources/
│   └── Localizable.xcstrings
└── AbstraktWidgetsExtension/
    ├── AbstraktWidgetsBundle.swift
    ├── AbstraktNewWidgets.swift
    ├── SavedWidgetEntity.swift
    ├── SolidWidgetIntents.swift
    ├── Info.plist
    ├── AbstraktWidgetsExtension.entitlements
    ├── Fonts/
    │   ├── Quicksand-Light.ttf
    │   ├── Quicksand-Regular.ttf
    │   ├── Quicksand-Medium.ttf
    │   ├── Quicksand-SemiBold.ttf
    │   ├── Quicksand-Bold.ttf
    │   └── Fusion-Pixel-Regular.ttf
    └── Shared/
        ├── SavedWidgetPreset.swift
        └── WidgetSharedStore.swift
```

## Why This Shape

- `App/` stays focused on the main iOS app shell, screens, navigation, and modal configuration sheets.
- `Core/` owns all data-facing architecture: models, providers/services, shared storage abstractions, constants, settings enums, and localization engine.
- `Core/Services/` encapsulates all Apple system frameworks (`HealthKit`, `WeatherKit`, `CoreLocation`, `EventKit`, `UIKit`, `Foundation`).
- `Core/Settings/` owns shared preference types (`TemperatureUnitPreference`, `TemperatureDisplayPreference`, `DistanceUnitPreference`, `AppLanguage`, `AppSettingsPreference`) used by both the app and widgets.
- `Core/Storage/SharedModelContainer.swift` provides atomic serialization and deserialization of snapshots and widget presets to App Group `UserDefaults`, plus thumbnail disk persistence and `WidgetTimelineReloadScheduler`.
- `Core/Localization/` coordinates in-app runtime language switching via `LocalizationManager` without needing an app restart.
- `DesignSystem/` defines shared semantic tokens for colors (`AppColors`), fonts (`AppFonts`), radii (`AppRadius`), spacings (`AppSpacing`), and widget sizes (`WidgetSizeTokens`).
- `Widgets/` houses the 15 feature widget renderers and `SharedWidgetStyle.swift`. Renderers are compiled into both the host app target and the `AbstraktWidgetsExtension` target.
- `LiveActivities/` hosts ActivityKit widgets divided by presentation state: `SmartPills` (compact Dynamic Island), `Expanded` (expanded Dynamic Island), `LiveActivity` (Lock Screen / notification Live Activity), and `Shared` (attributes, typography, item renderer, empty state).
- `AbstraktWidgetsExtension/` handles WidgetKit timeline providers, entries, App Intents (`SmallSolidWidgetIntent`, `MediumSolidWidgetIntent`, `LargeSolidWidgetIntent`), and `AppEntity` query resolvers (`SavedWidgetEntity`).

## Naming Rules

- App screens belong in `App/Screens/` and end in `Screen.swift` (e.g. `GalleryScreen.swift`, `LibraryScreen.swift`, `LiveActivityScreen.swift`).
- Configuration sheets belong in `App/Configuration/Sheets/` and end in `Sheet.swift` (e.g. `WidgetPreviewSheet.swift`, `LiveActivityPreviewSheet.swift`).
- Widget folders correspond 1:1 with catalog entries: `Activity`, `Battery`, `Calendar`, `Clock`, `Daylight`, `Events`, `Gradient`, `HeartRate`, `Portal`, `Reminder`, `Sleep`, `Steps`, `Storage`, `Today`, `Weather`.
- ActivityKit renderer files use `Activity` naming (`DynamicIslandActivity.swift`, `ExpandedActivity.swift`, `LockScreenActivity.swift`), reflecting ActivityKit state rather than generic screens.
- Shared domain/catalog models belong in `Core/Models/`.
- App-only code paths in shared widget files must be wrapped with `#if !WIDGET_EXTENSION`.
- Extension-only code paths (e.g. AppIntents in Portal) must be wrapped with `#if WIDGET_EXTENSION`.

## Extension Surface Rules

- Widget folders own Home Screen and StandBy widget visuals. They must not contain ActivityKit layout code.
- Live Activity folders own ActivityKit visuals. They must not contain app screen state, provider fetches, or WidgetKit timeline logic.
- `Core/Services/LiveActivities/LiveActivitiesState.swift` is the source of truth for ActivityKit lifecycle management (`Activity<DynamicIslandActivityAttributes>.request` / `update` / `end`) and slot assignments.
- `App/Configuration/Sheets/LiveActivityPreviewSheet.swift` renders preview cards and item badges, delegating presentation rendering to `LiveActivityItemRenderer`.
- `App/Screens/LiveActivity/Components/LiveActivityFrame.swift` coordinates the phone frame preview, island contours, stepper, glass/solid picker, and item removal actions.
