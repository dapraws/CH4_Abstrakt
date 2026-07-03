import SwiftUI

struct WidgetCard: View {
    private static let settingsStore = AppGroupConstants.sharedDefaults

    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false
    var showsTitle = true
    var maximumPreviewWidth: CGFloat?
    var maximumPreviewScale: CGFloat = 1
    @AppStorage(AppGroupConstants.portalSelectedAppsKey, store: settingsStore) private var portalSelectedAppsValue = PortalApp.storageValue(for: PortalApp.defaultSelection)
    @AppStorage(AppGroupConstants.portalIconClipStyleKey, store: settingsStore) private var portalIconClipStyleID = PortalIconClipStyle.default.id
    @AppStorage(AppGroupConstants.activityModeKey, store: settingsStore) private var activityModeID = ActivityMode.today.id
    @AppStorage(AppGroupConstants.eventModeKey, store: settingsStore) private var eventModeID = EventDisplayMode.upcoming.id

    private var previewSize: CGSize {
        item.size.previewSize(
            fittingWidth: maximumPreviewWidth ?? item.size.previewWidth,
            maximumScale: maximumPreviewScale
        )
    }

    var body: some View {
        VStack(alignment: item.size == .small ? .leading : .center, spacing: titleSpacing) {
            WidgetPreview(item: item, usesPlaceholderPreview: usesPlaceholderPreview)
                .id(previewIdentity)
                .frame(width: previewSize.width, height: previewSize.height)

            if showsTitle {
                Text("\(item.displayName) | \(item.primaryCategory.title)")
                    .font(AppFonts.font(.subHeading))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(width: previewSize.width)
    }

    private var titleSpacing: CGFloat {
        switch item.size {
        case .small:
            10
        case .medium, .large:
            15
        }
    }

    private var previewIdentity: String {
        if item.id == "portal" {
            return "\(item.id)-\(portalSelectedAppsValue)-\(portalIconClipStyleID)"
        }

        guard item.id == "activity" else {
            if item.id == "events" {
                return "\(item.id)-\(eventModeID)"
            }

            return item.id
        }

        return "\(item.id)-\(activityModeID)"
    }
}

struct WidgetPreview: View {
    private static let settingsStore = AppGroupConstants.sharedDefaults

    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false
    var portalSelectedAppsOverride: [PortalApp]?
    var portalIconClipStyleOverride: PortalIconClipStyle?
    var activityModeOverride: ActivityMode?
    var eventModeOverride: EventDisplayMode?
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore) private var sharedAppFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.portalSelectedAppsKey, store: settingsStore) private var portalSelectedAppsValue = PortalApp.storageValue(for: PortalApp.defaultSelection)
    @AppStorage(AppGroupConstants.portalIconClipStyleKey, store: settingsStore) private var portalIconClipStyleID = PortalIconClipStyle.default.id
    @AppStorage(AppGroupConstants.sharedHealthStepsKey, store: settingsStore) private var healthSteps = 0
    @AppStorage(AppGroupConstants.sharedHealthDistanceKilometersKey, store: settingsStore) private var healthDistanceKilometers = 0.0
    @AppStorage(AppGroupConstants.activityModeKey, store: settingsStore) private var activityModeID = ActivityMode.today.id
    @AppStorage(AppGroupConstants.eventModeKey, store: settingsStore) private var eventModeID = EventDisplayMode.upcoming.id
    @AppStorage(AppGroupConstants.sharedEventsKey, store: settingsStore) private var eventSnapshotData = Data()
    @AppStorage(AppGroupConstants.sharedActivityTodayExerciseMinutesKey, store: settingsStore) private var activityTodayExerciseMinutes = 0
    @AppStorage(AppGroupConstants.sharedActivityTodayActiveEnergyKey, store: settingsStore) private var activityTodayActiveEnergy = 0
    @AppStorage(AppGroupConstants.sharedActivityTodaySleepMinutesKey, store: settingsStore) private var activityTodaySleepMinutes = 0
    @AppStorage(AppGroupConstants.sharedActivityWeeklyExerciseMinutesKey, store: settingsStore) private var activityWeeklyExerciseMinutes = 0
    @AppStorage(AppGroupConstants.sharedActivityWeeklyActiveEnergyKey, store: settingsStore) private var activityWeeklyActiveEnergy = 0
    @AppStorage(AppGroupConstants.sharedActivityWeeklySleepMinutesKey, store: settingsStore) private var activityWeeklySleepMinutes = 0
    @AppStorage(AppGroupConstants.sharedWeatherTemperatureKey, store: settingsStore) private var weatherTemperature = 25
    @AppStorage(AppGroupConstants.sharedWeatherHighKey, store: settingsStore) private var weatherHigh = 30
    @AppStorage(AppGroupConstants.sharedWeatherLowKey, store: settingsStore) private var weatherLow = 24
    @AppStorage(AppGroupConstants.sharedWeatherSymbolKey, store: settingsStore) private var weatherSymbol = "🌥️"
    @AppStorage(AppGroupConstants.sharedWeatherConditionLabelKey, store: settingsStore) private var weatherConditionLabel = "Partly Cloudy"
    @AppStorage(AppGroupConstants.sharedPortalWeatherTemperatureKey, store: settingsStore) private var portalWeatherTemperature = 16
    @AppStorage(AppGroupConstants.sharedPortalWeatherPlaceNameKey, store: settingsStore) private var portalWeatherPlaceName = "Here"
    @AppStorage(AppGroupConstants.settingsDistanceUnitKey, store: settingsStore) private var distanceUnitID = DistanceUnitPreference.kilometers.id

