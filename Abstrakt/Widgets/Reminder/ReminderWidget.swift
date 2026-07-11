import SwiftUI
import WidgetKit

struct ReminderWidget: View {
    private static let widgetCornerRadius: CGFloat = 22

    let snapshot: ReminderSnapshot
    let fontTheme: AbstraktWidgetFontTheme
    var clipsToWidgetShape = true

    @Environment(\.colorScheme) private var colorScheme

    init(
        snapshot: ReminderSnapshot = .placeholder,
        fontTheme: AbstraktWidgetFontTheme = .selectedAppTheme,
        clipsToWidgetShape: Bool = true
    ) {
        self.snapshot = snapshot
        self.fontTheme = fontTheme
        self.clipsToWidgetShape = clipsToWidgetShape
    }

    var body: some View {
        GeometryReader { proxy in
            let metrics = ReminderWidgetMetrics(size: proxy.size)

            ZStack(alignment: .top) {
                palette.background
                VStack(spacing: 0) {
                    header(metrics: metrics)
                    bodyContent(metrics: metrics)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(
            RoundedRectangle(
                cornerRadius: clipsToWidgetShape ? Self.widgetCornerRadius : 0,
                style: .continuous
            )
        )
        .containerBackground(for: .widget) {
            palette.background
        }
    }

    private func header(metrics: ReminderWidgetMetrics) -> some View {
        ZStack {
            headerFill

            Text("Reminder")
                .font(AbstraktWidgetFonts.font(.heading, theme: fontTheme))
                .foregroundStyle(headerText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .padding(.bottom, metrics.headerTitleLift)
        }
        .overlay(alignment: .bottom) {
            dashedRule
                .padding(.horizontal, metrics.ruleHorizontalInset)
                .padding(.bottom, metrics.ruleBottomInset)
        }
        .frame(height: metrics.headerHeight)
    }

    @ViewBuilder
    private func bodyContent(metrics: ReminderWidgetMetrics) -> some View {
        switch snapshot.accessState {
        case .available:
            reminderList(metrics: metrics)
        case .empty:
            emptyState(
                title: "All clear",
                subtitle: "No reminders right now",
                metrics: metrics
            )
        case .permissionNeeded:
            emptyState(
                title: "Connect Reminders",
                subtitle: "Allow access in Abstrakt",
                metrics: metrics
            )
        }
    }

    private func reminderList(metrics: ReminderWidgetMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.listSpacing) {
            ForEach(snapshot.items.prefix(3)) { item in
                HStack(alignment: .center, spacing: metrics.rowSpacing) {
                    itemMarker(for: item, metrics: metrics)

                    Text(item.title)
                        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                        .foregroundStyle(item.isCompleted ? palette.tertiaryForeground : palette.foreground)
                        .strikethrough(item.isCompleted, color: palette.tertiaryForeground)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .minimumScaleFactor(0.74)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            if snapshot.remainingItemCount > 0 {
                HStack(alignment: .center, spacing: metrics.rowSpacing) {
                    Color.clear
                        .frame(width: metrics.markerSize, height: metrics.markerSize)

                    Text("+\(snapshot.remainingItemCount) more")
                        .font(AbstraktWidgetFonts.font(.body, theme: fontTheme))
                        .foregroundStyle(palette.secondaryForeground)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, metrics.bodyHorizontalPadding)
        .padding(.top, metrics.bodyTopPadding)
        .padding(.bottom, metrics.bodyBottomPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func itemMarker(for item: ReminderSummary, metrics: ReminderWidgetMetrics) -> some View {
        Group {
            if item.isCompleted {
                RoundedRectangle(cornerRadius: metrics.completedCornerRadius, style: .continuous)
                    .fill(Color(red: 0.39, green: 0.78, blue: 0.41))
            } else {
                RoundedRectangle(cornerRadius: metrics.pendingCornerRadius, style: .continuous)
                    .strokeBorder(palette.tertiaryForeground, lineWidth: 1)
            }
        }
        .frame(width: metrics.markerSize, height: metrics.markerSize)
    }

    private func emptyState(
        title: String,
        subtitle: String,
        metrics: ReminderWidgetMetrics
    ) -> some View {
        VStack(spacing: metrics.emptyStateSpacing) {
            Image(systemName: snapshot.accessState == .permissionNeeded ? "list.bullet.clipboard" : "checkmark.circle")
                .font(.system(size: metrics.emptyIconSize, weight: .semibold))
                .foregroundStyle(snapshot.accessState == .permissionNeeded ? palette.tertiaryForeground : Color(red: 0.39, green: 0.78, blue: 0.41))

            VStack(spacing: 3) {
                Text(title)
                    .font(AbstraktWidgetFonts.font(.bodyBold, theme: fontTheme))
                    .foregroundStyle(palette.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(subtitle)
                    .font(AbstraktWidgetFonts.font(.caption, theme: fontTheme))
                    .foregroundStyle(palette.secondaryForeground)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }
        }
        .padding(.horizontal, metrics.bodyHorizontalPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var dashedRule: some View {
        HStack(spacing: 4) {
            ForEach(0..<11, id: \.self) { _ in
                Capsule()
                    .fill(headerText.opacity(0.74))
                    .frame(height: 2)
            }
        }
    }

    private var palette: AbstraktWidgetPalette {
        AbstraktWidgetPalette(colorScheme: colorScheme)
    }

    private var headerFill: Color {
        colorScheme == .dark
            ? Color(red: 0.82, green: 0.63, blue: 0.18)
            : Color(red: 0.98, green: 0.80, blue: 0.18)
    }

    private var headerText: Color {
        colorScheme == .dark ? Color.black.opacity(0.84) : Color.white
    }
}

private struct ReminderWidgetMetrics {
    let size: CGSize

    var headerHeight: CGFloat { size.height * 0.28 }
    var headerTitleLift: CGFloat { size.height * 0.02 }
    var ruleHorizontalInset: CGFloat { size.width * 0.04 }
    var ruleBottomInset: CGFloat { size.height * 0.012 }
    var bodyHorizontalPadding: CGFloat { size.width * 0.07 }
    var bodyTopPadding: CGFloat { size.height * 0.06 }
    var bodyBottomPadding: CGFloat { size.height * 0.06 }
    var listSpacing: CGFloat { max(8, size.height * 0.056) }
    var rowSpacing: CGFloat { max(8, size.width * 0.04) }
    var markerSize: CGFloat { max(10, size.width * 0.055) }
    var pendingCornerRadius: CGFloat { 3 }
    var completedCornerRadius: CGFloat { 3 }
    var emptyIconSize: CGFloat { max(18, size.width * 0.11) }
    var emptyStateSpacing: CGFloat { max(8, size.height * 0.04) }
}
