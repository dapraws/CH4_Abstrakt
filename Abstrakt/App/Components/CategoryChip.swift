import SwiftUI

struct CategoryChip: View {
    let category: WidgetCategory
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: category.systemImage)
                .font(AppFonts.font(.iconBadge))

            Text(category.title)
                .font(AppFonts.font(.chip))
        }
        .foregroundStyle(isSelected ? AppColors.chipTextSelected : AppColors.chipText)
        .padding(.horizontal, 16)
        .frame(height: 32)
        .background(isSelected ? AppColors.chipSelected : AppColors.chip)
        .overlay {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(isSelected ? AppColors.chipBorderSelected : AppColors.chipBorder, lineWidth: 0.5)
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

#Preview {
    ZStack {
        AppColors.appBackground.ignoresSafeArea()
        CategoryChip(category: .classic, isSelected: true)
    }
}
