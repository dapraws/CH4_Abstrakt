import SwiftUI

struct WidgetCard: View {
    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false
    var showsTitle = true

    var body: some View {
        VStack(alignment: item.size == .small ? .leading : .center, spacing: titleSpacing) {
            WidgetPreview(item: item, usesPlaceholderPreview: usesPlaceholderPreview)
                .frame(width: item.size.previewWidth, height: item.size.previewHeight)

            if showsTitle {
                Text("\(item.displayName) | \(item.primaryCategory.title)")
                    .font(AppFonts.font(.subHeading))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .frame(width: item.size.previewWidth)
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
    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false

    @ViewBuilder
    var body: some View {
        if usesPlaceholderPreview {
            widgetBackground
        } else {
            switch item.id {
            case "battery-bars-small":
                BatteryBarsWidget()
            case "step-health-small":
                StepHealthWidget()
            case "daily-dashboard-medium":
                DailyDashboardWidget()
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

    private var widgetBackground: some View {
        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
            .fill(AppColors.widgetBackground)
    }
}