    private var widgetFontTheme: AbstraktWidgetFontTheme {
        AbstraktWidgetFontTheme.from(id: sharedAppFontThemeID.isEmpty ? appFontThemeID : sharedAppFontThemeID)
    }

    private var portalSelectedApps: [PortalApp] {
        portalSelectedAppsOverride ?? PortalApp.selection(from: portalSelectedAppsValue)
    }

    private var portalIconClipStyle: PortalIconClipStyle {
        portalIconClipStyleOverride ?? PortalIconClipStyle.from(id: portalIconClipStyleID)
    }

    @ViewBuilder
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1)) { timeline in
            if usesPlaceholderPreview {
                widgetBackground
            } else {
                switch item.id {
                case "battery":
                    BatteryWidget(
                        snapshot: BatterySnapshotViewData(snapshot: BatteryStatusProvider.currentSnapshot()),
                        fontTheme: widgetFontTheme
                    )
                case "steps":
                    StepsWidget(
                        snapshot: stepsSnapshot,
                        fontTheme: widgetFontTheme
                    )
                case "activity":
                    ActivityWidget(
                        snapshot: activitySnapshot,
                        fontTheme: widgetFontTheme
                    )
                case "events":
                    EventsWidget(
                        snapshot: eventSnapshot,
                        mode: eventMode,
                        fontTheme: widgetFontTheme
                    )
                case "portal":
                    Portal(
                        snapshot: PortalSnapshot(
                            date: timeline.date,
                            temperature: portalWeatherTemperature,
                            placeName: portalWeatherPlaceName
                        ),
                        fontTheme: widgetFontTheme,
                        selectedApps: portalSelectedApps,
                        iconClipStyle: portalIconClipStyle
                    )
                case "today":
                    TodayWidget(
                        snapshot: TodaySnapshot(
                            date: timeline.date,
                            temperature: weatherTemperature,
                            high: weatherHigh,
                            low: weatherLow,
                            weatherSymbol: weatherSymbol,
                            conditionLabel: weatherConditionLabel
                        ),
                        fontTheme: widgetFontTheme
                    )
                case "storage":
                    StorageWidget(
                        snapshot: StorageUsageSnapshot(snapshot: StorageProvider.currentSnapshot()),
                        fontTheme: widgetFontTheme
                    )
                case "weather":
                    WeatherWidget(fontTheme: widgetFontTheme)
                case "daylight":
                    DaylightWidget(fontTheme: widgetFontTheme)
                case "heart-rate":
                    HeartRateWidget(fontTheme: widgetFontTheme)
                default:
                    widgetBackground
                        .overlay(alignment: .topLeading) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(item.displayName)
                                    .font(item.size == .small ? AppFonts.widgetFont(.widgetBody, theme: .sfProRounded) : AppFonts.widgetFont(.widgetHeading, theme: .sfProRounded))
                                    .foregroundStyle(AppColors.widgetPrimaryText)
                                Text(item.primaryCategory.title)
                                    .font(AppFonts.widgetFont(.widgetCaption, theme: .sfProRounded))
                                    .foregroundStyle(AppColors.widgetSecondaryText)
                            }
                            .padding(20)
                        }
                }
            }
        }
    }

    private var stepsSnapshot: StepsSnapshot {
        let unit = DistanceUnitPreference.from(id: distanceUnitID)
        return StepsSnapshot(
            steps: healthSteps,
            distanceValue: unit.convertFromKilometers(healthDistanceKilometers),
            distanceUnitName: unit.noun
        )
    }

    private var activitySnapshot: ActivitySnapshot {
        let mode = activityModeOverride ?? ActivityMode.from(id: activityModeID)

        switch mode {
        case .today:
            return ActivitySnapshot(
                mode: .today,
                exerciseMinutes: activityTodayExerciseMinutes,
                activeEnergyCalories: activityTodayActiveEnergy,
                sleepMinutes: activityTodaySleepMinutes
            )
        case .weekly:
            return ActivitySnapshot(
                mode: .weekly,
                exerciseMinutes: activityWeeklyExerciseMinutes,
                activeEnergyCalories: activityWeeklyActiveEnergy,
                sleepMinutes: activityWeeklySleepMinutes
            )
        }
    }

    private var eventMode: EventDisplayMode {
        eventModeOverride ?? EventDisplayMode.from(id: eventModeID)
    }

    private var eventSnapshot: EventsSnapshot {
        guard !eventSnapshotData.isEmpty,
              let snapshot = try? JSONDecoder().decode(EventsSnapshot.self, from: eventSnapshotData) else {
            return EventsSnapshot(date: .now, accessState: .empty)
        }

        return snapshot
    }

    private var widgetBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
            .fill(AppColors.widgetBackground)
    }
}
