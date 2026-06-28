import SwiftUI

struct WidgetCard: View {
    let item: WidgetCatalogItem
    var usesPlaceholderPreview = false
    var showsTitle = true

    var body: some View {
        VStack(alignment: item.size == .small ? .leading : .center, spacing: 10) {
            widgetPreview(for: item)
                .frame(height: item.featuredHeight)

            if showsTitle {
                Text("\(item.displayName) | \(item.primaryCategory.title)")
                    .font(AppFonts.font(.bodyStrong))
                    .foregroundStyle(AppColors.primaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }

    @ViewBuilder
    private func widgetPreview(for item: WidgetCatalogItem) -> some View {
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
                                .font(item.size == .small ? AppFonts.font(.bodyStrong) : AppFonts.font(.titleCompact))
                                .foregroundStyle(AppColors.widgetPrimaryText)
                            Text(item.primaryCategory.title)
                                .font(AppFonts.font(.body))
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
