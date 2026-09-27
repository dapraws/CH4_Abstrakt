import SwiftUI

struct WidgetCustomizationSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            Text(title)
                .font(AppFonts.font(.heading4))
                .foregroundStyle(AppColors.primaryText)
                .padding(.horizontal, 4)

            content
        }
        .frame(maxWidth: 360, alignment: .leading)
    }
}

struct WidgetAppearanceControls: View {
    @Binding var mode: WidgetAppearanceMode

    var body: some View {
        GeometryReader { proxy in
            let options = WidgetAppearanceMode.allCases
            let selectedIndex = options.firstIndex(of: mode) ?? 0
            let innerPadding: CGFloat = 5
            let segmentWidth = max(
                0,
                (proxy.size.width - (innerPadding * 2)) / CGFloat(options.count)
            )

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(AppColors.card)
                    .frame(width: segmentWidth, height: 58)
                    .offset(
                        x: innerPadding
                            + (CGFloat(selectedIndex) * segmentWidth)
                    )
                    .animation(
                        .snappy(duration: 0.24, extraBounce: 0),
                        value: mode
                    )

                HStack(spacing: 0) {
                    ForEach(options) { option in
                        Button {
                            Haptics.selection.play()
                            mode = option
                        } label: {
                            Label(option.title, systemImage: option.systemImage)
                                .font(AppFonts.font(.heading4))
                                .foregroundStyle(AppColors.primaryText)
                                .labelStyle(.titleAndIcon)
                                .frame(maxWidth: .infinity)
                                .frame(height: 58)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(innerPadding)
            }
            .background(AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .frame(maxWidth: 360)
        .frame(height: 68)
    }
}
