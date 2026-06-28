import SwiftUI

struct WidgetDetailScreen: View {
    let item: WidgetCatalogItem

    var body: some View {
        ScrollFadeView(showsIndicators: false, headerHeight: 62, contentTopPadding: 12) { fadeProgress in
            FadingNavigationBar(fadeProgress: fadeProgress) {
                HStack {
                    Text(item.displayName)
                        .font(AppFonts.font(.titleCompact))
                        .foregroundStyle(AppColors.primaryText)
                        .lineLimit(1)

                    Spacer()
                }
            }
        } content: {
            VStack(alignment: .leading, spacing: AppSpacing.sectionGap) {
                WidgetCard(item: item)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Categories")
                        .font(AppFonts.font(.titleCompact))
                        .foregroundStyle(AppColors.primaryText)

                    LazyVGrid(columns: [.init(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                        ForEach(item.categories) { category in
                            CategoryChip(category: category, isSelected: true)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, 8)
        }
        .background(AppColors.appBackground)
    }
}

#Preview {
    WidgetDetailScreen(item: WidgetCatalog.items[0])
}
