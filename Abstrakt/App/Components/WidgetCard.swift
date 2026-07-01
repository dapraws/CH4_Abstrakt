import SwiftUI

struct WidgetCard: View {
    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false
    var showsTitle = true
    var maximumPreviewWidth: CGFloat?
    var maximumPreviewScale: CGFloat = 1

    private var previewSize: CGSize {
        item.size.previewSize(
            fittingWidth: maximumPreviewWidth ?? item.size.previewWidth,
            maximumScale: maximumPreviewScale
        )
    }

    var body: some View {
        VStack(alignment: item.size == .small ? .leading : .center, spacing: titleSpacing) {
            WidgetPreview(item: item, usesPlaceholderPreview: usesPlaceholderPreview)
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
            18
        }
    }
}

struct WidgetPreview: View {
    private static let settingsStore = UserDefaults(suiteName: AppGroupConstants.suiteName)

    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false
    var portalSelectedAppsOverride: [PortalApp]?
    var portalIconClipStyleOverride: PortalIconClipStyle?
    @AppStorage(AppFonts.appFontStorageKey) private var appFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.settingsAppFontThemeKey, store: settingsStore) private var sharedAppFontThemeID = AppFonts.defaultTheme.id
    @AppStorage(AppGroupConstants.portalSelectedAppsKey, store: settingsStore) private var portalSelectedAppsValue = PortalApp.storageValue(for: PortalApp.defaultSelection)
    @AppStorage(AppGroupConstants.portalIconClipStyleKey, store: settingsStore) private var portalIconClipStyleID = PortalIconClipStyle.default.id

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
        Group {
            if usesPlaceholderPreview {
                widgetBackground
            } else {
                switch item.id {
                case "battery-bars-small":
                    BatteryBarsWidget(fontTheme: widgetFontTheme)
                case "step-health-small":
                    StepHealthWidget(fontTheme: widgetFontTheme)
                case "portal-widget-small":
                    PortalWidget(
                        fontTheme: widgetFontTheme,
                        selectedApps: portalSelectedApps,
                        iconClipStyle: portalIconClipStyle
                    )
                case "daily-dashboard-medium":
                    DailyDashboardWidget(fontTheme: widgetFontTheme)
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

    private var widgetBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
            .fill(AppColors.widgetBackground)
    }
}
