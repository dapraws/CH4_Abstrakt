import SwiftUI

protocol WidgetSegmentedOption: CaseIterable, Hashable, Identifiable
where AllCases: Collection, AllCases.Element == Self {
    var title: String { get }
    var customizationSystemImage: String { get }
}

extension ActivityMode: WidgetSegmentedOption {
    var customizationSystemImage: String {
        switch self {
        case .today:
            "sun.max.fill"
        case .weekly:
            "calendar.badge.clock"
        }
    }
}

extension EventDisplayMode: WidgetSegmentedOption {
    var customizationSystemImage: String {
        switch self {
        case .upcoming:
            "calendar.badge.clock"
        case .current:
            "calendar.badge.exclamationmark"
        }
    }
}

struct WidgetSegmentedControl<Option: WidgetSegmentedOption>: View {
    @Binding var selection: Option

    var body: some View {
        GeometryReader { proxy in
            let options = Array(Option.allCases)
            let selectedIndex = options.firstIndex(of: selection) ?? 0
            let innerPadding: CGFloat = 5
            let segmentWidth = max(
                0,
                (proxy.size.width - (innerPadding * 2)) / CGFloat(options.count)
            )

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppColors.card)
                    .frame(width: segmentWidth, height: 48)
                    .offset(
                        x: innerPadding
                            + (CGFloat(selectedIndex) * segmentWidth)
                    )
                    .animation(
                        .snappy(duration: 0.24, extraBounce: 0),
                        value: selection
                    )

                HStack(spacing: 0) {
                    ForEach(options) { option in
                        Button {
                            Haptics.selection.play()
                            selection = option
                        } label: {
                            Label(
                                option.title,
                                systemImage: option.customizationSystemImage
                            )
                            .font(AppFonts.font(.heading3))
                            .foregroundStyle(AppColors.primaryText)
                            .labelStyle(.titleAndIcon)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(innerPadding)
            }
            .background(AppColors.cardSoft)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .frame(maxWidth: 360)
        .frame(height: 58)
    }
}
