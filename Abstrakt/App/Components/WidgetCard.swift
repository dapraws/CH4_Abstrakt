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
        guard item.id == "portal-widget-small" else {
            return item.id
        }

        return "\(item.id)-\(portalSelectedAppsValue)-\(portalIconClipStyleID)"
    }
}

struct WidgetPreview: View {
    private static let settingsStore = AppGroupConstants.sharedDefaults

    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false
    var portalSelectedAppsOverride: [PortalApp]?
    var portalIconClipStyleOverride: PortalIconClipStyle?
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore) private var sharedAppFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.portalSelectedAppsKey, store: settingsStore) private var portalSelectedAppsValue = PortalApp.storageValue(for: PortalApp.defaultSelection)
    @AppStorage(AppGroupConstants.portalIconClipStyleKey, store: settingsStore) private var portalIconClipStyleID = PortalIconClipStyle.default.id
    @AppStorage(AppGroupConstants.sharedHealthStepsKey, store: settingsStore) private var healthSteps = 0
    @AppStorage(AppGroupConstants.sharedHealthDistanceKilometersKey, store: settingsStore) private var healthDistanceKilometers = 0.0
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
                case "battery-bars-small":
                    BatteryBarsWidget(
                        snapshot: BatteryBarsRenderSnapshot(snapshot: BatteryStatusProvider.currentSnapshot()),
                        fontTheme: widgetFontTheme
                    )
                case "step-health-small":
                    StepHealthWidget(
                        snapshot: stepHealthSnapshot,
                        fontTheme: widgetFontTheme
                    )
                case "portal-widget-small":
                    PortalWidget(
                        snapshot: PortalWidgetSnapshot(
                            date: timeline.date,
                            temperature: portalWeatherTemperature,
                            placeName: portalWeatherPlaceName
                        ),
                        fontTheme: widgetFontTheme,
                        selectedApps: portalSelectedApps,
                        iconClipStyle: portalIconClipStyle
                    )
                case "daily-dashboard-medium":
                    DailyDashboardWidget(
                        snapshot: DailyDashboardSnapshot(
                            date: timeline.date,
                            temperature: weatherTemperature,
                            high: weatherHigh,
                            low: weatherLow,
                            weatherSymbol: weatherSymbol,
                            conditionLabel: weatherConditionLabel
                        ),
                        fontTheme: widgetFontTheme
                    )
                case "device-storage-small":
                    DeviceStorageWidget(
                        snapshot: DeviceStorageRenderSnapshot(snapshot: StorageProvider.currentSnapshot()),
                        fontTheme: widgetFontTheme
                    )
                case "classic-weather-small":
                    ClassicWeatherWidget(fontTheme: widgetFontTheme)
                case "sun-event-weather-small", "sunevent-weather-small":
                    SunEventWeatherWidget(fontTheme: widgetFontTheme)
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

    private var stepHealthSnapshot: StepHealthRenderSnapshot {
        let unit = DistanceUnitPreference.from(id: distanceUnitID)
        return StepHealthRenderSnapshot(
            steps: healthSteps,
            distanceValue: unit.convertFromKilometers(healthDistanceKilometers),
            distanceUnitName: unit.noun
        )
    }

    private var widgetBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
            .fill(AppColors.widgetBackground)
    }
}
